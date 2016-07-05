
// Generates the "active" signal for each I/O port

module IO_Active
#(
    parameter   ADDR_WIDTH              = 0,
    parameter   PORT_COUNT              = 0,
    parameter   PORT_BASE_ADDR          = 0,
    parameter   PORT_ADDR_WIDTH         = 0
)
(
    input   wire                        clock,
    input   wire                        enable,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    output  wire    [PORT_COUNT-1:0]    active
);
    wire [PORT_ADDR_WIDTH-1:0] addr_translated;

    Address_Translator 
    #(
        .ADDR_COUNT             (PORT_COUNT),
        .ADDR_BASE              (PORT_BASE_ADDR),
        .ADDR_WIDTH             (PORT_ADDR_WIDTH),
        .REGISTERED             (`FALSE)
    )
    Address_Translator
    (
        .clock                  (clock),
        .raw_address            (addr[PORT_ADDR_WIDTH-1:0]),
        .translated_address     (addr_translated)
    );         

    Port_Active
    #(
        .PORT_COUNT         (PORT_COUNT),
        .PORT_ADDR_WIDTH    (PORT_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    Port_Active
    (
        .clock              (clock),
        .enable             (enable),
        .port_addr          (addr_translated),
        .active             (active)
    );
endmodule

