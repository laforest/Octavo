
// Implements all Triadic Boolean operations, plus extended Boolean operations
// of the form f((+/-A+/-B), g(A,B,R)) where f() is the universal Dyadic
// Boolean operator, and g() is the universal Triadic Boolean operator.

// This ALU produces two results at once, usually identical, but with some
// limited computations on the A/B/R arguments when split.  These computations
// include a Double Move, optionally permuting A and B, and the basis for
// load/store with displacement addressing, producing both R and +/-A+/-B.

// When split, Ra = g(A,B,R) and Rb = f((+/-A+/-B), g(A,B,R))
// Rb can also be optionally shifted left or right by 1, signed and unsigned.

// R is assumed to be volatile: it's always the previous result, though this
// is not enforced in the design. The S argument is intended to be
// a persistent version of R, stored in a register somewhere. It is useful as
// a value not dependent on the previous result.

// --------------------------------------------------------------------

module Triadic_ALU
#(
    parameter   WORD_WIDTH                      = 0
)
(
    input   wire                                clock,
    input   wire    [`TRIADIC_CTRL_WIDTH-1:0]   control,    // Bits defining various sub-operations
    input   wire    [WORD_WIDTH-1:0]            A,          // First source argument
    input   wire    [WORD_WIDTH-1:0]            B,          // Second source argument
    input   wire    [WORD_WIDTH-1:0]            R,          // Third source argument  (previous result)
    input   wire                                R_zero,     // Computed flag in feedback pipeline (Ra->R)
    input   wire                                R_negative, // Computed flag in feedback pipeline (Ra->R)
    input   wire    [WORD_WIDTH-1:0]            S,          // Fourth source argument (persistent value)
    output  reg     [WORD_WIDTH-1:0]            Ra,         // First result
    output  reg     [WORD_WIDTH-1:0]            Rb,         // Second result
    output  wire                                carry_out,  // predicate from +/-A+/-B
    output  wire                                overflow    // predicate from +/-A+/-B
);

// --------------------------------------------------------------------

    initial begin
        Ra = 0;
        Rb = 0;
    end

// --------------------------------------------------------------------

    localparam PIPELINE_STAGES              = 4;
    localparam DYADIC_CTRL_WIDTH            = 4;
    localparam R_SELECTOR_CTRL_WIDTH        = 2;
    localparam R_SELECTOR_INPUT_COUNT       = 2**R_SELECTOR_CTRL_WIDTH;
    localparam ADD_SUB_CTRL_WIDTH           = 2;
    localparam ADD_SUB_PIPE_DEPTH           = 2;
    localparam SHIFT_SELECTOR_CTRL_WIDTH    = 2;
    localparam SHIFT_SELECTOR_INPUT_COUNT   = 2**SHIFT_SELECTOR_CTRL_WIDTH;
    localparam SPLIT_SELECTOR_CTRL_WIDTH    = 1;
    localparam SPLIT_SELECTOR_INPUT_COUNT   = 2**SPLIT_SELECTOR_CTRL_WIDTH;
    localparam TRIADIC_DUAL_WIDTH           = 1;

    integer i;
    genvar  j;

// --------------------------------------------------------------------

    // First, lets create the control pipeline

    reg [`TRIADIC_CTRL_WIDTH-1:0] control_pipeline [PIPELINE_STAGES-1:0];

    initial begin
        for(i = 0; i < PIPELINE_STAGES; i = i+1) begin
            control_pipeline[i] <= 0;
        end
    end

    always @(*) begin
        control_pipeline[0] = control;
    end

    always @(posedge clock) begin
        for(i = 1; i < PIPELINE_STAGES; i = i+1) begin
            control_pipeline[i] <= control_pipeline[i-1];
        end
    end

// --------------------------------------------------------------------

    // Second, lets extract all the control fields at each pipeline stage
    // Any unused ones will optimize away

    reg [R_SELECTOR_CTRL_WIDTH-1:0]     R_selector      [PIPELINE_STAGES-1:0];
    reg [SPLIT_SELECTOR_CTRL_WIDTH-1:0] split_selector  [PIPELINE_STAGES-1:0];
    reg [SHIFT_SELECTOR_CTRL_WIDTH-1:0] shift_selector  [PIPELINE_STAGES-1:0];
    reg [DYADIC_CTRL_WIDTH-1:0]         dyadic_1        [PIPELINE_STAGES-1:0];
    reg [DYADIC_CTRL_WIDTH-1:0]         dyadic_2        [PIPELINE_STAGES-1:0];
    reg [DYADIC_CTRL_WIDTH-1:0]         dyadic_3        [PIPELINE_STAGES-1:0];
    reg [ADD_SUB_CTRL_WIDTH-1:0]        add_sub         [PIPELINE_STAGES-1:0];
    reg [TRIADIC_DUAL_WIDTH-1:0]        triadic_dual    [PIPELINE_STAGES-1:0];

    initial begin
        for(i = 0; i < PIPELINE_STAGES; i = i+1) begin
            {split_selector[i],shift_selector[i],dyadic_3[i],add_sub[i],triadic_dual[i],dyadic_2[i],dyadic_1[i],R_selector[i]} = 0;
        end
    end

    always @(*) begin
        for(i = 0; i < PIPELINE_STAGES; i = i+1) begin
            {split_selector[i],shift_selector[i],dyadic_3[i],add_sub[i],triadic_dual[i],dyadic_2[i],dyadic_1[i],R_selector[i]} = control_pipeline[i];
        end
    end

// --------------------------------------------------------------------

    // Stage 0: Select R, compute dyadic_1 and dyadic_2, start add_sub

// --------------------------------------------------------------------

    // Expand R flags into masks

    reg [WORD_WIDTH-1:0] R_zero_mask;
    reg [WORD_WIDTH-1:0] R_negative_mask;

    always @(*) begin
        R_zero_mask     <= {WORD_WIDTH{R_zero}};
        R_negative_mask <= {WORD_WIDTH{R_negative}};
    end

    wire [WORD_WIDTH-1:0] selected_R_raw;

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (R_SELECTOR_CTRL_WIDTH),
        .INPUT_COUNT    (R_SELECTOR_INPUT_COUNT)
    )
    Select_R
    (
        .addr           (R_selector[0]),    
        .in             ({S,R_negative_mask,R_zero_mask,R}),
        .out            (selected_R_raw)
    );

    reg [WORD_WIDTH-1:0] selected_R = 0;

    always @(posedge clock) begin
        selected_R <= selected_R_raw;
    end
    
// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] D1_raw;

    Dyadic_Boolean_Operator
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    D1
    (
        .op             (dyadic_1[0]),
        .a              (A),
        .b              (B),
        .o              (D1_raw)
    );

    reg [WORD_WIDTH-1:0] D1_out = 0;

    always @(posedge clock) begin
        D1_out <= D1_raw;
    end
    
// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] D2_raw;

    Dyadic_Boolean_Operator
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    D2
    (
        .op             (dyadic_2[0]),
        .a              (A),
        .b              (B),
        .o              (D2_raw)
    );

    reg [WORD_WIDTH-1:0] D2_out = 0;

    always @(posedge clock) begin
        D2_out <= D2_raw;
    end
    
// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0]   sum_raw;
    wire                    carry_out_raw;
    wire                    overflow_raw;

    AddSub_Ripple_Carry_NoCarry
    #(
        .WORD_WIDTH      (WORD_WIDTH)
    )
    AddSub
    (
        .A              (A),
        .A_negative     (add_sub[0][0]),
        .B              (B),
        .B_negative     (add_sub[0][1]),
        .sum            (sum_raw),
        .carry_out      (carry_out_raw),
        .overflow       (overflow_raw)
    );

    // I don't know how to design the above adder as two pipeline stages, so
    // lets place the pipeline registers after the output and hope the CAD
    // tool retimes the registers appropriately.

    wire [WORD_WIDTH-1:0] sum;

    Delay_Line 
    #(
        .DEPTH  (ADD_SUB_PIPE_DEPTH), 
        .WIDTH  (WORD_WIDTH)
    ) 
    AddSub_pipeline
    (
        .clock  (clock),
        .in     (sum_raw),
        .out    (sum)
    );

    // Carry-along the predicates to the ALU output.

    Delay_Line 
    #(
        .DEPTH  (PIPELINE_STAGES), 
        .WIDTH  (2)
    ) 
    Predicates_pipeline
    (
        .clock  (clock),
        .in     ({carry_out_raw,overflow_raw}),
        .out    ({carry_out,overflow})
    );
    
