
`default_nettype none

module One_Hot_Mux_Example
#(
    parameter       WORD_WIDTH          = 32,
    parameter       WORD_COUNT          = 7,

    parameter   TOTAL_WIDTH = WORD_COUNT * WORD_WIDTH
)
(
    input   wire    [WORD_COUNT-1:0]    selectors,
    input   wire    [TOTAL_WIDTH-1:0]   in,
    output  wire    [WORD_WIDTH-1:0]    out
);

    One_Hot_Mux
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .WORD_COUNT (WORD_COUNT)
    )
    Example
    (
        .selectors  (selectors),
        .in         (in),
        .out        (out)
    );

endmodule

