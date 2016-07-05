
module Accumulator_test_bench
#(
    parameter       WORD_WIDTH          = 36,
    parameter       THREAD_COUNT        = 8
)
(
    output  wire    [WORD_WIDTH-1:0]    total
);
    integer                     cycle;
    reg                         clock;
    reg     [WORD_WIDTH-1:0]    addend;
    reg                         read_total;
    reg                         write_addend;

    initial begin
        $dumpfile("Accumulator_test_bench.vcd");
        $dumpvars(0);
        cycle           = 0;
        clock           = 0;
        addend          = 0;
        read_total      = 0;
        write_addend    = 0;
        `DELAY_CLOCK_CYCLES(200) $finish;
    end

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin

        // 0 + 1 = 1, read out
        read_total      = `HIGH;
        write_addend    = `HIGH;
        addend          = 1; 
        `DELAY_CLOCK_CYCLES(1)
        read_total      = `LOW;
        write_addend    = `LOW;
        `DELAY_CLOCK_CYCLES((THREAD_COUNT-1))

        // 0 + 1 + 2 = 3
        read_total      = `LOW;
        write_addend    = `HIGH;
        addend          = 2; 
        `DELAY_CLOCK_CYCLES(1)
        write_addend    <= `LOW;
        `DELAY_CLOCK_CYCLES((THREAD_COUNT-1))

        // 0 + 1 + 2 + 3 = 6
        read_total      = `LOW;
        write_addend    = `HIGH;
        addend          = 3; 
        `DELAY_CLOCK_CYCLES(1)
        write_addend    <= `LOW;
        `DELAY_CLOCK_CYCLES((THREAD_COUNT-1))

        // 0 + 1 + 2 + 3 + 4 = 10
        read_total      = `LOW;
        write_addend    = `HIGH;
        addend          = 4; 
        `DELAY_CLOCK_CYCLES(1)
        write_addend    = `LOW;
        `DELAY_CLOCK_CYCLES((THREAD_COUNT-1))

        // avoids syntax error
        read_total      = `HIGH;

    end

    Accumulator
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .THREAD_COUNT   (THREAD_COUNT)
    )
    DUT
    (
        .clock          (clock),
        .write_addend   (write_addend),
        .addend         (addend),
        .read_total     (read_total),
        .total          (total)
    );

endmodule

