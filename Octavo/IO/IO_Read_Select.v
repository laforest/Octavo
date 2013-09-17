
// Selects the data input for the given read port address.

module IO_Read_Select
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
    input   wire    [(READ_PORT_COUNT * WORD_WIDTH)-1:0]    read_data_in, 
    output  wire    [WORD_WIDTH-1:0]                        read_data_selected,
);
    wire [READ_PORT_ADDR_WIDTH-1:0] read_addr_translated;

    Address_Translator 
    #(
        .ADDR_COUNT             (READ_PORT_COUNT),
        .ADDR_BASE              (READ_PORT_BASE_ADDR),
        .ADDR_WIDTH             (READ_PORT_ADDR_WIDTH),
        .REGISTERED             (`FALSE)
    )
    read_addr
    (
        .clock                  (clock),
        .raw_address            (read_addr[READ_PORT_ADDR_WIDTH-1:0]),
        .translated_address     (read_addr_translated)
    );         

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (READ_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (READ_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    read_data
    (
        .clock          (clock),
        .addr           (read_addr_translated),
        .data_in        (read_data),
        .data_out       (read_data_selected)
    );
endmodule

