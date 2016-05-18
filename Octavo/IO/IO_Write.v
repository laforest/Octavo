
// Selects I/O Empty/Full bits, generates I/O enables, decodes addresses, and
// maps I/O ports onto memory writes.

module IO_Write
#(
    parameter   WORD_WIDTH                                      = 0,
    parameter   ADDR_WIDTH                                      = 0,
    parameter   RAM_ADDR_WIDTH                                  = 0,
    parameter   IO_WRITE_PORT_COUNT                             = 0,
    parameter   IO_WRITE_PORT_BASE_ADDR                         = 0,
    parameter   IO_WRITE_PORT_ADDR_WIDTH                        = 0
)
(
    input   wire                                                clock,
    input   wire    [ADDR_WIDTH-1:0]                            addr_raw,     // From raw instruction (Stage 1)
    input   wire    [IO_WRITE_PORT_COUNT-1:0]                   EmptyFull,
    input   wire                                                IO_ready,
    input   wire    [WORD_WIDTH-1:0]                            ALU_result,
    input   wire    [ADDR_WIDTH-1:0]                            ALU_addr,
    input   wire                                                ALU_write_is_IO,
    input   wire                                                ALU_wren,

    output  wire                                                write_is_IO,    // Carried around pipeline, through ALU
    output  wire                                                EmptyFull_masked,
    output  wire    [IO_WRITE_PORT_COUNT-1:0]                   active_IO,
    output  wire    [(IO_WRITE_PORT_COUNT * WORD_WIDTH)-1:0]    data_IO,
    output  wire    [WORD_WIDTH-1:0]                            data_RAM,
    output  wire    [RAM_ADDR_WIDTH-1:0]                        addr_RAM,
    output  wire                                                wren_RAM
);

// -----------------------------------------------------------

    wire addr_is_IO_reg;

    IO_Check
    #(
        .READY_STATE        (`EMPTY),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (IO_WRITE_PORT_COUNT),
        .PORT_BASE_ADDR     (IO_WRITE_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (IO_WRITE_PORT_ADDR_WIDTH)
    )
    Write_IO_Check
    (
        .clock              (clock),
        .addr               (addr_raw),
        .port_EF            (EmptyFull),
        .port_EF_masked     (EmptyFull_masked),
        .addr_is_IO         (),
        .addr_is_IO_reg     (addr_is_IO_reg)
    );

// -----------------------------------------------------------

    // Carry it along the pipeline up to the entrance of the ALU.
    // It will then carry along the ALU to eventually return.

    delay_line 
    #(
        .DEPTH  (2),
        .WIDTH  (1)
    ) 
    write_is_IO_pipeline
    (
        .clock  (clock),
        .in     (addr_is_IO_reg & IO_ready),
        .out    (write_is_IO)
    );

// -----------------------------------------------------------

    delay_line 
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    ) 
    data_RAM_pipeline
    (
        .clock  (clock),
        .in     (ALU_result),
        .out    (data_RAM)
    );

// -----------------------------------------------------------

    delay_line 
    #(
        .DEPTH  (1),
        .WIDTH  (RAM_ADDR_WIDTH)
    ) 
    addr_RAM_pipeline
    (
        .clock  (clock),
        .in     (ALU_addr[RAM_ADDR_WIDTH-1:0]),
        .out    (addr_RAM)
    );

// -----------------------------------------------------------

    delay_line 
    #(
        .DEPTH  (1),
        .WIDTH  (1)
    ) 
    wren_RAM_pipeline
    (
        .clock  (clock),
        .in     (ALU_wren),
        .out    (wren_RAM)
    );

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]    data_IO_internal;

    delay_line 
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    ) 
    data_IO_pipeline
    (
        .clock  (clock),
        .in     (ALU_result),
        .out    (data_IO_internal)
    );

// -----------------------------------------------------------

    wire    [IO_WRITE_PORT_COUNT-1:0]   active_IO_internal;

    IO_Active
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (IO_WRITE_PORT_COUNT),
        .PORT_BASE_ADDR     (IO_WRITE_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (IO_WRITE_PORT_ADDR_WIDTH)
    )
    Write
    (
        .clock              (clock),
        .enable             (ALU_write_is_IO & ALU_wren),
        .addr               (ALU_addr),
        .active             (active_IO_internal)
    );

// -----------------------------------------------------------

    // Update only enabled (adress-decoded) register

    Enabled_Registers 
    #(
        .COUNT  (IO_WRITE_PORT_COUNT), 
        .WIDTH  (WORD_WIDTH)
    ) 
    IO_write_port
    (
        .clock  (clock),
        .enable (active_IO_internal),
        .in     ({IO_WRITE_PORT_COUNT{data_IO_internal}}),
        .out    (data_IO)
    );

// -----------------------------------------------------------

    // Only 1 stage to match 2 stages of data_IO_pipeline
    // Both assure IO data exits at the same time as a RAM data write
    // So the same tread aligns to IO read and write.

    delay_line 
    #(
        .DEPTH  (1),
        .WIDTH  (IO_WRITE_PORT_COUNT)
    ) 
    active_IO_pipeline
    (
        .clock  (clock),
        .in     (active_IO_internal),
        .out    (active_IO)
    );


endmodule

