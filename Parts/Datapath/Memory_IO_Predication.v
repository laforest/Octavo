
// I/O Predication for one Memory in Octavo Datapath

`default_nettype none

module Memory_IO_Predication
#(
    parameter   ADDR_WIDTH                      = 0,
    parameter   PORT_COUNT                      = 0,
    parameter   PORT_BASE_ADDR                  = 0,
    parameter   PORT_ADDR_WIDTH                 = 0
)
(
    input   wire                                clock,
    input   wire                                IO_ready,

    input   wire                                read_enable,
    input   wire    [ADDR_WIDTH-1:0]            read_addr,
    input   wire                                write_enable,
    input   wire    [ADDR_WIDTH-1:0]            write_addr,

    input   wire    [PORT_COUNT-1:0]            read_EF,
    input   wire    [PORT_COUNT-1:0]            write_EF,
    output  wire                                read_EF_masked,
    output  wire                                write_EF_masked,

    output  wire    [PORT_COUNT-1:0]            io_rden,
    output  wire                                read_addr_is_IO,
    output  wire                                write_addr_is_IO
);

// --------------------------------------------------------------------

    IO_Read_Predication
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (PORT_COUNT),
        .PORT_BASE_ADDR     (PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (PORT_ADDR_WIDTH)
    )
    IORP
    (
        .clock              (clock),
        .IO_ready           (IO_ready),
        .enable             (read_enable),
        .addr               (read_addr),
        .EmptyFull          (read_EF),
        .EmptyFull_masked   (read_EF_masked),
        .io_rden            (io_rden),
        .addr_is_IO         (read_addr_is_IO)
    );

// --------------------------------------------------------------------

    IO_Write_Predication
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (PORT_COUNT),
        .PORT_BASE_ADDR     (PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (PORT_ADDR_WIDTH)
    )
    IOWP
    (
        .clock              (clock),
        .IO_ready           (IO_ready),
        .enable             (write_enable),
        .addr               (write_addr),
        .EmptyFull          (write_EF),
        .EmptyFull_masked   (write_EF_masked),
        .addr_is_IO         (write_addr_is_IO)
    );

endmodule

