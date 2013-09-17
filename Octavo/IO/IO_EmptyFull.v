
// Selects the Empty/Full bit for the given port address.

// We check the E/F bits of write ports here, even though we only do the
// write much later, so we can annul I/O and instruction side-effects
// before they happen.

module IO_EmptyFull
#(
    parameter   ADDR_WIDTH              = 0,
    parameter   PORT_COUNT              = 0,
    parameter   PORT_BASE_ADDR          = 0,
    parameter   PORT_ADDR_WIDTH         = 0,
)
(
    input   wire                        clock,
    input   wire    [PORT_COUNT-1:0]    port_EF, 
    input   wire    [ADDR_WIDTH-1:0]    port_addr,
    output  wire                        port_EF_selected
);

    wire [PORT_ADDR_WIDTH-1:0]  port_addr_translated;

    Address_Translator 
    #(
        .ADDR_COUNT             (PORT_COUNT),
        .ADDR_BASE              (PORT_BASE_ADDR),
        .ADDR_WIDTH             (PORT_ADDR_WIDTH),
        .REGISTERED             (`FALSE)
    )
    port_addr_Translator
    (
        .clock                  (clock),
        .raw_address            (port_addr[PORT_ADDR_WIDTH-1:0]),
        .translated_address     (port_addr_translated)
    );         

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (PORT_ADDR_WIDTH),
        .INPUT_COUNT    (PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    port_EF_Selector
    (
        .clock          (clock),
        .addr           (port_addr_translated),
        .data_in        (port_EF),
        .data_out       (port_EF_selected)
    );
endmodule

