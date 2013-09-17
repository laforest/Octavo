
// Selects I/O Empty/Full bits, generates I/O enables, decodes addresses,
// generates an "I/O Ready" signal used later to predicate instructions,
// and maps I/O ports onto memory reads.

module IO_Read
#(
    parameter   WORD_WIDTH                                  = 0,
    parameter   ADDR_WIDTH                                  = 0,
    parameter   READ_PORT_COUNT                             = 0,
    parameter   READ_PORT_BASE_ADDR                         = 0,
    parameter   READ_PORT_ADDR_WIDTH                        = 0
)
(
    input   wire                                            clock,
    input   wire    [ADDR_WIDTH-1:0]                        read_addr,
    input   wire    [READ_PORT_COUNT-1:0]                   read_EF,
    input   wire                                            other_port_EF,
    input   wire    [(READ_PORT_COUNT * WORD_WIDTH)-1:0]    read_data_IO,
    input   wire    [WORD_WIDTH-1:0]                        read_data_RAM,

    output  wire                                            read_EF_masked,
    output  wire                                            IO_ready,
    output  wire    [WORD_WIDTH-1:0]                        read_data_out
);
    wire read_EF_selected;

    IO_EmptyFull
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (READ_PORT_COUNT),
        .PORT_BASE_ADDR     (READ_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (READ_PORT_ADDR_WIDTH)
    )
    Read_Port_EF_Selector
    (
        .clock              (clock),
        .port_EF            (read_EF), 
        .port_addr          (read_addr),
        .port_EF_selected   (read_EF_selected)
    );

    wire read_is_IO;

    Address_Decoder
    #(
        .ADDR_COUNT (READ_PORT_COUNT),
        .ADDR_BASE  (READ_PORT_BASE_ADDR),
        .ADDR_WIDTH (READ_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    Read_IO_Detect
    (
        .clock      (clock),
        .addr       (read_addr),
        .hit        (read_is_IO)
    );

    IO_Ready
    #(
        .READY_STATE    (`FULL),
        .REGISTERED     (`TRUE)
    )
    Read
    (
        .clock          (clock),
        .addr_is_IO     (read_is_IO),
        .port_EF        (read_EF_selected),
        .other_port_EF  (other_port_EF),
        .port_EF_masked (read_EF_masked),
        .port_IO_ready  (IO_ready)
    );

endmodule

