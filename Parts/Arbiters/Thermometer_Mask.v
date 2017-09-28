
// Takes a bit vector and returns a mask
// which masks-off all bits less significant
// than the least significant set bit.  

// Does allow an all-zero vector as a special case,
// where the mask ends up all-one.

// Used to mask-off arbiter requests of higher priority
// to the current grant, where the LSB has highest priority.

// Core logic from Hacker's Delight

`default_nettype none

module Thermometer_Mask
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    bitvector,
    output  reg     [WORD_WIDTH-1:0]    mask
);

    localparam zero = {WORD_WIDTH{1'b0}};

    always @(*) begin
        // Outputs 1 at the first set bit and all trailing (less significant) bits.
        // Outputs 0 at all more significant bits.
        // All 1's if no bit set.
        mask = bitvector ^ (bitvector - 1);
        // Invert mask to instead mask-off the set bit and the trailing bits
        // Don't invert mask if no bit set (don't want an all-zero mask)
        mask = (bitvector == zero) ? mask : ~mask;
        // Re-add set bit, so it and leading (more significant) bits pass through.
        mask = mask | bitvector;
    end

endmodule

