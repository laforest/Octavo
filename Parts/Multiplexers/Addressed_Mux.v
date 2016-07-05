
// Generic multiplexer
// Concatenate in with the zeroth element on the right.

module Addressed_Mux
#(
    parameter       WORD_WIDTH                          = 0,
    parameter       ADDR_WIDTH                          = 0,
    parameter       INPUT_COUNT                         = 0
)
(
    input   wire    [ADDR_WIDTH-1:0]                    addr,    
    input   wire    [(WORD_WIDTH * INPUT_COUNT)-1:0]    in,
    output  reg     [WORD_WIDTH-1:0]                    out
);
    always @(*) begin
        out <= in[(addr * WORD_WIDTH) +: WORD_WIDTH];
    end
endmodule

