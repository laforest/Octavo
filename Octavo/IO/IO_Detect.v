
// Checks if read/write addresses refer to I/O ports

module IO_Detect
#(
    parameter   A_ADDR_WIDTH                    = 0,
    parameter   B_ADDR_WIDTH                    = 0,
    parameter   D_ADDR_WIDTH                    = 0,

    parameter   A_READ_PORT_COUNT               = 0,
    parameter   A_READ_PORT_BASE_ADDR           = 0,
    parameter   A_READ_PORT_ADDR_WIDTH          = 0,

    parameter   A_WRITE_PORT_COUNT              = 0,
    parameter   A_WRITE_PORT_BASE_ADDR          = 0,
    parameter   A_WRITE_PORT_ADDR_WIDTH         = 0,

    parameter   B_READ_PORT_COUNT               = 0,
    parameter   B_READ_PORT_BASE_ADDR           = 0,
    parameter   B_READ_PORT_ADDR_WIDTH          = 0,

    parameter   B_WRITE_PORT_COUNT              = 0,
    parameter   B_WRITE_PORT_BASE_ADDR          = 0,
    parameter   B_WRITE_PORT_ADDR_WIDTH         = 0
)
(
    input   wire                                clock,

    input   wire    [A_ADDR_WIDTH-1:0]          A_read_addr,
    input   wire    [B_ADDR_WIDTH-1:0]          B_read_addr,
    input   wire    [D_ADDR_WIDTH-1:0]          D_write_addr,

    output  wire                                A_read_is_IO,
    output  wire                                A_write_is_IO,

    output  wire                                B_read_is_IO,
    output  wire                                B_write_is_IO
);
    Address_Decoder
    #(
        .ADDR_COUNT (A_READ_PORT_COUNT),
        .ADDR_BASE  (A_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH (A_READ_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    A_read_decoder
    (
        .clock      (clock),
        .addr       (A_read_addr),
        .hit        (A_read_is_IO)
    );
    
    Address_Decoder
    #(
        .ADDR_COUNT (B_READ_PORT_COUNT),
        .ADDR_BASE  (B_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH (B_READ_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    B_read_decoder
    (
        .clock      (clock),
        .addr       (B_read_addr),
        .hit        (B_read_is_IO)
    );
    
    // Both A and B ports share a common write address and data.
    // The writes will duplicate to both if their port address 
    // ranges overlap.

    Address_Decoder
    #(
        .ADDR_COUNT (A_WRITE_PORT_COUNT),
        .ADDR_BASE  (A_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH (A_WRITE_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    A_write_decoder
    (
        .clock      (clock),
        .addr       (D_write_addr),
        .hit        (A_write_is_IO)
    );
    
    Address_Decoder
    #(
        .ADDR_COUNT (B_WRITE_PORT_COUNT),
        .ADDR_BASE  (B_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH (B_WRITE_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    B_write_decoder
    (
        .clock      (clock),
        .addr       (D_write_addr),
        .hit        (B_write_is_IO)
    );
endmodule

