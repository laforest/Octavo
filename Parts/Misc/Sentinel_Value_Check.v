
// Checks if the input matches the sentinel value, 
// with masking to exclude bits from match.

// Set mask to 0 to exclude a bit from the match.

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

    always @(*) begin
        raw_match = ~(in ^ sentinel) & mask;
        match     = | raw_match;
    end

endmodule

