
// Contains the new PC for taken parallel branches.
// The D operand used to provide this value. (but it won't exist anymore)

module Branch_Destination
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
    output  wire    [WORD_WIDTH-1:0]    branch_destination
);
    wire    [WORD_WIDTH-1:0]    branch_destination_raw;

    RAM_SDP_no_fw
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    New_PC_Memory
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (write_addr),
        .write_data         (write_data),
        .read_addr          (read_addr),
        .read_data          (branch_destination_raw)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (WORD_WIDTH)
    )
    NPC_pipeline
    (
        .clock  (clock),
        .in     (branch_destination_raw),
        .out    (branch_destination)
    );

endmodule

