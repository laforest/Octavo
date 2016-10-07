
// Data Memories for Datapath: A and B
// Includes read/write address decoding
// Any split address has already been dealt with before arriving here.

module Datapath_Memory
#(
    parameter   WORD_WIDTH                              = 0,
    parameter   READ_ADDR_WIDTH                         = 0,
    parameter   WRITE_ADDR_WIDTH                        = 0,
    parameter   MEM_ADDR_WIDTH                          = 0,
    parameter   MEM_DEPTH                               = 0,
    parameter   MEM_RAMSTYLE                            = "",
    parameter   MEM_INIT_FILE_A                         = "",
    parameter   MEM_INIT_FILE_B                         = "",
    // Memory A Write Base Address is always zero
    parameter   MEM_WRITE_BASE_ADDR_B                   = 0,
    parameter   IO_PORT_COUNT                           = 0,
    parameter   IO_PORT_BASE_ADDR                       = 0,
    parameter   IO_PORT_ADDR_WIDTH                      = 0
)
(
    input   wire                                        clock,

    // Translated addresses from Address Offset Module (AOM)
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_A,
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_B,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_A,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_B,
    
    // From the ALU
    input   wire    [WORD_WIDTH-1:0]                    write_data_A,
    input   wire    [WORD_WIDTH-1:0]                    write_data_B,

    // To/From the outside world
    input   wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_A,
    input   wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_B,
    output  wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_write_data_A,
    output  wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_write_data_B,

    // From the I/O Predication module
    input   wire                                        read_addr_is_IO_A,
    input   wire                                        read_addr_is_IO_B,
    input   wire                                        write_addr_is_IO_A,
    input   wire                                        write_addr_is_IO_B,

    // To the outside world: which I/O Write Port is writing
    output  wire    [IO_PORT_COUNT-1:0]                 io_wren_A,
    output  wire    [IO_PORT_COUNT-1:0]                 io_wren_B,

    // Final read output from either Memory or I/O
    output  wire    [WORD_WIDTH-1:0]                    read_data_A,
    output  wire    [WORD_WIDTH-1:0]                    read_data_B
);

// --------------------------------------------------------------------
// --------------------------------------------------------------------

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

    // Memories are addressed as a sub-set of the 
    // entire read/write address space.

    // This does assume that MEM_ADDR_WIDTH is <= READ/WRITE_ADDR_WIDTH
    // and that the sub-set is power-of-two aligned since we drop the MSB.

    reg [MEM_ADDR_WIDTH-1:0] read_addr_A_local = 0;
    reg [MEM_ADDR_WIDTH-1:0] read_addr_B_local = 0;
    reg [MEM_ADDR_WIDTH-1:0] write_addr_A_local = 0;
    reg [MEM_ADDR_WIDTH-1:0] write_addr_B_local = 0;

    always @(*) begin
        read_addr_A_local  <= read_addr_A  [MEM_ADDR_WIDTH-1:0];
        read_addr_B_local  <= read_addr_B  [MEM_ADDR_WIDTH-1:0];
        write_addr_A_local <= write_addr_A [MEM_ADDR_WIDTH-1:0];
        write_addr_B_local <= write_addr_B [MEM_ADDR_WIDTH-1:0];
    end

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    Memory
    #(
        .WORD_WIDTH             (WORD_WIDTH), 
        .ADDR_WIDTH             (MEM_ADDR_WIDTH), 
        .MEM_DEPTH              (MEM_DEPTH), 
        .MEM_RAMSTYLE           (MEM_RAMSTYLE), 
        .MEM_INIT_FILE          (MEM_INIT_FILE_A), 
        .IO_PORT_COUNT          (IO_PORT_COUNT), 
        .IO_PORT_BASE_ADDR      (IO_PORT_BASE_ADDR), 
        .IO_PORT_ADDR_WIDTH     (IO_PORT_ADDR_WIDTH)
    )
    M_A
    (
        .clock                  (clock),

        .read_enable            (read_enable_A),
        .read_addr              (read_addr_A_local),
        .read_addr_is_IO        (read_addr_is_IO_A),
        .read_data              (read_data_A),
        .io_read_data           (io_read_data_A),   

        .write_enable           (write_enable_A),
        .write_addr             (write_addr_A_local),
        .write_addr_is_IO       (write_addr_is_IO_A),
        .write_data             (write_data_A),
        .io_wren                (io_wren_A),
        .io_write_data          (io_write_data_A)
    );

// --------------------------------------------------------------------

    Memory
    #(
        .WORD_WIDTH             (WORD_WIDTH), 
        .ADDR_WIDTH             (MEM_ADDR_WIDTH), 
        .MEM_DEPTH              (MEM_DEPTH), 
        .MEM_RAMSTYLE           (MEM_RAMSTYLE), 
        .MEM_INIT_FILE          (MEM_INIT_FILE_B), 
        .IO_PORT_COUNT          (IO_PORT_COUNT), 
        .IO_PORT_BASE_ADDR      (IO_PORT_BASE_ADDR), 
        .IO_PORT_ADDR_WIDTH     (IO_PORT_ADDR_WIDTH)
    )
    M_B
    (
        .clock                  (clock),

        .read_enable            (read_enable_B),
        .read_addr              (read_addr_B_local),
        .read_addr_is_IO        (read_addr_is_IO_B),
        .read_data              (read_data_B),
        .io_read_data           (io_read_data_B),   

        .write_enable           (write_enable_B),
        .write_addr             (write_addr_B_local),
        .write_addr_is_IO       (write_addr_is_IO_B),
        .write_data             (write_data_B),
        .io_wren                (io_wren_B),
        .io_write_data          (io_write_data_B)
    );

endmodule

