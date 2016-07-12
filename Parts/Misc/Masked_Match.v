
// Checks if the input matches the target value, 
// with masking to exclude bits from match.

// Set mask to 0 to exclude a bit from the match.

module Masked_Match
#(
    parameter WORD_WIDTH = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    in,
    input   wire    [WORD_WIDTH-1:0]    target, 
    input   wire    [WORD_WIDTH-1:0]    mask,
    output  reg                         match
);

    reg [WORD_WIDTH-1:0] raw_match;

    always @(*) begin
        raw_match = ~(in ^ target) & mask;
        match     = | raw_match;
    end

endmodule

