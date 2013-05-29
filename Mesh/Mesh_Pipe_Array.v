// A linear array of pipeline stages, with special endpieces.
// All unconnected, all the same depth, except for the endpieces.
// LSB/MID/MSB alludes to the bit ordering of vectors, to distinguish each endpiece, with LSB being 'rightmost'

module Mesh_Pipe_Array
#(
    parameter       LSB_PIPE_DEPTH      = 0,
    parameter       MID_PIPE_DEPTH      = 0,
    parameter       MSB_PIPE_DEPTH      = 0,
    parameter       WIDTH               = 0,
    parameter       PIPE_ARRAY_SIZE     = 0
)
(
    input   wire                                        clock,
    input   wire    [(WIDTH * PIPE_ARRAY_SIZE)-1:0]     in,
    output  wire    [(WIDTH * PIPE_ARRAY_SIZE)-1:0]     out

);
    localparam  LSB_START = 0;
    localparam  LSB_END   = LSB_START + WIDTH  - 1;
    localparam  MID_START = LSB_END   + 1;
    localparam  MID_COUNT = PIPE_ARRAY_SIZE    - 2;
    localparam  MID_END   = MID_START + (WIDTH * MID_COUNT) - 1;
    localparam  MSB_START = MID_END   + 1;
    localparam  MSB_END   = MSB_START + WIDTH  - 1;

    delay_line
    #(  
        .DEPTH  (LSB_PIPE_DEPTH),
        .WIDTH  (WIDTH)
    )
    Mesh_Pipe_LSB 
    (   
        .clock  (clock),
        .in     (in [LSB_END:LSB_START]),
        .out    (out[LSB_END:LSB_START])
    );  

    delay_line
    #(  
        .DEPTH  (MID_PIPE_DEPTH),
        .WIDTH  (WIDTH)
    )
    Mesh_Pipe_MID    [MID_COUNT-1:0] 
    (   
        .clock  (clock),
        .in     (in [MID_END:MID_START]),
        .out    (out[MID_END:MID_START])
    );  

    delay_line
    #(  
        .DEPTH  (MSB_PIPE_DEPTH),
        .WIDTH  (WIDTH)
    )
    Mesh_Pipe_MSB 
    (   
        .clock  (clock),
        .in     (in [MSB_END:MSB_START]),
        .out    (out[MSB_END:MSB_START])
    );  
endmodule

