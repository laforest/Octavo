
// Contains values to match to the current PC, indicating the locations of potentical parallel branches.

module Match
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
    input   wire    [ADDR_WIDTH-1:0]    write_addr,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_addr,
    output  wire    [WORD_WIDTH-1:0]    match
);
    wire    [WORD_WIDTH-1:0]    match_raw;

    RAM_SDP_no_fw
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    Match_Memory
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (write_addr),
        .write_data         (write_data),
        .read_addr          (read_addr),
        .read_data          (match_raw)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    )
    MM_pipeline
    (
        .clock  (clock),
        .in     (match_raw),
        .out    (match)
    );

endmodule

