
// Creates a simple serial pipelined link from I/O output to I/O input
// Encapsulates a lot of redundancy.

module simple_link
#(
    parameter       WIDTH           = 0,
    parameter       DEPTH           = 0
)
(
    input   wire                    clock,
    input   wire    [WIDTH-1:0]     in,
    input   wire                    wren,
    output  wire    [WIDTH-1:0]     out
);

    wire    [WIDTH-1:0]     or_out;

    output_register
    #(
        .WIDTH  (WIDTH)
    )
    sl_or
    (
        .clock  (clock),
        .in     (in),
        .wren   (wren),
        .out    (or_out)
    );

    delay_line
    #(
        .WIDTH  (WIDTH),
        .DEPTH  (DEPTH)
    )
    sl_dl
    (
        .clock  (clock),
        .in     (or_out),
        .out    (out)
    );

endmodule

