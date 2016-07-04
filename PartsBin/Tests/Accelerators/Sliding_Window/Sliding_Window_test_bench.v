
module Sliding_Window_test_bench
#(
    parameter       WORD_WIDTH              = 36,
    parameter       LANES                   = 8 // ECL XXX hardcoded, don't touch
)
(
    output  wire    [(WORD_WIDTH * LANES)-1:0] read_data
);
    integer     cycle;
    reg         clock;
    reg         in_write;
    reg         out_read;
    reg     [(WORD_WIDTH * LANES)-1:0] write_data;
    integer i;

    initial begin
        $dumpfile("Sliding_Window_test_bench.vcd");
        $dumpvars;
        cycle       = 0;
        clock       = 0;
        in_write    = 0;
        out_read    = 0;
        for (i = 0; i < LANES; i = i + 1) begin
            write_data[(i * WORD_WIDTH) +: WORD_WIDTH] = 0;
        end
        `DELAY_CLOCK_CYCLES(2000) $finish;
    end

    always begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin

        // Load some data
        `DELAY_CLOCK_CYCLES(10)
        in_write = `HIGH;
        out_read = `LOW;
        for (i = 0; i < LANES; i = i + 1) begin
            write_data[(i * WORD_WIDTH) +: WORD_WIDTH] <= i*2;
        end
        `DELAY_CLOCK_CYCLES(1)
        in_write = `LOW;
        out_read = `LOW;

        // Now let's read them out
        `DELAY_CLOCK_CYCLES(10)
        in_write = `LOW;
        out_read = `HIGH;

        // Load some data just as the previous one exhausts.
        `DELAY_CLOCK_CYCLES(7)
        in_write = `HIGH;
        out_read = `HIGH;
        for (i = 0; i < LANES; i = i + 1) begin
            write_data[(i * WORD_WIDTH) +: WORD_WIDTH] <= i*3;
        end
        `DELAY_CLOCK_CYCLES(1)
        in_write = `LOW;
        out_read = `HIGH;

        // Now let's read them all out
        `DELAY_CLOCK_CYCLES(20)
        in_write = `LOW;
        out_read = `HIGH;

    end

    Sliding_Window
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .LANES      (LANES)
    )
    DUT
    (
        .clock      (clock),
        .in_write   (in_write),
        .in         (write_data),
        .out_read   (out_read),
        .out        (read_data)
    );

endmodule

