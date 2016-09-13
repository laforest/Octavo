
// I/O Read Predication. Allows us to prevent an I/O Port read operation if the
// port isn't ready.

module IO_Read_Predication
#(
    parameter   WORD_WIDTH                                  = 0,
    parameter   ADDR_WIDTH                                  = 0,
    parameter   IO_READ_PORT_COUNT                          = 0,
    parameter   IO_READ_PORT_BASE_ADDR                      = 0,
    parameter   IO_READ_PORT_ADDR_WIDTH                     = 0
)
(
    input   wire                                            clock,
    input   wire                                            IO_ready,
    input   wire    [ADDR_WIDTH-1:0]                        addr,
    input   wire    [IO_READ_PORT_COUNT-1:0]                EmptyFull,
    output  wire                                            EmptyFull_masked,
    output  wire    [IO_READ_PORT_COUNT-1:0]                io_rden,
    output  reg                                             addr_is_IO
);

// --------------------------------------------------------------------

    initial begin
        addr_is_IO = 0;
    end

// --------------------------------------------------------------------

    wire addr_is_IO_raw;

    IO_Check
    #(
        .READY_STATE        (1'b1), // FULL
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (IO_READ_PORT_COUNT),
        .PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH)
    )
    Read_IO_Check
    (
        .clock              (clock),
        .addr               (addr),
        .port_EF            (EmptyFull),
        .port_EF_masked     (EmptyFull_masked),
        .addr_is_IO         (addr_is_IO_raw),
    );

    reg [ADDR_WIDTH-1:0] addr_stage_2 = 0;

    always @(posedge clock) begin
        addr_stage_2 <= addr;
    end

// --------------------------------------------------------------------
// This is aligned to Stage 2 of the IO_Check

    wire    [IO_READ_PORT_COUNT-1:0]    io_rden_raw;

    IO_Active
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (IO_READ_PORT_COUNT),
        .PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH)
    )
    Read_IO_Active
    (
        .enable             (addr_is_IO_raw),
        .addr               (addr_stage_2),
        .active             (io_rden_raw)
    );

    reg [IO_READ_PORT_COUNT-1:0] io_rden_raw_reg = 0;

    always @(posedge clock) begin
        io_rden_raw_reg <= io_rden_raw;
    end

// --------------------------------------------------------------------
// This is aligned to Stage 2 of the IO_Check

    // We re-use this bit later, instead of re-calculating if an address
    // refers to an I/O port.

    always @(posedge clock) begin
        addr_is_IO <= addr_is_IO_raw;
    end

// --------------------------------------------------------------------
// --------------------------------------------------------------------

// Only output read enable if all accessed ports are ready.
// This prevents side-effects or lost data if an instruction is anulled.
// This happens in the stage *after* Stage 2 of IO_Check, since that's when
// the IO_ready signal is available.

    Annuller
    #(
        .WORD_WIDTH (IO_READ_PORT_COUNT)
    )
    rden_enable
    (
        .annul      (~IO_ready),
        .in         (io_rden_raw_reg),
        .out        (io_rden)
    );

endmodule

