
// Adder/subtractor without carry-in/out. 
// This allows us to compute +/-A+/-B.
// Should infer to the usual LUT and carry-chain logic.

module AddSub_Ripple_Carry_NoCarry
#(
    parameter               WORD_WIDTH          = 0
)
(
    input   wire    signed  [WORD_WIDTH-1:0]    A,
    input   wire                                A_negative,
    input   wire    signed  [WORD_WIDTH-1:0]    B,
    input   wire                                B_negative,
    output  reg     signed  [WORD_WIDTH-1:0]    sum
);
    always @(*) begin
        sum <= (A ^ {WORD_WIDTH{A_negative}}) + (B ^ {WORD_WIDTH{B_negative}}) + A_negative + B_negative;
    end
endmodule

