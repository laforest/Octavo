
// Selects the data input for the given read/write port address.

module IO_Read
#(
    parameter   A_WORD_WIDTH                                    = 0,
    parameter   B_WORD_WIDTH                                    = 0,

    parameter   A_ADDR_WIDTH                                    = 0,
    parameter   B_ADDR_WIDTH                                    = 0,

    parameter   A_READ_PORT_COUNT                               = 0,
    parameter   A_READ_PORT_BASE_ADDR                           = 0,
    parameter   A_READ_PORT_ADDR_WIDTH                          = 0,

    parameter   B_READ_PORT_COUNT                               = 0,
    parameter   B_READ_PORT_BASE_ADDR                           = 0,
    parameter   B_READ_PORT_ADDR_WIDTH                          = 0
)
(
    input   wire                                                clock,

    input   wire    [A_ADDR_WIDTH-1:0]                          A_read_addr,
    input   wire    [B_ADDR_WIDTH-1:0]                          B_read_addr,

    input   wire    [(A_READ_PORT_COUNT * A_WORD_WIDTH)-1:0]    A_read_data_in, 
    input   wire    [(B_READ_PORT_COUNT * B_WORD_WIDTH)-1:0]    B_read_data_in, 

    output  wire    [A_WORD_WIDTH-1:0]                          A_read_data_selected,
    output  wire    [B_WORD_WIDTH-1:0                           B_read_data_selected,
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
        .WORD_WIDTH     (A_WORD_WIDTH),
        .ADDR_WIDTH     (A_READ_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (A_READ_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    A_read_data_Selector
    (
        .clock          (clock),
        .addr           (A_read_addr_translated),
        .data_in        (A_read_data),
        .data_out       (A_read_data_selected)
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
        .WORD_WIDTH     (B_WORD_WIDTH),
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
endmodule

