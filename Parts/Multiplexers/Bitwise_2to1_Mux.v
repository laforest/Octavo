
// Selects each bit from two sources, based on a mask of same size.

`default_nettype none

module Bitwise_2to1_Mux
#(
    parameter WORD_WIDTH = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    select_mask,
    input   wire    [WORD_WIDTH-1:0]    in1,
    input   wire    [WORD_WIDTH-1:0]    in2,
    output  wire    [WORD_WIDTH-1:0]    out
);

    // One mux per bit pair

    generate
        genvar j;
        for(j = 0; j < WORD_WIDTH; j = j+1) begin: per_bit
            Addressed_Mux
            #(
                .WORD_WIDTH     (1),
                .ADDR_WIDTH     (1),
                .INPUT_COUNT    (2)
            )
            Mux
            (
                .addr           (select_mask[j]),    
                .in             ({in2[j],in1[j]}),
                .out            (out[j])
            );
        end
    endgenerate

endmodule

