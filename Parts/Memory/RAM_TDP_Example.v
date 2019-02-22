
`default_nettype none

module RAM_TDP_Example
#(
    parameter       WORD_WIDTH          = 36,
    parameter       ADDR_WIDTH          = 12,
    parameter       DEPTH               = 4096,
    parameter       RAMSTYLE            = "M10K",
    parameter       READ_NEW_DATA       = 0,
    parameter       USE_INIT_FILE       = 0,
    parameter       INIT_FILE           = ""
)
(
    input  wire                         clock,

    input  wire                         wren_A,
    input  wire     [ADDR_WIDTH-1:0]    addr_A,
    input  wire     [WORD_WIDTH-1:0]    write_data_A,
    output reg      [WORD_WIDTH-1:0]    read_data_A,

    input  wire                         wren_B,
    input  wire     [ADDR_WIDTH-1:0]    addr_B,
    input  wire     [WORD_WIDTH-1:0]    write_data_B,
    output reg      [WORD_WIDTH-1:0]    read_data_B
);

    RAM_TDP 
    #(
        .WORD_WIDTH     (WORD_WIDTH), 
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DEPTH          (DEPTH),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        .USE_INIT_FILE  (USE_INIT_FILE),
        .INIT_FILE      (INIT_FILE)
    )
    Example
    (
        .clock          (clock),

        .wren_A         (wren_A),
        .addr_A         (addr_A),
        .write_data_A   (write_data_A),
        .read_data_A    (read_data_A),

        .wren_B         (wren_B),
        .addr_B         (addr_B),
        .write_data_B   (write_data_B),
        .read_data_B    (read_data_B)
    );

endmodule

