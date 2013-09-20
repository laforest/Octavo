
// Selects I/O Empty/Full bits, generates I/O enables, decodes addresses, and
// maps I/O ports onto memory writes.

module IO_Write
#(
    parameter   WORD_WIDTH                              = 0,
    parameter   ADDR_WIDTH                              = 0,
    parameter   ALU_WORD_WIDTH                          = 0,
    parameter   D_OPERAND_WIDTH                         = 0,
    parameter   WRITE_PORT_COUNT                        = 0,
    parameter   WRITE_PORT_BASE_ADDR                    = 0,
    parameter   WRITE_PORT_ADDR_WIDTH                   = 0
)
(
    input   wire                                        clock,
    input   wire    [ADDR_WIDTH-1:0]                    addr_1,     // From raw instruction (Stage 1)
    input   wire    [WRITE_PORT_COUNT-1:0]              EmptyFull,
    input   wire                                        IO_ready,
    input   wire    [ALU_WORD_WIDTH-1:0]                ALU_result,
    input   wire    [D_OPERAND_WIDTH-1:0]               ALU_addr,
    input   wire                                        ALU_write_is_IO, // Carried around pipeline

    output  reg                                         write_is_IO
    output  wire                                        EmptyFull_masked,
    output  wire    [PORT_COUNT-1:0]                    active_IO,
    output  reg     [(PORT_COUNT * WORD_WIDTH)-1:0]     data_IO,
    output  reg     [WORD_WIDTH-1:0]                    data_RAM,
    output  reg     [D_OPERAND_WIDTH-1:0]               addr_RAM
);

    wire addr_is_IO_reg;

    IO_Check
    #(
        .READY_STATE        (`EMPTY)
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (WRITE_PORT_COUNT),
        .PORT_BASE_ADDR     (WRITE_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (WRITE_PORT_ADDR_WIDTH)
    )
    Write
    (
        .clock              (clock),
        .addr               (addr_1),
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
    end

    // ECL Done this way to explicitly replicate registers, rather than just
    // fanout a single register. Quartus does not reliably replicate as-needed,
    // but it will de-duplicate heartily.

    always @(posedge clock) begin
        data_IO <= {WRITE_PORT_COUNT{ALU_result}};
    end

    IO_Active
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (WRITE_PORT_COUNT),
        .PORT_BASE_ADDR     (WRITE_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (WRITE_PORT_ADDR_WIDTH)
    )
    Write
    (
        .clock              (clock),
        .is_IO              (ALU_write_is_IO),
        .addr               (ALU_addr),
        .active             (active_IO)
    );
endmodule
