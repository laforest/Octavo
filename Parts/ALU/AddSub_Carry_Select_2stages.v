
// A Carry-Select adder/subtractor can reach a higher speed in fewer stages
// than a Ripple-Carry equivalent. However, by default Quartus mangles the
// design back into a (bad) Ripple-Carry circuit. The "keep" directives are an
// attempt to portably preserve the three individual sub-adders.

// Two pipeline stages suffice to reach a very, very high speed.
// This is only useful in designs where you want to exceed the speed of
// a Block RAM, and you don't want to create a 4-stage Rippler-Carry adder.

// WORD_WIDTH must be an *even* number.

`default_nettype none

module AddSub_Carry_Select_2stages
#(
    parameter               WORD_WIDTH          = 0
)
(
    input   wire                                clock,
	input   wire                                sub_add, // 1/0 -> A-B/A+B
	input   wire                                carry_in,
	input   wire    signed  [WORD_WIDTH-1:0]    A,
	input   wire    signed  [WORD_WIDTH-1:0]    B,
	output  reg     signed  [WORD_WIDTH-1:0]    sum,
	output  reg                                 carry_out
);

// --------------------------------------------------------------------------

    localparam HALF_WIDTH   = WORD_WIDTH / 2;
    localparam ZERO         = {WORD_WIDTH{1'b0}};
    localparam ZERO_HALF    = {HALF_WIDTH{1'b0}};

    initial begin
        sum         = ZERO;
        carry_out   = 1'b0;
    end

// --------------------------------------------------------------------------

    reg [HALF_WIDTH-1:0] A_lower_half = ZERO_HALF;
    reg [HALF_WIDTH-1:0] A_upper_half = ZERO_HALF;
    reg [HALF_WIDTH-1:0] B_lower_half = ZERO_HALF;
    reg [HALF_WIDTH-1:0] B_upper_half = ZERO_HALF;

    always @(*) begin
        A_lower_half = A[HALF_WIDTH-1:0];
        A_upper_half = A[WORD_WIDTH-1:HALF_WIDTH];
        B_lower_half = B[HALF_WIDTH-1:0];
        B_upper_half = B[WORD_WIDTH-1:HALF_WIDTH];
    end

// --------------------------------------------------------------------

    wire                        carry_out_lower;    /* synthesis keep */
    wire    [HALF_WIDTH-1:0]    sum_lower;          /* synthesis keep */

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (HALF_WIDTH)
    )
    alu_lower
    (
        .sub_add        (sub_add),
        .carry_in       (carry_in),
        .A              (A_lower_half),
        .B              (B_lower_half),
        .carry_out      (carry_out_lower),
        .sum            (sum_lower)
    );

    reg                         carry_out_lower_reg;
    reg     [HALF_WIDTH-1:0]    sum_lower_reg;

    always @(posedge clock) begin
        carry_out_lower_reg <=  carry_out_lower;
        sum_lower_reg       <=  sum_lower;
    end

// --------------------------------------------------------------------

    wire                        carry_out_upper_0;  /* synthesis keep */
    wire    [HALF_WIDTH-1:0]    sum_upper_0;        /* synthesis keep */

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (HALF_WIDTH)
    )
    alu_upper_0
    (
        .sub_add        (sub_add),
        .carry_in       (1'b0),
        .A              (A_upper_half),
        .B              (B_upper_half),
        .carry_out      (carry_out_upper_0),
        .sum            (sum_upper_0)
    );

    reg                         carry_out_upper_0_reg;
    reg     [HALF_WIDTH-1:0]    sum_upper_0_reg;

    always @(posedge clock) begin
        carry_out_upper_0_reg   <=  carry_out_upper_0;
        sum_upper_0_reg         <=  sum_upper_0;
    end

// --------------------------------------------------------------------

    wire                        carry_out_upper_1;  /* synthesis keep */
    wire    [HALF_WIDTH-1:0]    sum_upper_1;        /* synthesis keep */

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (HALF_WIDTH)
    )
    alu_upper_1
    (
        .sub_add        (sub_add),
        .carry_in       (1'b1),
        .A              (A_upper_half),
        .B              (B_upper_half),
        .carry_out      (carry_out_upper_1),
        .sum            (sum_upper_1)
    );

    reg                         carry_out_upper_1_reg;
    reg     [HALF_WIDTH-1:0]    sum_upper_1_reg;

    always @(posedge clock) begin
        carry_out_upper_1_reg   <=  carry_out_upper_1;
        sum_upper_1_reg         <=  sum_upper_1;
    end

// --------------------------------------------------------------------

    always @(posedge clock) begin
        carry_out   <= (carry_out_lower_reg == 1'b1) ? carry_out_upper_1_reg            : carry_out_upper_0_reg;
        sum         <= (carry_out_lower_reg == 1'b1) ? {sum_upper_1_reg, sum_lower_reg} : {sum_upper_0_reg, sum_lower_reg};
    end

endmodule

