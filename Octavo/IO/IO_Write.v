
// Selects I/O Empty/Full bits, generates I/O enables, decodes addresses, and
// maps I/O ports onto memory writes.

module IO_Write
#(
    parameter   WORD_WIDTH                                      = 0,
    parameter   ADDR_WIDTH                                      = 0,
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

    output  reg                                                 write_is_IO,    // Carried around pipeline, through ALU
    output  wire                                                EmptyFull_masked,
    output  wire    [IO_WRITE_PORT_COUNT-1:0]                   active_IO,
    output  reg     [(IO_WRITE_PORT_COUNT * WORD_WIDTH)-1:0]    data_IO,
    output  reg     [WORD_WIDTH-1:0]                            data_RAM,
    output  reg     [ADDR_WIDTH-1:0]                            addr_RAM,
    output  reg                                                 wren_RAM
);

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

    // Carry it along the pipeline up to the entrance of the ALU.
    // It will then carry along the ALU to eventually return.

    reg write_is_IO_internal;
    always @(posedge clock) begin
        write_is_IO_internal <= addr_is_IO_reg & IO_ready;
        write_is_IO          <= write_is_IO_internal;
    end

    always @(posedge clock) begin
        data_RAM <= ALU_result;
        addr_RAM <= ALU_addr;
        wren_RAM <= ALU_wren;
    end

    // ECL Done this way to explicitly replicate registers, rather than just
    // fanout a single register. Quartus does not reliably replicate as-needed,
    // but it will de-duplicate heartily.

    always @(posedge clock) begin
        data_IO <= {IO_WRITE_PORT_COUNT{ALU_result}};
    end

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
        .active             (active_IO)
    );

    initial begin
        write_is_IO_internal    = 0;
        write_is_IO             = 0;
        data_IO                 = 0;
        data_RAM                = 0;
        addr_RAM                = 0;
        wren_RAM                = 0;
    end

endmodule