// --------------------------------------------------------------------

    // Stage 1: select dyadic_1/2 with selected_R to generate triadic result,
    // add_sub continues implicitly

// --------------------------------------------------------------------

    // Yes, these two mux groups repeat eachother, but they can optionally
    // select in opposition, which gives us the triadic result and it's
    // complement. This is useful for Double Move.

    wire [WORD_WIDTH-1:0] selected_dyadic_1_raw;

    Bitwise_2to1_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    SD1
    (
        .select_mask     (selected_R),
        .in1             (D1_out),
        .in2             (D2_out), 
        .out             (selected_dyadic_1_raw)
    );

    reg [WORD_WIDTH-1:0] selected_dyadic_1 = 0;

    always @(posedge clock) begin
        selected_dyadic_1 <= selected_dyadic_1_raw;
    end
    
// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] selected_R_inverted;

    Inverter
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    Triadic_Mode
    (
        .invert (triadic_dual[1]),
        .in     (selected_R),
        .out    (selected_R_inverted)
    );

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] selected_dyadic_2_raw;

    Bitwise_2to1_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    SD2
    (
        .select_mask     (selected_R_inverted),
        .in1             (D1_out),
        .in2             (D2_out), 
        .out             (selected_dyadic_2_raw)
    );

    reg [WORD_WIDTH-1:0] selected_dyadic_2 = 0;

    always @(posedge clock) begin
        selected_dyadic_2 <= selected_dyadic_2_raw;
    end
    
// --------------------------------------------------------------------

    // Stage 2: combine triadic result with sum, carry triadic result along

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] D3_raw;

    Dyadic_Boolean_Operator
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    D3
    (
        .op             (dyadic_3[2]),
        .a              (selected_dyadic_2),
        .b              (sum),
        .o              (D3_raw)
    );

    reg [WORD_WIDTH-1:0] D3_out = 0;

    always @(posedge clock) begin
        D3_out <= D3_raw;
    end
    
// --------------------------------------------------------------------

    reg [WORD_WIDTH-1:0] selected_dyadic_1_2 = 0;

    always @(posedge clock) begin
        selected_dyadic_1_2 <= selected_dyadic_1;
    end
    
// --------------------------------------------------------------------

    // Stage 3: do shift and split

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] D3_shifted;

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (SHIFT_SELECTOR_CTRL_WIDTH),
        .INPUT_COUNT    (SHIFT_SELECTOR_INPUT_COUNT)
    )
    Shift
    (
        .addr           (shift_selector[3]),    
        .in             ({D3_out << 1, $signed(D3_out) >>> 1, $unsigned(D3_out) >>> 1, D3_out}),
        .out            (D3_shifted)
    );

    always @(posedge clock) begin
        Rb <= D3_shifted;
    end

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] selected_dyadic_1_3;

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (SPLIT_SELECTOR_CTRL_WIDTH),
        .INPUT_COUNT    (SPLIT_SELECTOR_INPUT_COUNT)
    )
    Split
    (
        .addr           (split_selector[3]),    
        .in             ({D3_shifted, selected_dyadic_1_2}),
        .out            (selected_dyadic_1_3)
    );

    always @(posedge clock) begin
        Ra <= selected_dyadic_1_3;
    end
    
// --------------------------------------------------------------------

endmodule

