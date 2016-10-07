
// I/O Predication for A and B Data Memories in Octavo Datapath

module Datapath_IO_Predication
#(

    parameter   READ_ADDR_WIDTH             = 0,
    parameter   WRITE_ADDR_WIDTH            = 0,
    parameter   MEM_ADDR_WIDTH              = 0,
    parameter   MEM_DEPTH                   = 0,
    parameter   MEM_WRITE_BASE_ADDR_B       = 0,
    parameter   PORT_COUNT                  = 0,
    parameter   PORT_BASE_ADDR              = 0,
    parameter   PORT_ADDR_WIDTH             = 0
)
(
    input   wire                            clock,
    input   wire                            split,

    input   wire    [READ_ADDR_WIDTH-1:0]   read_addr_A,
    input   wire    [READ_ADDR_WIDTH-1:0]   read_addr_B,
    input   wire    [WRITE_ADDR_WIDTH-1:0]  write_addr_D,

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

    wire                        read_enable_A;
    wire                        write_enable_A;
    wire [MEM_ADDR_WIDTH-1:0]   write_addr_A;

    Write_Address_Split
    #(
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH), 
        .WRITE_ADDR_WIDTH_LOCAL (MEM_ADDR_WIDTH),
        .LOWER_UPPER_SPLIT      (1) // Memory A gets upper half of split D
    )
    WAS_A
    (
        .split                  (split),
        .write_addr             (write_addr_D),
        .write_addr_translated  (write_addr_A)
    );

    Memory_Addressing
    #(
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),
        .MEM_READ_BASE_ADDR     (0),
         // Memory A Write Base Address is always zero
        .MEM_WRITE_BASE_ADDR    (0),
        .MEM_DEPTH              (MEM_DEPTH)
    )
    MA_A
    (
        .read_addr              (read_addr_A),
        .write_addr             (write_addr_A),
        .read_enable            (read_enable_A),
        .write_enable           (write_enable_A)
    );

// --------------------------------------------------------------------

    wire                        read_enable_B;
    wire                        write_enable_B;
    wire [MEM_ADDR_WIDTH-1:0]   write_addr_B;

    Write_Address_Split
    #(
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH), 
        .WRITE_ADDR_WIDTH_LOCAL (MEM_ADDR_WIDTH),
        .LOWER_UPPER_SPLIT      (0) // Memory B gets lower half of split D
    )
    WAS_B
    (
        .split                  (split),
        .write_addr             (write_addr_D),
        .write_addr_translated  (write_addr_B)
    );

    Memory_Addressing
    #(
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),
        .MEM_READ_BASE_ADDR     (0),
        .MEM_WRITE_BASE_ADDR    (MEM_WRITE_BASE_ADDR_B),
        .MEM_DEPTH              (MEM_DEPTH)
    )
    MA_B
    (
        .read_addr              (read_addr_B),
        .write_addr             (write_addr_B),
        .read_enable            (read_enable_B),
        .write_enable           (write_enable_B)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    wire read_EF_masked_A;
    wire write_EF_masked_A;

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
        .IO_ready           (IO_ready),

        .read_enable        (read_enable_A),
        .read_addr          (read_addr_A),
        .write_enable       (write_enable_A),
        .write_addr         (write_addr_A),

        .read_EF            (read_EF_A),
        .write_EF           (write_EF_A),
        .read_EF_masked     (read_EF_masked_A),
        .write_EF_masked    (write_EF_masked_A),

        .io_rden            (io_rden_A),
        .read_addr_is_IO    (read_addr_is_IO_A),
        .write_addr_is_IO   (write_addr_is_IO_A)
    );

// --------------------------------------------------------------------

    wire read_EF_masked_B;
    wire write_EF_masked_B;

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
        .IO_ready           (IO_ready),

        .read_enable        (read_enable_B),
        .read_addr          (read_addr_B),
        .write_enable       (write_enable_B),
        .write_addr         (write_addr_B),

        .read_EF            (read_EF_B),
        .write_EF           (write_EF_B),
        .read_EF_masked     (read_EF_masked_B),
        .write_EF_masked    (write_EF_masked_B),

        .io_rden            (io_rden_B),
        .read_addr_is_IO    (read_addr_is_IO_B),
        .write_addr_is_IO   (write_addr_is_IO_B)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    // PORT_COUNT here refers to the number of simultaneously active I/O ports
    // of each kind. Here it's 2, since there are 2 Data Memories, A and B,
    // which can each do a read and a write each cycle.

    IO_All_Ready
    #(
        .READ_PORT_COUNT    (2),
        .WRITE_PORT_COUNT   (2)
    )
    IAR
    (
        .read_EF            ({read_EF_masked_B, read_EF_masked_A}),
        .write_EF           ({write_EF_masked_B,write_EF_masked_A}),
        .IO_ready           (IO_ready)
    );

endmodule

