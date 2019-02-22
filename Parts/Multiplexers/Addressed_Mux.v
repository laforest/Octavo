
// Generic multiplexer
// Pass a concatenation to "in" with the zeroth element on the right.

`default_nettype none

module Addressed_Mux
#(
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       INPUT_COUNT         = 0,

    // Not for instantiation
    parameter   TOTAL_WIDTH = WORD_WIDTH * INPUT_COUNT
)
(
    input   wire    [ADDR_WIDTH-1:0]    addr,    
    input   wire    [TOTAL_WIDTH-1:0]   in,
    output  reg     [WORD_WIDTH-1:0]    out
);

    always @(*) begin
        out = in[(addr * WORD_WIDTH) +: WORD_WIDTH];
    end

endmodule

