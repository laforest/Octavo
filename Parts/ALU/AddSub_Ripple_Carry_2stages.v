
// Generates a 2-stage pipelines Ripple-Carry Adder-Subtractor for any *even*
// word-width. For most cases, 2 pipeline stages suffice to reach
// a high-enough Fmax to not be a bottleneck.

// The CAD tool should re-time registers as needed to map to the actual
// carry-chain logic on the device.

`default_nettype none

module AddSub_Ripple_Carry_2stages
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

// --------------------------------------------------------------------

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

    wire                        carry_out_lower;
    wire    [HALF_WIDTH-1:0]    sum_lower;

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (HALF_WIDTH)
    )
    addsub_lower
    (
        .sub_add        (sub_add),
        .carry_in       (carry_in),
        .A              (A_lower_half),
        .B              (B_lower_half),
        .carry_out      (carry_out_lower),
        .sum            (sum_lower)
    );

    reg                         carry_out_lower_reg = 1'b0;
    reg     [HALF_WIDTH-1:0]    sum_lower_reg       = ZERO_HALF;
    reg                         sub_add_upper       = 1'b0;
    reg     [HALF_WIDTH-1:0]    A_upper             = ZERO_HALF;
    reg     [HALF_WIDTH-1:0]    B_upper             = ZERO_HALF;

    always @(posedge clock) begin
        carry_out_lower_reg <= carry_out_lower;
        sum_lower_reg       <= sum_lower;
        sub_add_upper       <= sub_add;
        A_upper             <= A_upper_half;
        B_upper             <= B_upper_half;
    end

// --------------------------------------------------------------------

    wire                        carry_out_upper;
    wire    [HALF_WIDTH-1:0]    sum_upper;

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (HALF_WIDTH)
    )
    addsub_upper
    (
        .sub_add        (sub_add_upper),
        .carry_in       (carry_out_lower_reg),
        .A              (A_upper),
        .B              (B_upper),
        .carry_out      (carry_out_upper),
        .sum            (sum_upper)
    );

    reg                       carry_out_upper_reg   = 1'b0;
    reg     [HALF_WIDTH-1:0]  sum_upper_reg         = ZERO_HALF;
    reg     [HALF_WIDTH-1:0]  sum_lower_reg_1       = ZERO_HALF;    

    always @(posedge clock) begin
        carry_out_upper_reg <= carry_out_upper;
        sum_upper_reg       <= sum_upper;
        sum_lower_reg_1     <= sum_lower_reg;
    end

// --------------------------------------------------------------------

    always @(*) begin
        carry_out   = carry_out_upper_reg;
        sum         = {sum_upper_reg, sum_lower_reg_1};
    end
endmodule

