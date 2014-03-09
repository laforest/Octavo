
module ALU 
#(
    parameter               OPCODE_WIDTH            = 0,
    parameter               D_OPERAND_WIDTH         = 0,
    parameter               WORD_WIDTH              = 0,
    parameter               AB_ALU_PIPELINE_DEPTH   = 0,
    parameter               ADDSUB_CARRY_SELECT     = 0,
    parameter               LOGIC_OPCODE_WIDTH      = 0,
    parameter               MULT_DOUBLE_PIPE        = 0,
    parameter               MULT_HETEROGENEOUS      = 0,    // Only meaningful for a double pipe mult
    parameter               MULT_USE_DSP            = 0
)
(
    input   wire                                    clock,
    input   wire                                    half_clock,
    input   wire                                    c_in,
    input   wire            [OPCODE_WIDTH-1:0]      op_in,
    input   wire            [D_OPERAND_WIDTH-1:0]   D_in,
    input   wire            [WORD_WIDTH-1:0]        A,
    input   wire            [WORD_WIDTH-1:0]        B,
    output  reg     signed  [WORD_WIDTH-1:0]        R,
    output  reg             [OPCODE_WIDTH-1:0]      op_out,
    output  wire                                    c_out,
    output  wire            [D_OPERAND_WIDTH-1:0]   D_out
);


// ************* Calculate pipeline depths and latencies **************

    // Linear relationships between *even* numbers of total datapath pipeline stages to multiplier internal pipeline stages 
    // Double Pipeline
    // 8 -> 2, 10 -> 3, 12 -> 4, 14 -> 5, 16 -> 6
    // y = x - x/2 - 2
    // Single Pipeline
    // 8 -> 3, 10 -> 5, 12 -> 7, 14 -> 9, 16 -> 11
    // y = x - 5
    localparam MULT_PIPELINE_DEPTH  = MULT_DOUBLE_PIPE ? (AB_ALU_PIPELINE_DEPTH - (AB_ALU_PIPELINE_DEPTH / 2) - 2) : (AB_ALU_PIPELINE_DEPTH - 5);
    // Double Pipeline
    // Two internal multiplexed paths, running on opposite clock edges 
    // Single Pipeline
    // One pipelined internal path, no extra output reg.
    localparam MULT_LATENCY         = MULT_DOUBLE_PIPE ? ((MULT_PIPELINE_DEPTH * 2) - 1) : MULT_PIPELINE_DEPTH;

    // ALU output is registered
    localparam ALU_LATENCY          = MULT_LATENCY + 1;
    
    // Simple AND/XOR with MUX for addsub result.
    localparam BITWISE_LATENCY      = 1;
    // Two-stage adder seems to be fast enough
    localparam ADDSUB_LATENCY       = 2;

    // How many delay stages before feeding operation and operands to ADDSUB
    localparam ADDSUB_DELAY         = ALU_LATENCY - ADDSUB_LATENCY - BITWISE_LATENCY - 1;
    // How many delay stages before feeding operation and operands to logic unit
    localparam BITWISE_DELAY        = ALU_LATENCY - ADDSUB_LATENCY;

