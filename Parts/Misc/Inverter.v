
// Inverts a value (bitwise NOT if enabled)

// We put something this simple into a module since it conveys intent,
// and avoids an RTL schematic cluttered with a bunch of XOR gates.

`default_nettype none

module Inverter
#(
    parameter       WORD_WIDTH         = 0
)
(
    input   wire                       invert,
    input   wire    [WORD_WIDTH-1:0]   in,
    output  reg     [WORD_WIDTH-1:0]   out
);

    always @(*) begin
        out = (invert == 1'b1) ? ~in : in;
    end

endmodule

