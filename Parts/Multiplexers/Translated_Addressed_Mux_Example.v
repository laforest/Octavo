
`default_nettype none

module Translated_Addressed_Mux_Example
#(
    parameter       WORD_WIDTH          = 36,
    parameter       ADDR_WIDTH          = 11,
    parameter       INPUT_COUNT         = 8,
    parameter       INPUT_BASE_ADDR     = 123,
    parameter       INPUT_ADDR_WIDTH    = 3,  // clog2(INPUT_COUNT)

    parameter       TOTAL_WIDTH = INPUT_COUNT * WORD_WIDTH
)
(
    input   wire    [ADDR_WIDTH-1:0]    addr,
    input   wire    [TOTAL_WIDTH-1:0]   in, 
    output  wire    [WORD_WIDTH-1:0]    out
);

    Translated_Addressed_Mux
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .INPUT_COUNT        (INPUT_COUNT),
        .INPUT_BASE_ADDR    (INPUT_BASE_ADDR),
        .INPUT_ADDR_WIDTH   (INPUT_ADDR_WIDTH)
    )
    Example
    (
        .addr               (addr),
        .in                 (in), 
        .out                (out)
    );

endmodule

