
// Generates the "active" signal for each I/O port, based on the address of
// the selected I/O port, if enabled also.

// This is the read or write enable (rden or wren)

module IO_Active
#(
    parameter   ADDR_WIDTH              = 0,
    parameter   PORT_COUNT              = 0,
    parameter   PORT_BASE_ADDR          = 0,
    parameter   PORT_ADDR_WIDTH         = 0
)
(
    input   wire                        enable,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    output  wire    [PORT_COUNT-1:0]    active
);

// --------------------------------------------------------------------

    wire [PORT_ADDR_WIDTH-1:0] addr_translated;

    Address_Range_Translator 
    #(
        .ADDR_COUNT             (PORT_COUNT),
        .ADDR_BASE              (PORT_BASE_ADDR),
        .ADDR_WIDTH             (PORT_ADDR_WIDTH),
        .REGISTERED             (0)
    )
    IO_Port
    (
        .clock                  (1'b0),
        .raw_address            (addr[PORT_ADDR_WIDTH-1:0]),
        .translated_address     (addr_translated)
    );         

// --------------------------------------------------------------------

    wire [PORT_COUNT-1:0] active_raw;

    Binary_to_N_Decoder
    #(
        .BINARY_WIDTH   (PORT_ADDR_WIDTH),
        .OUTPUT_WIDTH   (PORT_COUNT)
    )
    Port_Active
    (
        .in             (addr_translated),
        .out            (active_raw)
    );

// --------------------------------------------------------------------

    Annuller
    #(
        .WORD_WIDTH (PORT_COUNT)
    )
    active_enable
    (
        .annul      (~enable),
        .in         (active_raw),
        .out        (active)
    );


endmodule

