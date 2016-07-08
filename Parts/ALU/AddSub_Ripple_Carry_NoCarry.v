
// Adder/subtractor without carry-in/out. 
// This allows us to compute +/-A+/-B.
// Should infer to the usual LUT and carry-chain logic.

// Also generates addition-specific predicates for later comparisons

module AddSub_Ripple_Carry_NoCarry
#(
    parameter               WORD_WIDTH          = 0
)
(
    input   wire    signed  [WORD_WIDTH-1:0]    A,
    input   wire                                A_negative,
    input   wire    signed  [WORD_WIDTH-1:0]    B,
    input   wire                                B_negative,
    output  reg     signed  [WORD_WIDTH-1:0]    sum,
    output  reg                                 carry_out,
    output  reg                                 overflow
);

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] A_signed;
    wire [WORD_WIDTH-1:0] B_signed;

    Inverter
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    A_inv
    (
        .invert     (A_negative),
        .in         (A),
        .out        (A_signed)
    );

    Inverter
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    B_inv
    (
        .invert     (B_negative),
        .in         (B),
        .out        (B_signed)
    );

    // -X = (~X)+1

    always @(*) begin
        {carry_out,sum} <= A_signed + B_signed + A_negative + B_negative;
    end

// --------------------------------------------------------------------
// Find carry-in into MSB

    wire carry_in;

    Carryin_Calculator
    #(
        .WORD_WIDTH (1)
    )
    MSB_Cin
    (
        .A          (A_signed[WORD_WIDTH-1]),
        .B          (B_signed[WORD_WIDTH-1]),
        .S          (sum     [WORD_WIDTH-1]),
        .Cin        (carry_in)
    );

// --------------------------------------------------------------------

    always @(*) begin
        overflow = carry_in ^ carry_out; // signed overflow
    end

endmodule

