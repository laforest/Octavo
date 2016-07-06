
module Triadic_ALU_test_bench
#(
    parameter       WORD_WIDTH          = 36
)
(
);

    localparam CTRL_WIDTH = 20; // Static!

// --------------------------------------------------------------------

    integer                     cycle;
    reg                         clock;
    reg     [CTRL_WIDTH-1:0]    control;
    reg     [WORD_WIDTH-1:0]    A;
    reg     [WORD_WIDTH-1:0]    B;
    reg     [WORD_WIDTH-1:0]    R;
    reg     [WORD_WIDTH-1:0]    S;
    wire    [WORD_WIDTH-1:0]    Ra;
    wire    [WORD_WIDTH-1:0]    Rb;
    

    initial begin
        $dumpfile("Triadic_ALU_test_bench.vcd");
        //$dumpvars(0);
        cycle   = 0;
        clock   = 0;
        control = `ALU_NOP;
        A       = 36'h42;
        B       = 36'h24;
        R       = 36'h1;
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
        .S          (S),       // Fourth source argument (persistent value)
        .Ra         (Ra),      // First result
        .Rb         (Rb)       // Second result
    );

endmodule

