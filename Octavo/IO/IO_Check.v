
// Common module to IO_Read and Io_Write
// Detects when an address refers to an I/O port and
// outputs its Empty/Full bit, masked if not an I/O port.

module IO_Check
#(
    parameter   READY_STATE             = `FULL,
    parameter   ADDR_WIDTH              = 0,
    parameter   PORT_COUNT              = 0,
    parameter   PORT_BASE_ADDR          = 0,
    parameter   PORT_ADDR_WIDTH         = 0
)
(
    input   wire                        clock,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    input   wire    [PORT_COUNT-1:0]    port_EF,
    output  wire                        port_EF_masked,
    output  wire                        addr_is_IO,
    output  reg                         addr_is_IO_reg
);
    wire    port_EF_selected;
    
    Translated_Addressed_Mux
    #(
        .WORD_WIDTH         (1),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .INPUT_COUNT        (PORT_COUNT),
        .INPUT_BASE_ADDR    (PORT_BASE_ADDR),
        .INPUT_ADDR_WIDTH   (PORT_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    EmptyFull
    (
        .clock              (clock),
        .addr               (addr),
        .data_in            (port_EF), 
        .data_out           (port_EF_selected)
    );

    Address_Decoder
    #(
        .ADDR_COUNT     (PORT_COUNT), 
        .ADDR_BASE      (PORT_BASE_ADDR),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .REGISTERED     (`TRUE)
    )
    is_IO
    (
        .clock          (clock),
        .addr           (addr),
        .hit            (addr_is_IO)   
    );

    always @(posedge clock) begin
        addr_is_IO_reg <= addr_is_IO;
    end

    // Masks the Empty/Full bit with the appropriate READY_STATE if not an I/O
    // address (`EMPTY for writes, `FULL for reads), since memory is always
    // "ready".

    Addressed_Mux
    #(
        .WORD_WIDTH         (1),
        .ADDR_WIDTH         (1),
        .INPUT_COUNT        (2),
        .REGISTERED         (`FALSE)
    )
    IO_EF_Mask
    (
        .clock              (clock),
        .addr               (addr_is_IO),
        .data_in            ({port_EF_selected, READY_STATE}), 
        .data_out           (port_EF_masked)
    );
endmodule

