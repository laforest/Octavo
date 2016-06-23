
// Add/Sub followed by Boolean logic. 
// No multiply. (left as later accelerator)

module ALU 
#(
    parameter               CONTROL_WIDTH           = 0,
    parameter               WORD_WIDTH              = 0,
    parameter               D_OPERAND_WIDTH         = 0,
    parameter               LOGIC_OPCODE_WIDTH      = 0
)
(
    input   wire                                    clock,
    input   wire            [CONTROL_WIDTH-1:0]     control,
    input   wire            [D_OPERAND_WIDTH-1:0]   D_in,
    input   wire            [WORD_WIDTH-1:0]        A,
    input   wire            [WORD_WIDTH-1:0]        B,
    output  wire    signed  [WORD_WIDTH-1:0]        R,
    output  wire            [D_OPERAND_WIDTH-1:0]   D_out
);

// -----------------------------------------------------------

    localparam ALU_LATENCY = 4; // XXX ECL HARDCODED

// ************* Carry D operand through ALU pipeline **************

    delay_line 
    #(
        .DEPTH  (ALU_LATENCY),
        .WIDTH  (D_OPERAND_WIDTH)
    )
    D_pipeline
    (
        .clock  (clock),
        .in     (D_in),
        .out    (D_out)
    );


// ************* The Adder/Subtractor **************

    reg                         control_add_sub;
    wire    [WORD_WIDTH-1:0]    result_add_sub;

    always @(*) begin
        control_add_sub = control[0];
    end

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    AddSub 
    (
        .clock          (clock),
        .add_sub        (control_add_sub),
        .cin            (`LOW),
        .dataa          (A),
        .datab          (B),
        .cout           (),                 // N/C
        .result         (result_add_sub)
    );

// -----------------------------------------------------------

    wire    [CONTROL_WIDTH-1:0] control_bitwise;

    delay_line
    #(
        .DEPTH  (2), // XXX ECL HARDCODED
        .WIDTH  (CONTROL_WIDTH)
    )
    AddSub_Control_Pipeline
    (
        .clock  (clock),
        .in     (control),
        .out    (control_bitwise)
    );

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]    A_bitwise;

    delay_line
    #(
        .DEPTH  (2), // XXX ECL HARDCODED
        .WIDTH  (WORD_WIDTH)
    )
    AddSub_A_Pipeline
    (
        .clock  (clock),
        .in     (A),
        .out    (A_bitwise)
    );

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]    B_bitwise;

    delay_line
    #(
        .DEPTH  (2), // XXX ECL HARDCODED
        .WIDTH  (WORD_WIDTH)
    )
    AddSub_B_Pipeline
    (
        .clock  (clock),
        .in     (B),
        .out    (B_bitwise)
    );

// ************* The Bitwise Logic Unit **************

    wire    [WORD_WIDTH-1:0]            result_bitwise;
    reg     [LOGIC_OPCODE_WIDTH-1:0]    opcode_bitwise;

    always @(*) begin
        opcode_bitwise = control_bitwise[1 +: LOGIC_OPCODE_WIDTH];
    end

    Bitwise 
    #(
        .OPCODE_WIDTH   (LOGIC_OPCODE_WIDTH), 
        .WORD_WIDTH     (WORD_WIDTH)
    )
    Bitwise
    (
        .clock          (clock),
        .op             (opcode_bitwise),
        .result_add_sub (result_add_sub),
        .A              (A_bitwise),
        .B              (B_bitwise),
        .R              (result_bitwise)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1), // XXX ECL HARDCODED
        .WIDTH  (WORD_WIDTH)
    )
    Bitwise_Result_Pipeline
    (
        .clock  (clock),
        .in     (result_bitwise),
        .out    (R)
    );

endmodule
