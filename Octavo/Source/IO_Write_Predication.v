
// IO_Write_Predication. Allows us to prevent a write to an I/O port if the
// port isn't ready.

// Similar as IO_Read_Predication, except the IO_Active check, to generate all
// the write enables, is done separately, after the ALU.

`default_nettype none

module IO_Write_Predication
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
    input   wire    [PORT_COUNT-1:0]    EmptyFull,
    output  wire                        EmptyFull_masked,
    output  reg                         addr_is_IO
);

// -----------------------------------------------------------

    initial begin
        addr_is_IO = 0;
    end

// -----------------------------------------------------------
// Stage 1 and 2

    wire addr_is_IO_raw;

    IO_Check
    #(
        .READY_STATE        (1'b0),  // EMPTY
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (PORT_COUNT),
        .PORT_BASE_ADDR     (PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (PORT_ADDR_WIDTH)
    )
    Write_IO_Check
    (
        .clock              (clock),
        .enable             (enable),
        .addr               (addr),
        .port_EF            (EmptyFull),
        .port_EF_masked     (EmptyFull_masked),
        .addr_is_IO         (addr_is_IO_raw)
    );

// --------------------------------------------------------------------
// This is to line up to Stage 2 of the IO_Check

    always @(posedge clock) begin
        addr_is_IO <= addr_is_IO_raw;
    end

endmodule

