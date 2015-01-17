
module Add_Reducer_test_bench
#(
    parameter       WORD_WIDTH                = 36,
    parameter       ADDENDS                   = 8 // ECL XXX hardcoded, don't touch
)
(
    output  wire    [WORD_WIDTH-1:0]       reduction
);
    integer     cycle;
    reg         clock;
    reg     [(ADDENDS * WORD_WIDTH)-1:0] addends;
    integer i;

    initial begin
        $dumpfile("Add_Reducer_test_bench.vcd");
        $dumpvars;
        cycle       = 0;
        clock       = 0;
        for (i = 0; i < ADDENDS; i = i + 1) begin
            addends[(i * WORD_WIDTH) +: WORD_WIDTH] = 0;
        end
        `DELAY_CLOCK_CYCLES(200) $finish;
    end

    always begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin

        // reduction: 1
        `DELAY_CLOCK_CYCLES(10)
        for (i = 0; i < ADDENDS; i = i + 1) begin
            addends[(i * WORD_WIDTH) +: WORD_WIDTH] <= 0;
        end

        // reduction: 8
        `DELAY_CLOCK_CYCLES(10)
        for (i = 0; i < ADDENDS; i = i + 1) begin
            addends[(i * WORD_WIDTH) +: WORD_WIDTH] <= 1;
        end

        // reduction: 28
        `DELAY_CLOCK_CYCLES(10)
        for (i = 0; i < ADDENDS; i = i + 1) begin
            addends[(i * WORD_WIDTH) +: WORD_WIDTH] <= i;
        end

        // reduction: 36
        `DELAY_CLOCK_CYCLES(10)
        for (i = 0; i < ADDENDS; i = i + 1) begin
            addends[(i * WORD_WIDTH) +: WORD_WIDTH] <= i+1;
        end

    end

    Add_Reducer
    #(
        .WORD_WIDTH (WORD_WIDTH)
        // .ADDENDS    (ADDENDS) // ECL XXX hardcoded, don't touch
    )
    DUT
    (
        .clock      (clock),
        .addends    (addends),
        .reduction  (reduction)
    );

endmodule

