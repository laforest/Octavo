
module Triadic_ALU_test_bench
#(
    parameter       WORD_WIDTH          = 36
)
(
);

// --------------------------------------------------------------------

    integer                             cycle;
    reg                                 clock;
    reg     [`TRIADIC_CTRL_WIDTH-1:0]   control;
    reg     [WORD_WIDTH-1:0]            A;
    reg     [WORD_WIDTH-1:0]            B;
    wire    [WORD_WIDTH-1:0]            R;
    wire                                R_zero;
    wire                                R_negative;
    reg     [WORD_WIDTH-1:0]            S;
    wire    [WORD_WIDTH-1:0]            Ra;
    wire    [WORD_WIDTH-1:0]            Rb;
    wire                                carry_out;
    wire                                overflow;
    

    initial begin
        //$dumpfile("Triadic_ALU_test_bench.vcd");
        //$dumpvars(0);
        cycle   = 0;
        clock   = 0;
        control = `ALU_NOP;
        A       = 36'h8FFFFFFFF;
        B       = 36'hF00000000;
        S       = 36'hFFFFFFFFF;
        `DELAY_CLOCK_CYCLES(32) $finish;
    end

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin
        control <= `ALU_NOP;
        `DELAY_CLOCK_CYCLES(1);
        control <= `ALU_A_PLUS_B;
        `DELAY_CLOCK_CYCLES(1);
        control <= `ALU_DMOV;
        `DELAY_CLOCK_CYCLES(1);
    end

// --------------------------------------------------------------------

    // Loop Ra back to R, after 4 cycles.
    // So every 8th instruction can see it's previous result
    // Split to allow putting logic in the middle.

    wire [WORD_WIDTH-1:0] R_pipe_1;

    Delay_Line 
    #(
        .DEPTH  (2), 
        .WIDTH  (WORD_WIDTH)
    ) 
    R_pipeline_1
    (
        .clock  (clock),
        .in     (Ra),
        .out    (R_pipe_1)
    );
 
    Delay_Line 
    #(
        .DEPTH  (2), 
        .WIDTH  (WORD_WIDTH)
    ) 
    R_pipeline_2
    (
        .clock  (clock),
        .in     (R_pipe_1),
        .out    (R)
    );
 
// --------------------------------------------------------------------

    // Place in R pipeline middle to retime zero/negative flag calculations

    wire R_zero_raw;
    wire R_negative_raw;

    R_Flags
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    R_Flags
    (
        .R          (R_pipe_1),
        .R_zero     (R_zero_raw),
        .R_negative (R_negative_raw)
    );

    Delay_Line 
    #(
        .DEPTH  (2), 
        .WIDTH  (1)
    ) 
    R_zero_pipeline
    (
        .clock  (clock),
        .in     (R_zero_raw),
        .out    (R_zero)
    );
 
    Delay_Line 
    #(
        .DEPTH  (2), 
        .WIDTH  (1)
    ) 
    R_negative_pipeline
    (
        .clock  (clock),
        .in     (R_negative_raw),
        .out    (R_negative)
    );
 
// --------------------------------------------------------------------

    Triadic_ALU
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    DUT
    (
        .clock      (clock),
        .control    (control), // Bits defining various sub-operations
        .A          (A),       // First source argument
        .B          (B),       // Second source argument
        .R          (R),       // Third source argument  (previous result)
        .R_zero     (R_zero),
        .R_negative (R_negative),
        .S          (S),       // Fourth source argument (persistent value)
        .Ra         (Ra),      // First result
        .Rb         (Rb),      // Second result
        .carry_out  (carry_out),
        .overflow   (overflow)
    );

endmodule

