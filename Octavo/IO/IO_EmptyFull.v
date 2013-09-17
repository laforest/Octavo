
// Selects the Empty/Full bit for the given read/write port address.

// We check the E/F bits of write ports here, even though we only do the
// write much later, so we can annul I/O and instruction side-effects
// before they happen.

module IO_EmptyFull
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

    input   wire    [A_READ_PORT_COUNT-1:0]     A_read_EF, 
    input   wire    [A_WRITE_PORT_COUNT-1:0]    A_write_EF, 

    input   wire    [B_READ_PORT_COUNT-1:0]     B_read_EF, 
    input   wire    [B_WRITE_PORT_COUNT-1:0]    B_write_EF, 

    input   wire    [A_ADDR_WIDTH-1:0]          A_read_addr,
    input   wire    [B_ADDR_WIDTH-1:0]          B_read_addr,
    input   wire    [D_ADDR_WIDTH-1:0]          D_write_addr,

    output  wire                                A_read_EF_selected,
    output  wire                                A_write_EF_selected,

    output  wire                                B_read_EF_selected,
    output  wire                                B_write_EF_selected
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

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (A_READ_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (A_READ_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    A_read_EF_Selector
    (
        .clock          (clock),
        .addr           (A_read_addr_translated),
        .data_in        (A_read_EF),
        .data_out       (A_read_EF_selected)
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

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (B_READ_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (B_READ_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    B_read_EF_Selector
    (
        .clock          (clock),
        .addr           (B_read_addr_translated),
        .data_in        (B_read_EF),
        .data_out       (B_read_EF_selected)
    );

    //
    // A and B share a common write address
    //

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
        .raw_address            (D_write_addr[A_WRITE_PORT_ADDR_WIDTH-1:0]),
        .translated_address     (A_write_addr_translated)
    );         

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (A_WRITE_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (A_WRITE_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    A_write_EF_Selector
    (
        .clock          (clock),
        .addr           (D_write_addr_translated),
        .data_in        (A_write_EF),
        .data_out       (A_write_EF_selected)
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
        .raw_address            (D_write_addr[B_WRITE_PORT_ADDR_WIDTH-1:0]),
        .translated_address     (B_write_addr_translated)
    );         

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (B_WRITE_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (B_WRITE_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    B_write_EF_Selector
    (
        .clock          (clock),
        .addr           (B_write_addr_translated),
        .data_in        (B_write_EF),
        .data_out       (B_write_EF_selected)
    );
endmodule

