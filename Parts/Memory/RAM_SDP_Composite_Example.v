
`default_nettype none

module RAM_SDP_Composite_Example
#(
    parameter       WORD_WIDTH          = 36,
    parameter       ADDR_WIDTH          = 12,
    parameter       DEPTH               = 4096,
    parameter       RAMSTYLE            = "M10K",
    parameter       READ_NEW_DATA       = 0,
    parameter       USE_INIT_FILE       = 0,
    // Parameters for the individual sub-RAMs
    parameter       SUB_INIT_FILE       = "",
    parameter       SUB_ADDR_WIDTH      = 6,
    parameter       SUB_DEPTH           = 64
)
(
    input  wire                         clock,
    input  wire                         wren,
    input  wire     [ADDR_WIDTH-1:0]    write_addr,
    input  wire     [WORD_WIDTH-1:0]    write_data,
    input  wire                         rden,
    input  wire     [ADDR_WIDTH-1:0]    read_addr, 
    output reg      [WORD_WIDTH-1:0]    read_data
);

    RAM_SDP_Composite 
    #(
        .WORD_WIDTH     (WORD_WIDTH), 
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DEPTH          (DEPTH),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        .USE_INIT_FILE  (USE_INIT_FILE),
        .SUB_INIT_FILE  (SUB_INIT_FILE),
        .SUB_ADDR_WIDTH (SUB_ADDR_WIDTH),
        .SUB_DEPTH      (SUB_DEPTH)
    )
    Example
    (
        .clock          (clock),
        .wren           (wren),
        .write_addr     (write_addr),
        .write_data     (write_data),
        .rden           (rden),
        .read_addr      (read_addr),
        .read_data      (read_data)
    );

endmodule

