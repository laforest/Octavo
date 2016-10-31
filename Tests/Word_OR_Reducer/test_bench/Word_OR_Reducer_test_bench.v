
module Word_OR_Reducer_test_bench
#(
    parameter       WORD_WIDTH          = 36,
    parameter       WORD_COUNT          = 4
)
(
);

// --------------------------------------------------------------------

    integer                                 cycle;
    reg                                     clock;

    reg     [(WORD_WIDTH*WORD_COUNT)-1:0]   dut_in;
    wire    [WORD_WIDTH-1:0]                dut_out;

    initial begin
        cycle       = 0;
        clock       = 0;
        dut_in      = {36'h400000000,36'h200000000,36'h100000000,36'hFFFFFFFFF};
        `DELAY_CLOCK_CYCLES(32) $finish;
    end

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin
        dut_in = dut_in + 'd1; 
    end

// --------------------------------------------------------------------

    Word_OR_Reducer
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .WORD_COUNT (WORD_COUNT)
    )
    DUT
    (
        .in         (dut_in),
        .out        (dut_out)
    );

endmodule

