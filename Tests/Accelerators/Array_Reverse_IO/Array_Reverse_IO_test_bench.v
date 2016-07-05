
module Array_Reverse_IO_test_bench
#(
    parameter       WORD_WIDTH          = 36,
    parameter       LANE_COUNT          = 8,
    parameter       THREAD_COUNT        = 8
)
(
    // This line left intentionally blank.
);
    integer                                     cycle;
    reg                                         clock;
    reg     [(LANE_COUNT * WORD_WIDTH)-1:0]     original;
    wire    [(LANE_COUNT * WORD_WIDTH)-1:0]     reversed;

    initial begin
        //$dumpfile("Array_Reverse_IO_test_bench.vcd");
        //$dumpvars();
        cycle           = 0;
        clock           = 0;
        original        = 1;
        `DELAY_CLOCK_CYCLES(1000) $finish;
    end

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin
        // Should see the bit travel in lane-wise reverse order at output
        original <= original << 1;
    end

    Array_Reverse_IO
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .LANE_COUNT     (LANE_COUNT),
        .THREAD_COUNT   (THREAD_COUNT)
    )
    DUT
    (
        .clock          (clock),
        .in             (original),
        .out            (reversed)
    );

endmodule