// ************* Tappable delay lines to match functional unit pipeline depths **************

    integer i;

    reg     [OPCODE_WIDTH-1:0]  op_delay    [ALU_LATENCY-1:0];

    initial begin
        for(i = 0; i < ALU_LATENCY; i = i + 1) begin
            op_delay[i] = 0;
        end
    end

    always @(*) begin
        op_delay[0] <= op_in;
    end
    always @(posedge clock) begin
        for(i = 1; i < ALU_LATENCY; i = i + 1) begin
            op_delay[i] <= op_delay[i-1];
        end
    end

    reg     [WORD_WIDTH-1:0]   A_delay     [ALU_LATENCY-1:0];
    reg     [WORD_WIDTH-1:0]   B_delay     [ALU_LATENCY-1:0];

    initial begin
        for(i = 0; i < ALU_LATENCY; i = i + 1) begin
            A_delay[i] = 0;
            B_delay[i] = 0;
        end
    end

    always @(*) begin
        A_delay[0] <= A;
        B_delay[0] <= B;
    end
    always @(posedge clock) begin
        for(i = 1; i < ALU_LATENCY; i = i + 1) begin
            A_delay[i] <= A_delay[i-1];
            B_delay[i] <= B_delay[i-1];
        end
    end


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

    wire    [WORD_WIDTH-1:0]    add_sub_result;
    wire                        add_sub   = op_delay[ADDSUB_DELAY][2]; // selects ADD (1) or SUB (0)
    wire    [WORD_WIDTH-1:0]    add_sub_A = A_delay[ADDSUB_DELAY];
    wire    [WORD_WIDTH-1:0]    add_sub_B = B_delay[ADDSUB_DELAY];

    // Use Carry-Select to scale better at large widths or route with more slack
    // ...or since speed doesn't seem to be a problem...use ripple-carry to save area!
    generate
        if(ADDSUB_CARRY_SELECT) begin
            AddSub_Carry_Select 
            #(
                .WORD_WIDTH     (WORD_WIDTH)
            )
            AddSub 
            (
                .clock          (clock),
                .add_sub        (add_sub),
                .cin            (c_in),
                .dataa          (add_sub_A),
                .datab          (add_sub_B),
                .cout           (c_out),
                .result         (add_sub_result)
            );
        end
        else begin
            AddSub_Ripple_Carry 
            #(
                .WORD_WIDTH     (WORD_WIDTH)
            )
            AddSub 
            (
                .clock          (clock),
                .add_sub        (add_sub),
                .cin            (c_in),
                .dataa          (add_sub_A),
                .datab          (add_sub_B),
                .cout           (c_out),
                .result         (add_sub_result)
            );
        end
    endgenerate


// ************* The Bitwise Logic Unit **************

    wire    [WORD_WIDTH-1:0]            bitwise_result;
    wire    [LOGIC_OPCODE_WIDTH-1:0]    bitwise_opcode = op_delay[BITWISE_DELAY][LOGIC_OPCODE_WIDTH-1:0];
    wire    [WORD_WIDTH-1:0]            bitwise_A      = A_delay[BITWISE_DELAY];
    wire    [WORD_WIDTH-1:0]            bitwise_B      = B_delay[BITWISE_DELAY];

    Bitwise 
    #(
        .OPCODE_WIDTH   (LOGIC_OPCODE_WIDTH), 
        .WORD_WIDTH     (WORD_WIDTH)
    )
    Bitwise
    (
        .clock          (clock),
        .op             (bitwise_opcode),
        .add_sub_result (add_sub_result),
        .A              (bitwise_A),
        .B              (bitwise_B),
        .R              (bitwise_result)
    );

// ************* The Multiplier **************

    wire    signed  [WORD_WIDTH-1:0]    mult_result_hi;
    wire    signed  [WORD_WIDTH-1:0]    mult_result_lo;
    wire                                sign = ~op_delay[0][1];

    Mult 
    #(
        .DOUBLE_PIPE    (MULT_DOUBLE_PIPE),
        .HETEROGENEOUS  (MULT_HETEROGENEOUS),
        .USE_DSP        (MULT_USE_DSP),
        .WORD_WIDTH     (WORD_WIDTH),
        .PIPE_DEPTH     (MULT_PIPELINE_DEPTH)
    )
    Mult
    (
        .clock          (clock),
        .half_clock     (half_clock),
        // Largest latency, hence no delayed operands
        .sign           (sign),
        .A              (A),
        .B              (B),
        .R_lo           (mult_result_lo),
        .R_hi           (mult_result_hi)
    );


// ************* The Final Mux **************
    
    wire    select_addsub_mult  =  op_delay[ALU_LATENCY-1][OPCODE_WIDTH-1];
    wire    select_mhi_mlo      = ~op_delay[ALU_LATENCY-1][0];

    always @(posedge clock) begin
        case ({select_addsub_mult, select_mhi_mlo})
            'b00: R <= bitwise_result;
            'b01: R <= bitwise_result;
            'b10: R <= mult_result_lo;
            'b11: R <= mult_result_hi;
            default: R <= 'bX;
        endcase
    end

    always @(posedge clock) begin
        op_out <= op_delay[ALU_LATENCY-1];
    end

    initial begin
        op_out = 0;
        R      = 0;
    end
endmodule
