
// A half-adder. Used as a building block for more complex extended Boolean
// functions, but without using the carry-chain logic of an FPGA, which will
// be more efficient for small word widths.

`default_nettype none

module Half_Adder
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    A,
    input   wire    [WORD_WIDTH-1:0]    B,
    output  reg     [WORD_WIDTH-1:0]    sum,
    output  reg     [WORD_WIDTH-1:0]    carry_out
);

    always @(*) begin
        sum         <= A ^ B;
        carry_out   <= A & B;   // Per-bit carry-out
    end

endmodule

