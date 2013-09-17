
// Generates the "active" signal for each I/O read/write port

module IO_Active
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

    input   wire                                A_read_is_IO,
    input   wire                                A_write_is_IO,
    input   wire                                B_read_is_IO,
    input   wire                                B_write_is_IO,

    input   wire    [A_ADDR_WIDTH-1:0]          A_read_addr,
    input   wire    [B_ADDR_WIDTH-1:0]          B_read_addr,
    input   wire    [D_ADDR_WIDTH-1:0]          D_write_addr,

    output  wire    [A_READ_PORT_COUNT-1:0]     A_read,
    output  wire    [A_WRITE_PORT_COUNT-1:0]    A_write,

    output  wire    [B_READ_PORT_COUNT-1:0]     B_read,
    output  wire    [B_WRITE_PORT_COUNT-1:0]    B_write

);
    wire [A_READ_PORT_ADDR_WIDTH-1:0] A_read_addr_translated;

    Address_Translator 
    #(
        .ADDR_COUNT             (A_READ_PORT_COUNT),
        .ADDR_BASE              (A_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH             (A_READ_PORT_ADDR_WIDTH),
        .REGISTERED             (`FALSE)
    )
    A_read_addr_Translator
    (
        .clock                  (clock),
        .raw_address            (A_read_addr[A_READ_PORT_ADDR_WIDTH-1:0]),
        .translated_address     (A_read_addr_translated)
    );         

    Port_Active
    #(
        .PORT_COUNT         (A_READ_PORT_COUNT),
        .PORT_ADDR_WIDTH    (A_READ_PORT_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    A_read_Active
    (
        .clock              (clock),
        .enable             (A_read_is_IO),
        .port_addr          (A_read_addr_translated),
        .active             (A_read)
    );

    wire [B_READ_PORT_ADDR_WIDTH-1:0] B_read_addr_translated;

    Address_Translator 
    #(
        .ADDR_COUNT             (B_READ_PORT_COUNT),
        .ADDR_BASE              (B_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH             (B_READ_PORT_ADDR_WIDTH),
        .REGISTERED             (`FALSE)
    )
    B_read_addr_Translator
    (
        .clock                  (clock),
        .raw_address            (B_read_addr[B_READ_PORT_ADDR_WIDTH-1:0]),
        .translated_address     (B_read_addr_translated)
    );         

    Port_Active
    #(
        .PORT_COUNT         (B_READ_PORT_COUNT),
        .PORT_ADDR_WIDTH    (B_READ_PORT_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    B_read_Active
    (
        .clock              (clock),
        .enable             (B_read_is_IO),
        .port_addr          (B_read_addr_translated),
        .active             (B_read)
    );

    wire [A_WRITE_PORT_ADDR_WIDTH-1:0] A_write_addr_translated;

    Address_Translator 
    #(
        .ADDR_COUNT             (A_WRITE_PORT_COUNT),
        .ADDR_BASE              (A_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH             (A_WRITE_PORT_ADDR_WIDTH),
        .REGISTERED             (`FALSE)
    )
    A_write_addr_Translator
    (
        .clock                  (clock),
        .raw_address            (A_write_addr[A_WRITE_PORT_ADDR_WIDTH-1:0]),
        .translated_address     (A_write_addr_translated)
    );         

    Port_Active
    #(
        .PORT_COUNT         (A_WRITE_PORT_COUNT),
        .PORT_ADDR_WIDTH    (A_WRITE_PORT_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    A_write_Active
    (
        .clock              (clock),
        .enable             (A_write_is_IO),
        .port_addr          (A_write_addr_translated),
        .active             (A_write)
    );

    wire [B_WRITE_PORT_ADDR_WIDTH-1:0] B_write_addr_translated;

    Address_Translator 
    #(
        .ADDR_COUNT             (B_WRITE_PORT_COUNT),
        .ADDR_BASE              (B_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH             (B_WRITE_PORT_ADDR_WIDTH),
        .REGISTERED             (`FALSE)
    )
    B_write_addr_Translator
    (
        .clock                  (clock),
        .raw_address            (B_write_addr[B_WRITE_PORT_ADDR_WIDTH-1:0]),
        .translated_address     (B_write_addr_translated)
    );         

    Port_Active
    #(
        .PORT_COUNT         (B_WRITE_PORT_COUNT),
        .PORT_ADDR_WIDTH    (B_WRITE_PORT_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    B_write_Active
    (
        .clock              (clock),
        .enable             (B_write_is_IO),
        .port_addr          (B_write_addr_translated),
        .active             (B_write)
    );
endmodule
