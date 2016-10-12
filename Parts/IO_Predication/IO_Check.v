
// Common module to IO_Read and IO_Write
// (IO_Active sits in a different place for each)

// Detects if an address refers to an I/O port and outputs its Empty/Full bit,
// masked if not an I/O port.

module IO_Check
#(
    parameter   READY_STATE             = 0,
    parameter   ADDR_WIDTH              = 0,
    parameter   PORT_COUNT              = 0,
    parameter   PORT_BASE_ADDR          = 0,
    parameter   PORT_ADDR_WIDTH         = 0
)
(
    input   wire                        clock,
    input   wire                        enable,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    input   wire    [PORT_COUNT-1:0]    port_EF,
    output  reg                         port_EF_masked,
    output  reg                         addr_is_IO
);
// --------------------------------------------------------------------

    initial begin
        port_EF_masked = 0;
        addr_is_IO     = 0;
    end

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 1

    wire    port_EF_selected_raw;
    
    Translated_Addressed_Mux
    #(
        .WORD_WIDTH         (1),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .INPUT_COUNT        (PORT_COUNT),
        .INPUT_BASE_ADDR    (PORT_BASE_ADDR),
        .INPUT_ADDR_WIDTH   (PORT_ADDR_WIDTH)
    )
    EF_Select
    (
        .addr               (addr),
        .in                 (port_EF), 
        .out                (port_EF_selected_raw)
    );

    reg     port_EF_selected = 0;

    always @(posedge clock) begin
        port_EF_selected <= port_EF_selected_raw;
    end

// --------------------------------------------------------------------

    localparam PORT_BOUND_ADDR = PORT_BASE_ADDR + PORT_COUNT - 1;

    wire addr_is_IO_raw;
    
    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH     (ADDR_WIDTH),
        .ADDR_BASE      (PORT_BASE_ADDR),
        .ADDR_BOUND     (PORT_BOUND_ADDR) 
    )
    IO_Detect
    (
        .enable         (enable),
        .addr           (addr),
        .hit            (addr_is_IO_raw)   
    );

    always @(posedge clock) begin
        addr_is_IO <= addr_is_IO_raw;
    end

// --------------------------------------------------------------------

    reg enable_stage2 = 0;

    always @(posedge clock) begin
        enable_stage2 <= enable;
    end

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 2

    // Masks the Empty/Full bit with the appropriate READY_STATE if not an I/O
    // address (EMPTY (0) for writes, FULL (1) for reads), since memory is
    // always "ready".

    always @(*) begin
        port_EF_masked <= (addr_is_IO == 1) ? port_EF_selected : READY_STATE;
    end

endmodule

