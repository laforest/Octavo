
// Selects I/O Empty/Full bits, generates I/O enables, decodes addresses, and
// maps I/O ports onto memory reads.

module IO_Read
#(
    parameter   WORD_WIDTH                                  = 0,
    parameter   ADDR_WIDTH                                  = 0,
    parameter   READ_PORT_COUNT                             = 0,
    parameter   READ_PORT_BASE_ADDR                         = 0,
    parameter   READ_PORT_ADDR_WIDTH                        = 0
)
(
    input   wire                                            clock,
    input   wire    [ADDR_WIDTH-1:0]                        addr_1,     // From raw instruction (Stage 1)
    input   wire    [ADDR_WIDTH-1:0]                        addr_3,     // After optional translation (Stage 3)
    input   wire    [READ_PORT_COUNT-1:0]                   EmptyFull,
    input   wire    [(READ_PORT_COUNT * WORD_WIDTH)-1:0]    data_IO,
    input   wire    [WORD_WIDTH-1:0]                        data_RAM,
    input   wire                                            IO_ready,

    output  wire                                            EmptyFull_masked,
    output  wire    [PORT_COUNT-1:0]                        active_IO,
    output  wire    [WORD_WIDTH-1:0]                        data_out
);

    wire addr_is_IO;
    wire addr_is_IO_reg;

    IO_Check
    #(
        .READY_STATE        (`FULL)
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (READ_PORT_COUNT),
        .PORT_BASE_ADDR     (READ_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (READ_PORT_ADDR_WIDTH)
    )
    Read
    (
        .clock              (clock),
        .addr               (addr_1),
        .port_EF            (EmptyFull),
        .port_EF_masked     (EmptyFull_masked),
        .addr_is_IO         (addr_is_IO),
        .addr_is_IO_reg     (addr_is_IO_reg)
    );

    reg addr_1_reg;
    always @(posedge clock) begin
        addr_1_reg <= addr_1;
    end

    wire active_IO_internal;

    IO_Active
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (READ_PORT_COUNT),
        .PORT_BASE_ADDR     (READ_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (READ_PORT_ADDR_WIDTH)
    )
    Read
    (
        .clock              (clock),
        .enable             (addr_is_IO),
        .addr               (addr_1_reg),
        .active             (active_IO_internal)
    );

    always@(*) begin
        active_IO <= active_IO_internal & {READ_PORT_COUNT{IO_ready}};
    end

    wire [WORD_WIDTH-1:0] data_IO_selected;

    Translated_Addressed_Mux
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .INPUT_COUNT        (READ_PORT_COUNT),
        .INPUT_BASE_ADDR    (READ_PORT_BASE_ADDR),
        .INPUT_ADDR_WIDTH   (READ_PORT_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    IO
    (
        .clock              (clock),
        .addr               (addr_3),
        .data_in            (data_IO), 
        .data_out           (data_IO_selected)
    );

    reg addr_is_IO_reg_reg;
    always @(posedge clock) begin
        addr_is_IO_reg_reg <= addr_is_IO_reg;
    end

    wire [WORD_WIDTH-1:0] data_out_internal;

    Addressed_Mux
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (1),
        .INPUT_COUNT        (2),
        .REGISTERED         (`TRUE)
    )
    Data
    (
        .clock              (clock),
        .addr               (addr_is_IO_reg_reg),
        .data_in            ({data_IO_selected, data_RAM}), 
        .data_out           (data_out_internal)
    );

    // ECL Really IO_ready_reg should be a reset signal into above mux, but I
    // don't want to create a one-use special mux module. Hopefully register
    // retiming and logic optimization of the following code should end up the
    // same.

    reg IO_ready_reg;
    reg IO_ready_reg_reg;
    always @(posedge clock) begin
        IO_ready_reg     <= IO_ready;
        IO_ready_reg_reg <= IO_ready_reg;
    end

    always @(*) begin
        data_out <= data_out_internal & {WORD_WIDTH{IO_ready_reg_reg};
    end

endmodule

