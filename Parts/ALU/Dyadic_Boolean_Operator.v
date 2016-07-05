
// Based on control input, implements one of the 16 possible two-variable
// (dyadic) Boolean operators, as o = a op b.

// Include Dyadic_Boolean_Operations.vh as necessary.

module Dyadic_Boolean_Operator
#(
    parameter WORD_WIDTH = 0
)
(
    input   wire    [3:0]               op,
    input   wire    [WORD_WIDTH-1:0]    a,
    input   wire    [WORD_WIDTH-1:0]    b,
    output  wire    [WORD_WIDTH-1:0]    o
);

    // One mux per bit, where the inputs select the op bits.

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (2),
        .INPUT_COUNT    (4)
    )
    Operator            [WORD_WIDTH-1:0]
    (
        .addr           ({a,b}),    
        .in             (op),
        .out            (o)
    );

endmodule

