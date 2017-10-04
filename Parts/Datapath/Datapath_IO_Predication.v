
// I/O Predication for A and B Data Memories in Octavo Datapath

`default_nettype none

`include "Global_Defines.vh"

module Datapath_IO_Predication
#(
    // Global read/write address ranges
    parameter   READ_ADDR_WIDTH             = 0,
    parameter   WRITE_ADDR_WIDTH            = 0,
    // Physical memory address width (<= to global addresses)
    parameter   MEM_ADDR_WIDTH              = 0,
    // Expressed as global addresses
    parameter   MEM_READ_BASE_ADDR_A        = 0,
    parameter   MEM_READ_BOUND_ADDR_A       = 0,
    parameter   MEM_WRITE_BASE_ADDR_A       = 0,
    parameter   MEM_WRITE_BOUND_ADDR_A      = 0,
    parameter   MEM_READ_BASE_ADDR_B        = 0,
    parameter   MEM_READ_BOUND_ADDR_B       = 0,
    parameter   MEM_WRITE_BASE_ADDR_B       = 0,
    parameter   MEM_WRITE_BOUND_ADDR_B      = 0,
    // Local memory address
    parameter   PORT_COUNT                  = 0,
    parameter   PORT_BASE_ADDR              = 0,
    parameter   PORT_ADDR_WIDTH             = 0
)
(
    input   wire                            clock,

    input   wire                            cancel,

    input   wire    [READ_ADDR_WIDTH-1:0]   read_addr_A,
    input   wire    [READ_ADDR_WIDTH-1:0]   read_addr_B,
    input   wire    [WRITE_ADDR_WIDTH-1:0]  write_addr_A,
    input   wire    [WRITE_ADDR_WIDTH-1:0]  write_addr_B,

    input   wire    [PORT_COUNT-1:0]        read_EF_A,
    input   wire    [PORT_COUNT-1:0]        read_EF_B,
    input   wire    [PORT_COUNT-1:0]        write_EF_A,
    input   wire    [PORT_COUNT-1:0]        write_EF_B,

    output  wire    [PORT_COUNT-1:0]        io_rden_A,
    output  wire    [PORT_COUNT-1:0]        io_rden_B,
    output  wire                            read_addr_is_IO_A,
    output  wire                            read_addr_is_IO_B,
    output  wire                            write_addr_is_IO_A,
    output  wire                            write_addr_is_IO_B,
    output  wire                            IO_ready
);

// --------------------------------------------------------------------

    // Gate the I/O read enables if the instruction was cancelled or if I/O
    // isn't all ready to avoid side-effect on the I/O ports.

    reg stop_rden = 0;

    always @(*) begin
        stop_rden <= (IO_ready == 1'b0) | (cancel == 1'b1);
    end 

