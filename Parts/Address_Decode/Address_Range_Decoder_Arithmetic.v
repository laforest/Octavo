
// A *universal* address decoder. Works for any address range at any starting point.

// Checks if the address lies between the base and (higher, inclusive) bound of a range.

// This version uses arithmetic checks and thus should scale to wide addresses
// without reaching limits in the CAD tool.

// Making the base and bound constant will optimize the hardware down to plain
// logic. It's not as optimal as the Static version, but OK.

`default_nettype none

module Address_Range_Decoder_Arithmetic
#(
    parameter       ADDR_WIDTH          = 0
)
(
    input   wire    [ADDR_WIDTH-1:0]    base_addr,
    input   wire    [ADDR_WIDTH-1:0]    bound_addr,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    output  reg                         hit 
);

    reg base_or_higher;
    reg bound_or_lower;

    always @(*) begin
        base_or_higher = (addr >= base_addr);
        bound_or_lower = (addr <= bound_addr);
        hit            = (base_or_higher && bound_or_lower);
    end

endmodule

