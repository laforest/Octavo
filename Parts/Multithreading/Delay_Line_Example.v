`default_nettype none

module Delay_Line_Example
#(
    parameter       DEPTH           = 5,
    parameter       WIDTH           = 42
)
(
    input   wire                    clock,
    input   wire    [WIDTH-1:0]     in,
    output  reg     [WIDTH-1:0]     out
);

    Delay_Line
    #(
        .DEPTH  (DEPTH),
        .WIDTH  (WIDTH)
    )
    Example
    (
        .clock  (clock),
        .in     (in),
        .out    (out)
    );

endmodule

