
// Simple adder/subtractor. 
// Computes A+B or A-B
// Should infer to the usual LUT and carry-chain logic.

`default_nettype none

module AddSub_Ripple_Carry
#(
    parameter               WORD_WIDTH          = 0
)
(
    input   wire                                sub_add,    // 1/0 A-B/A+B
    input   wire                                carry_in,
    input   wire    signed  [WORD_WIDTH-1:0]    A,
    input   wire    signed  [WORD_WIDTH-1:0]    B,
    output  reg     signed  [WORD_WIDTH-1:0]    sum,
    output  reg                                 carry_out
);
    always @(*) begin
        {carry_out, sum} <= (sub_add == 1'b1) ? A - B - carry_in : A + B + carry_in;
    end
endmodule

