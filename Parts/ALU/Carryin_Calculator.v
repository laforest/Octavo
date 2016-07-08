
// Infers carry-in to each bit position given both addends A/B and their sum S.

module Carryin_Calculator
#(
    parameter WORD_WIDTH = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    A,
    input   wire    [WORD_WIDTH-1:0]    B,
    input   wire    [WORD_WIDTH-1:0]    S,
    output  reg     [WORD_WIDTH-1:0]    Cin
);

    initial begin
        Cin = 0;
    end

    always @(*) begin
        Cin = A ^ B ^ S;
    end

endmodule

