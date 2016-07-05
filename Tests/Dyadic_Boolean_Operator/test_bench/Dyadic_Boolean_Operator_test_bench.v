
module Dyadic_Boolean_Operator_test_bench
#(
    parameter       WORD_WIDTH          = 36
)
(
);
    localparam OP_WIDTH = 4;

    integer                     cycle;
    reg                         clock;
    reg     [OP_WIDTH-1:0]      op;
    reg     [WORD_WIDTH-1:0]    a;
    reg     [WORD_WIDTH-1:0]    b;
    wire    [WORD_WIDTH-1:0]    o;

    initial begin
        $dumpfile("Dyadic_Boolean_Operator_test_bench.vcd");
        //$dumpvars(0);
        cycle   = 0;
        clock   = 0;
        op      = 0;
        a       = 36'h100F0500A;
        b       = 36'h100F050A0;
        `DELAY_CLOCK_CYCLES(32) $finish;
    end

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin
        // Test all 16 ops. Refer to Dyadic_Boolean_Operations.vh for meaning.
        op = op + 4'd1;
        `DELAY_CLOCK_CYCLES(1);
    end

    Dyadic_Boolean_Operator
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    DUT
    (
        .op             (op),
        .a              (a),
        .b              (b),
        .o              (o)
    );

endmodule

