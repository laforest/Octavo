
// Selects I/O Empty/Full bits, generates I/O enables, decodes addresses,
// generates an "I/O Ready" signal used later to predicate instructions,
// and maps I/O ports onto memory read/writes.

module IO
#(
    parameter   A_WORD_WIDTH                                    = 0,
    parameter   B_WORD_WIDTH                                    = 0,
    parameter   ALU_WORD_WIDTH                                  = 0,

    parameter   A_ADDR_WIDTH                                    = 0,
    parameter   B_ADDR_WIDTH                                    = 0,
    parameter   D_ADDR_WIDTH                                    = 0,

    parameter   A_READ_PORT_COUNT                               = 0,
    parameter   A_READ_PORT_BASE_ADDR                           = 0,
    parameter   A_READ_PORT_ADDR_WIDTH                          = 0,

    parameter   A_WRITE_PORT_COUNT                              = 0,
    parameter   A_WRITE_PORT_BASE_ADDR                          = 0,
    parameter   A_WRITE_PORT_ADDR_WIDTH                         = 0,

    parameter   B_READ_PORT_COUNT                               = 0,
    parameter   B_READ_PORT_BASE_ADDR                           = 0,
    parameter   B_READ_PORT_ADDR_WIDTH                          = 0,

    parameter   B_WRITE_PORT_COUNT                              = 0,
    parameter   B_WRITE_PORT_BASE_ADDR                          = 0,
    parameter   B_WRITE_PORT_ADDR_WIDTH                         = 0
)
(
    input   wire                                                clock,

    input   wire    [A_ADDR_WIDTH-1:0]                          A_read_addr,
    input   wire    [B_ADDR_WIDTH-1:0]                          B_read_addr,
    input   wire    [D_ADDR_WIDTH-1:0]                          D_write_addr,

    input   wire    [A_READ_PORT_COUNT-1:0]                     A_read_EF,
    input   wire    [A_WRITE_PORT_COUNT-1:0]                    A_write_EF,
    input   wire    [B_READ_PORT_COUNT-1:0]                     B_read_EF,
    input   wire    [B_WRITE_PORT_COUNT-1:0]                    B_write_EF,

    input   wire    [(A_READ_PORT_COUNT  * A_WORD_WIDTH)-1:0]   A_read_data_IO,
    input   wire    [(B_READ_PORT_COUNT  * B_WORD_WIDTH)-1:0]   B_read_data_IO,

    input   wire    [A_WORD_WIDTH-1:0]                          A_read_data_RAM,
    input   wire    [B_WORD_WIDTH-1:0]                          B_read_data_RAM,

    input   wire    [ALU_WORD_WIDTH-1:0]                        D_write_data,

    output  wire    [(A_WRITE_PORT_COUNT * A_WORD_WIDTH)-1:0]   A_write_data_IO,
    output  wire    [(B_WRITE_PORT_COUNT * B_WORD_WIDTH)-1:0]   B_write_data_IO,
);

endmodule

