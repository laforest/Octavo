
// Checks if ALL the input bits match the sentinel value, 
// with masking to exclude bits from match.

// Set a mask bit to 1 to exclude a bit from the comparison.
// (by forcing both the input and sentinel bit to zero, thus matching.)
// Thus, an all-one mask will cause a match to always be found.
// And an all-zero mask will cause a comparison to be exact.
// (which will be the default behaviour at start)

// The sentinel masking logic was pulled up to the enclosing logic
// to allow for retiming.

`default_nettype none

module Sentinel_Value_Check
#(
    parameter       WORD_WIDTH          = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    data_in,
    input   wire    [WORD_WIDTH-1:0]    sentinel_masked, 
    input   wire    [WORD_WIDTH-1:0]    mask,
    output  reg                         match
);

// --------------------------------------------------------------------------

    localparam ZERO = {WORD_WIDTH{1'b0}};

    initial begin
        match = 1'b0;
    end

    reg [WORD_WIDTH-1:0] data_in_masked = ZERO;

    always @(*) begin
        data_in_masked  = data_in & ~mask;
        match           = (data_in_masked == sentinel_masked);
    end

endmodule

