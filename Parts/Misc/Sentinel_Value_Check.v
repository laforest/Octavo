
// Checks if the input matches the sentinel value, 
// with masking to exclude bits from match.

// Set a mask bit to 0 to exclude a bit from the comparison.
// (by forcing both the input and sentinel bit to zero, thus matching.)
// Thus, an all-zero mask will cause a match to always be found.
// And an all-one mask will cause a comparison to be exact.

module Sentinel_Value_Check
#(
    parameter WORD_WIDTH = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    in,
    input   wire    [WORD_WIDTH-1:0]    sentinel, 
    input   wire    [WORD_WIDTH-1:0]    mask,
    output  reg                         match
);

    reg [WORD_WIDTH-1:0] raw_match;
    reg [WORD_WIDTH-1:0] masked_in;
    reg [WORD_WIDTH-1:0] masked_sentinel;

    always @(*) begin
        masked_in       = in       & mask;
        masked_sentinel = sentinel & mask;
        raw_match       = ~(masked_in ^ masked_sentinel);
        match           = & raw_match;
    end

endmodule

