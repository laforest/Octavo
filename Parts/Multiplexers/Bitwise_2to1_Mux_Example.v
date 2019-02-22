
`default_nettype none

module Bitwise_2to1_Mux_Example
#(
    parameter WORD_WIDTH = 36
)
(
    input   wire    [WORD_WIDTH-1:0]    select_mask,
    input   wire    [WORD_WIDTH-1:0]    in1,
    input   wire    [WORD_WIDTH-1:0]    in2,
    output  wire    [WORD_WIDTH-1:0]    out
);

    Bitwise_2to1_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    Example
    (
        .select_mask    (select_mask),
        .in1            (in1),
        .in2            (in2),
        .out            (out)
    );

endmodule

