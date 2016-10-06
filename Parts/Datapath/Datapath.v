
// Octavo Datapath: I/O predication, Memory, I/O, and ALU


module Datapath
#(
    parameter   WORD_WIDTH                              = 0,
    parameter   READ_ADDR_WIDTH                         = 0,
    parameter   WRITE_ADDR_WIDTH                        = 0,
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
    input   wire    [`TRIADIC_CTRL_WIDTH-1:0]           control,

    // Contained in control, but extracted separately as it's used elsewhere.
    input   wire                                        split,

    // From Branch Trigger Module (BTM). Signals a cancelled instruction.
    input   wire                                        branch_cancel,

    // These are raw from the instruction, and drive I/O Predication
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_A,
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_B,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_D,

    // These have been translated, and drive the Memory
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_A_offset,
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_B_offset,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_A_offset,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_B_offset,
    
    input   wire    [WORD_WIDTH-1:0]                    write_data_A,
    input   wire    [WORD_WIDTH-1:0]                    write_data_B,

    input   wire    [PORT_COUNT-1:0]                    io_read_EF_A,
    input   wire    [PORT_COUNT-1:0]                    io_read_EF_B,
    input   wire    [PORT_COUNT-1:0]                    io_write_EF_A,
    input   wire    [PORT_COUNT-1:0]                    io_write_EF_B,

    input   wire    [(PORT_COUNT*WORD_WIDTH)-1:0]       io_read_data_A,
    input   wire    [(PORT_COUNT*WORD_WIDTH)-1:0]       io_read_data_B,
    output  wire    [(PORT_COUNT*WORD_WIDTH)-1:0]       io_write_data_A,
    output  wire    [(PORT_COUNT*WORD_WIDTH)-1:0]       io_write_data_B,

    output  wire    [PORT_COUNT-1:0]                    io_rden_A,
    output  wire    [PORT_COUNT-1:0]                    io_rden_B,
    output  wire    [PORT_COUNT-1:0]                    io_wren_A,
    output  wire    [PORT_COUNT-1:0]                    io_wren_B,

    // ALU outputs
    output  wire    [WORD_WIDTH-1:0]                    Ra,
    output  wire    [WORD_WIDTH-1:0]                    Rb,
    output  wire                                        Rcarry_out,
    output  wire                                        Roverflow,

    // Main I/O Predication output. Signals an annulled instruction.
    output  wire                                        IO_ready
);

// --------------------------------------------------------------------

    // For clarity, as the read and write addresses have the same width at the
    // level of individual memories, and the D instruction operand write
    // address is always wider since it addresses all memory ranges
    // (A, B, I, and H)

    localparam MEM_ADDR_WIDTH = READ_ADDR_WIDTH;

// --------------------------------------------------------------------

    wire read_addr_is_IO_A;
    wire read_addr_is_IO_B;
    wire write_addr_is_IO_A;
    wire write_addr_is_IO_B;

    Datapath_IO_Predication
    #(
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),    
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),    
        .MEM_ADDR_WIDTH         (MEM_ADDR_WIDTH),
         // Memory A Write Base Address is always zero
        .MEM_WRITE_BASE_ADDR_A  (0),
        .MEM_DEPTH_A            (MEM_DEPTH), 
        .MEM_WRITE_BASE_ADDR_B  (MEM_WRITE_BASE_ADDR_B),
        .MEM_DEPTH_B            (MEM_DEPTH),
        .PORT_COUNT             (IO_PORT_COUNT),
        .PORT_BASE_ADDR         (IO_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH        (IO_PORT_ADDR_WIDTH)
    )
    DIOP
    (
        .clock                  (clock),
        .split                  (split),

        .read_addr_A            (read_addr_A),
        .read_addr_B            (read_addr_B),
        .write_addr_D           (write_addr_D),

        .read_EF_A              (io_read_EF_A),
        .read_EF_B              (io_read_EF_B),
        .write_EF_A             (io_write_EF_A),
        .write_EF_B             (io_write_EF_B),

        .io_rden_A              (io_rden_A),
        .io_rden_B              (io_rden_B),
        .read_addr_is_IO_A      (read_addr_is_IO_A),
        .read_addr_is_IO_B      (read_addr_is_IO_B),
        .write_addr_is_IO_A     (write_addr_is_IO_A),
        .write_addr_is_IO_B     (write_addr_is_IO_B),
        .IO_ready               (IO_ready)
    );

// --------------------------------------------------------------------



endmodule

