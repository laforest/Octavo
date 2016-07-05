
// Simple adder/subtractor. 
// Computes A+B or A-B
// Should infer to the usual LUT and carry-chain logic.

module AddSub_Ripple_Carry
#(
    parameter               WORD_WIDTH          = 0
)
(
    input   wire                                add_sub,
    input   wire                                cin,
    input   wire    signed  [WORD_WIDTH-1:0]    dataa,
    input   wire    signed  [WORD_WIDTH-1:0]    datab,
    output  reg                                 cout,
    output  reg     signed  [WORD_WIDTH-1:0]    result
);
    always @(*) begin
        {cout, result} <= (add_sub == 1'b1) ? dataa + datab + cin : dataa - datab - cin;
    end
endmodule

