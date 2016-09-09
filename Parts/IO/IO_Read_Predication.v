
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
    output  wire    [IO_READ_PORT_COUNT-1:0]                rden,
);

// --------------------------------------------------------------------

    wire addr_is_IO;

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
        .addr_is_IO         (addr_is_IO),
    );

    reg [ADDR_WIDTH-1:0] addr_stage_2 = 0;

    always @(posedge clock) begin
        addr_stage_2 <= addr;
    end

// --------------------------------------------------------------------
// This is aligned to Stage 2 of the IO_Check

    wire    [IO_READ_PORT_COUNT-1:0]    rden_raw;

    IO_Active
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (IO_READ_PORT_COUNT),
        .PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH)
    )
    Read_IO_Active
    (
        .clock              (clock),
        .enable             (addr_is_IO),
        .addr               (addr_stage_2),
        .active             (rden_raw)
    );

    reg [IO_READ_PORT_COUNT-1:0] rden_raw_reg = 0;

    always @(posedge clock) begin
        rden_raw_reg <= rden_raw;
    end

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
        .in         (rden_raw_reg),
        .out        (rden)
    );

endmodule

