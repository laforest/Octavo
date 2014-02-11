
// Contains the default PC offset for each thread, enabling shared code.

module Default_Offset
#(
    parameter   WORD_WIDTH              = 0,
    parameter   ADDR_WIDTH              = 0,
    parameter   DEPTH                   = 0,
    parameter   RAMSTYLE                = 0,
    parameter   INIT_FILE               = 0
)
(
    input   wire                        clock,
    input   wire                        wren,
    input   wire    [ADDR_WIDTH-1:0]    write_thread,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_thread,
    output  wire    [WORD_WIDTH-1:0]    offset
);

    wire    [WORD_WIDTH-1:0]    offset_raw;

    RAM_SDP_no_fw
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    Default_Offset
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (write_thread),
        .write_data         (write_data),
        .read_addr          (read_thread),
        .read_data          (offset_raw)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (WORD_WIDTH)
    )
    default_offset_pipeline
    (
        .clock  (clock),
        .in     (offset_raw),
        .out    (offset)
    );
endmodule
