
module AddSub_Structural_test_bench
#(
    parameter       WORD_WIDTH          = 36
)
(
);

// --------------------------------------------------------------------

    integer                             cycle;
    reg                                 clock;
    reg                                 sub_add;
    reg                                 carry_in;
    reg     [WORD_WIDTH-1:0]            A;
    reg     [WORD_WIDTH-1:0]            B;
    wire    [WORD_WIDTH-1:0]            sum;
    wire                                carry_out;
    

    initial begin
        $dumpfile("AddSub_Structural_test_bench.vcd");
        //$dumpvars(0);
        cycle       = 0;
        clock       = 0;
        sub_add     = 1'b0;
        carry_in    = 1'b0;
        A           = 36'h000000001;
        B           = 36'hFFFFFFFFF;
        `DELAY_CLOCK_CYCLES(32) $finish;
    end

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin
        `DELAY_CLOCK_CYCLES(1);
        sub_add     = 1'b1;
        `DELAY_CLOCK_CYCLES(1);
        sub_add     = 1'b0;
    end

// --------------------------------------------------------------------

    AddSub_Structural
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    DUT
    (
        .sub_add    (sub_add),
        .carry_in   (carry_in),
        .A          (A),
        .B          (B),
        .sum        (sum),
        .carry_out  (carry_out)
    );

endmodule