// --------------------------------------------------------------------

    // These address decoders are always enabled since neither Cancel nor IOR
    // have been generated yet. Those will be used later to gate the final
    // read enables.  Write enables are gated at the location of the write
    // down the pipeline.

    wire                        read_enable_A;
    wire                        write_enable_A;

    Memory_Addressing
    #(
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),
        .MEM_READ_BASE_ADDR     (MEM_READ_BASE_ADDR_A),
        .MEM_READ_BOUND_ADDR    (MEM_READ_BOUND_ADDR_A),
        .MEM_WRITE_BASE_ADDR    (MEM_WRITE_BASE_ADDR_A),
        .MEM_WRITE_BOUND_ADDR   (MEM_WRITE_BOUND_ADDR_A)
    )
    MA_A
    (
        .read_IOR               (1'b1),
        .read_cancel            (1'b0),
        .read_addr              (read_addr_A),
        .read_enable            (read_enable_A),

        .write_IOR              (1'b1),
        .write_cancel           (1'b0),
        .write_addr             (write_addr_A),
        .write_enable           (write_enable_A)
    );

// --------------------------------------------------------------------

    wire                        read_enable_B;
    wire                        write_enable_B;

    Memory_Addressing
    #(
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),
        .MEM_READ_BASE_ADDR     (MEM_READ_BASE_ADDR_B),
        .MEM_READ_BOUND_ADDR    (MEM_READ_BOUND_ADDR_B),
        .MEM_WRITE_BASE_ADDR    (MEM_WRITE_BASE_ADDR_B),
        .MEM_WRITE_BOUND_ADDR   (MEM_WRITE_BOUND_ADDR_B)
    )
    MA_B
    (
        .read_IOR               (1'b1),
        .read_cancel            (1'b0),
        .read_addr              (read_addr_B),
        .read_enable            (read_enable_B),

        .write_IOR              (1'b1),
        .write_cancel           (1'b0),
        .write_addr             (write_addr_B),
        .write_enable           (write_enable_B)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    wire                    read_EF_masked_A;
    wire                    write_EF_masked_A;
    wire [PORT_COUNT-1:0]   io_rden_A_raw;

    Memory_IO_Predication
    #(
        .ADDR_WIDTH         (MEM_ADDR_WIDTH),
        .PORT_COUNT         (PORT_COUNT),
        .PORT_BASE_ADDR     (PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (PORT_ADDR_WIDTH) 
    )
    MIOP_A
    (
        .clock              (clock),

        .read_enable        (read_enable_A),
        .read_addr          (read_addr_A),
        .write_enable       (write_enable_A),
        .write_addr         (write_addr_A[MEM_ADDR_WIDTH-1:0]),

        .read_EF            (read_EF_A),
        .write_EF           (write_EF_A),
        .read_EF_masked     (read_EF_masked_A),
        .write_EF_masked    (write_EF_masked_A),

        .io_rden            (io_rden_A_raw),
        .read_addr_is_IO    (read_addr_is_IO_A),
        .write_addr_is_IO   (write_addr_is_IO_A)
    );

    Annuller
    #(
        .WORD_WIDTH (PORT_COUNT)
    )
    Gate_IO_rden_A
    (
        .annul      (stop_rden),
        .in         (io_rden_A_raw),
        .out        (io_rden_A)
    );

// --------------------------------------------------------------------

    wire                    read_EF_masked_B;
    wire                    write_EF_masked_B;
    wire [PORT_COUNT-1:0]   io_rden_B_raw;

    Memory_IO_Predication
    #(
        .ADDR_WIDTH         (MEM_ADDR_WIDTH),
        .PORT_COUNT         (PORT_COUNT),
        .PORT_BASE_ADDR     (PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (PORT_ADDR_WIDTH) 
    )
    MIOP_B
    (
        .clock              (clock),

        .read_enable        (read_enable_B),
        .read_addr          (read_addr_B),
        .write_enable       (write_enable_B),
        .write_addr         (write_addr_B[MEM_ADDR_WIDTH-1:0]),

        .read_EF            (read_EF_B),
        .write_EF           (write_EF_B),
        .read_EF_masked     (read_EF_masked_B),
        .write_EF_masked    (write_EF_masked_B),

        .io_rden            (io_rden_B_raw),
        .read_addr_is_IO    (read_addr_is_IO_B),
        .write_addr_is_IO   (write_addr_is_IO_B)
    );

    Annuller
    #(
        .WORD_WIDTH (PORT_COUNT)
    )
    Gate_IO_rden_B
    (
        .annul      (stop_rden),
        .in         (io_rden_B_raw),
        .out        (io_rden_B)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    // PORT_COUNT here refers to the number of simultaneously active I/O ports
    // of each kind. Here it's 2, since there are 2 Data Memories, A and B,
    // which can each do a read and a write each cycle.

    // And if any of the read/write I/O ports accessed by the current
    // instruction are not ready, drop IO_ready.

    IO_All_Ready
    #(
        .READ_PORT_COUNT    (`READ_PORT_COUNT),
        .WRITE_PORT_COUNT   (`WRITE_PORT_COUNT)
    )
    IAR
    (
        .read_EF            ({read_EF_masked_B, read_EF_masked_A}),
        .write_EF           ({write_EF_masked_B,write_EF_masked_A}),
        .IO_ready           (IO_ready)
    );

endmodule

