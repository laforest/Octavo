
// Octavo Datapath: I/O Predication, Addressing, Memory, I/O, and ALU

`default_nettype none

`include "Triadic_ALU_Operations.vh"

module Datapath
#(
    parameter   WORD_WIDTH                              = 0,
    parameter   READ_ADDR_WIDTH                         = 0,
    parameter   WRITE_ADDR_WIDTH                        = 0,
    // Data Memories (A/B)
    parameter   MEM_RAMSTYLE                            = "",
    parameter   MEM_READ_NEW_DATA                       = 0,
    parameter   MEM_INIT_FILE_A                         = "",
    parameter   MEM_INIT_FILE_B                         = "",
    parameter   MEM_READ_BASE_ADDR_A                    = 0,
    parameter   MEM_READ_BOUND_ADDR_A                   = 0,
    parameter   MEM_WRITE_BASE_ADDR_A                   = 0,
    parameter   MEM_WRITE_BOUND_ADDR_A                  = 0,
    parameter   MEM_READ_BASE_ADDR_B                    = 0,
    parameter   MEM_READ_BOUND_ADDR_B                   = 0,
    parameter   MEM_WRITE_BASE_ADDR_B                   = 0,
    parameter   MEM_WRITE_BOUND_ADDR_B                  = 0,
    // S register in ALU
    parameter   S_WRITE_ADDR                            = 0,
    parameter   S_RAMSTYLE                              = "",
    parameter   S_READ_NEW_DATA                         = 0,
    // Same count and address for both A and B
    parameter   IO_PORT_COUNT                           = 0,
    parameter   IO_PORT_BASE_ADDR                       = 0,
    parameter   IO_PORT_ADDR_WIDTH                      = 0,
    // Addressing Module
    parameter   A_SHARED_READ_ADDR_BASE                 = 0,
    parameter   A_SHARED_READ_ADDR_BOUND                = 0,
    parameter   A_SHARED_WRITE_ADDR_BASE                = 0,
    parameter   A_SHARED_WRITE_ADDR_BOUND               = 0,
    parameter   B_SHARED_READ_ADDR_BASE                 = 0,
    parameter   B_SHARED_READ_ADDR_BOUND                = 0,
    parameter   B_SHARED_WRITE_ADDR_BASE                = 0,
    parameter   B_SHARED_WRITE_ADDR_BOUND               = 0,
    parameter   A_INDIRECT_READ_ADDR_BASE               = 0,
    parameter   A_INDIRECT_WRITE_ADDR_BASE              = 0,
    parameter   B_INDIRECT_READ_ADDR_BASE               = 0,
    parameter   B_INDIRECT_WRITE_ADDR_BASE              = 0,
    parameter   A_PO_ADDR_BASE                          = 0,
    parameter   B_PO_ADDR_BASE                          = 0,
    parameter   DA_PO_ADDR_BASE                         = 0,
    parameter   DB_PO_ADDR_BASE                         = 0,
    parameter   DO_ADDR                                 = 0,
    parameter   PO_INCR_WIDTH                           = 0,
    parameter   PO_ENTRY_COUNT                          = 0,
    parameter   PO_ADDR_WIDTH                           = 0,
    parameter   PO_INIT_FILE                            = "",
    parameter   DO_INIT_FILE                            = "",
    parameter   AD_RAMSTYLE                             = "",
    parameter   AD_READ_NEW_DATA                        = 0,
    // Multithreading
    parameter   THREAD_COUNT                            = 0,
    parameter   THREAD_COUNT_WIDTH                      = 0
)
(
    input   wire                                        clock,

    // From Flow Control: ALU control bits
    input   wire    [`TRIADIC_ALU_CTRL_WIDTH-1:0]       control,

    // From Flow Control. Signals a cancelled current and previous instruction.
    input   wire                                        cancel,
    input   wire                                        cancel_previous,

    // From Flow Control: Instruction operands (post-splitting).
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_A,
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_B,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_A,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_B,

    // External I/O: Empty/Full bits, data, and read/write enables
    input   wire    [IO_PORT_COUNT-1:0]                 io_read_EF_A,
    input   wire    [IO_PORT_COUNT-1:0]                 io_read_EF_B,
    input   wire    [IO_PORT_COUNT-1:0]                 io_write_EF_A,
    input   wire    [IO_PORT_COUNT-1:0]                 io_write_EF_B,

    input   wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_A,
    input   wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_B,
    output  wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_write_data_A,
    output  wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_write_data_B,

    output  wire    [IO_PORT_COUNT-1:0]                 io_rden_A,
    output  wire    [IO_PORT_COUNT-1:0]                 io_rden_B,
    output  wire    [IO_PORT_COUNT-1:0]                 io_wren_A,
    output  wire    [IO_PORT_COUNT-1:0]                 io_wren_B,

    // ALU write data and address outputs to all things not in Datapath (I and H Memories)
    output  wire    [WORD_WIDTH-1:0]                    Ra,
    output  wire    [WORD_WIDTH-1:0]                    Rb,
    output  wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_Ra,
    output  wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_Rb,
    // ALU flags out to Control Path (mapped to H Memory)
    output  wire                                        Rcarry_out,
    output  wire                                        Roverflow,

    // Main I/O Predication output.
    // Signals the current instruction is annulled when low.
    // Also receive the same signal from the previous instruction.
    output  wire                                        IO_ready,
    input   wire                                        IO_ready_previous
);

// --------------------------------------------------------------------

    // For clarity, as the read and write addresses have the same width at the
    // level of individual memories, and the D instruction operand write
    // address is always wider since it addresses all memory ranges
    // (A, B, I, and H)

    localparam MEM_ADDR_WIDTH = READ_ADDR_WIDTH;

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stages 1 and 2

    // Pipelines to pass control and operands along
    // Pass ALU control alongside Predication and Addressing

    localparam ADDRESSING_AND_PREDICATION_PIPE_DEPTH = 2;
    localparam ADDRESSING_AND_PREDICATION_PIPE_WIDTH = `TRIADIC_ALU_CTRL_WIDTH;

    wire [`TRIADIC_ALU_CTRL_WIDTH-1:0] control_stage2;

    Delay_Line 
    #(
        .DEPTH  (ADDRESSING_AND_PREDICATION_PIPE_DEPTH), 
        .WIDTH  (ADDRESSING_AND_PREDICATION_PIPE_WIDTH)
    ) 
    DL_AD_CTL
    (
        .clock  (clock),
        .in     (control),
        .out    (control_stage2)
    );

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
        .MEM_READ_BASE_ADDR_A   (MEM_READ_BASE_ADDR_A),
        .MEM_READ_BOUND_ADDR_A  (MEM_READ_BOUND_ADDR_A),
        .MEM_WRITE_BASE_ADDR_A  (MEM_WRITE_BASE_ADDR_A),
        .MEM_WRITE_BOUND_ADDR_A (MEM_WRITE_BOUND_ADDR_A),
        .MEM_READ_BASE_ADDR_B   (MEM_READ_BASE_ADDR_B),
        .MEM_READ_BOUND_ADDR_B  (MEM_READ_BOUND_ADDR_B),
        .MEM_WRITE_BASE_ADDR_B  (MEM_WRITE_BASE_ADDR_B),
        .MEM_WRITE_BOUND_ADDR_B (MEM_WRITE_BOUND_ADDR_B),
        .PORT_COUNT             (IO_PORT_COUNT),
        .PORT_BASE_ADDR         (IO_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH        (IO_PORT_ADDR_WIDTH)
    )
    PR
    (
        .clock                  (clock),

        .cancel                 (cancel),

        .read_addr_A            (read_addr_A),
        .read_addr_B            (read_addr_B),
        .write_addr_A           (write_addr_A),
        .write_addr_B           (write_addr_B),

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

    wire [READ_ADDR_WIDTH-1:0]  read_addr_A_offset;
    wire [READ_ADDR_WIDTH-1:0]  read_addr_B_offset;
    wire [WRITE_ADDR_WIDTH-1:0] write_addr_A_offset;
    wire [WRITE_ADDR_WIDTH-1:0] write_addr_B_offset;

    Addressing
    #(
        .WRITE_WORD_WIDTH           (WORD_WIDTH),
        .WRITE_ADDR_WIDTH           (WRITE_ADDR_WIDTH),
        .A_ADDR_WIDTH               (READ_ADDR_WIDTH),
        .B_ADDR_WIDTH               (READ_ADDR_WIDTH),
        .D_ADDR_WIDTH               (WRITE_ADDR_WIDTH),
        .A_SHARED_READ_ADDR_BASE    (A_SHARED_READ_ADDR_BASE), 
        .A_SHARED_READ_ADDR_BOUND   (A_SHARED_READ_ADDR_BOUND),
        .A_SHARED_WRITE_ADDR_BASE   (A_SHARED_WRITE_ADDR_BASE),
        .A_SHARED_WRITE_ADDR_BOUND  (A_SHARED_WRITE_ADDR_BOUND),
        .B_SHARED_READ_ADDR_BASE    (B_SHARED_READ_ADDR_BASE),
        .B_SHARED_READ_ADDR_BOUND   (B_SHARED_READ_ADDR_BOUND),
        .B_SHARED_WRITE_ADDR_BASE   (B_SHARED_WRITE_ADDR_BASE),
        .B_SHARED_WRITE_ADDR_BOUND  (B_SHARED_WRITE_ADDR_BOUND),
        .A_INDIRECT_READ_ADDR_BASE  (A_INDIRECT_READ_ADDR_BASE),
        .A_INDIRECT_WRITE_ADDR_BASE (A_INDIRECT_WRITE_ADDR_BASE),
        .B_INDIRECT_READ_ADDR_BASE  (B_INDIRECT_READ_ADDR_BASE),
        .B_INDIRECT_WRITE_ADDR_BASE (B_INDIRECT_WRITE_ADDR_BASE),
        .A_PO_ADDR_BASE             (A_PO_ADDR_BASE),
        .B_PO_ADDR_BASE             (B_PO_ADDR_BASE),
        .DA_PO_ADDR_BASE            (DA_PO_ADDR_BASE),
        .DB_PO_ADDR_BASE            (DB_PO_ADDR_BASE),
        .DO_ADDR                    (DO_ADDR),
        .PO_INCR_WIDTH              (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT             (PO_ENTRY_COUNT),
        .PO_ADDR_WIDTH              (PO_ADDR_WIDTH),
        .PO_INIT_FILE               (PO_INIT_FILE),
        .DO_INIT_FILE               (DO_INIT_FILE),
        .RAMSTYLE                   (AD_RAMSTYLE),
        .READ_NEW_DATA              (AD_READ_NEW_DATA),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH)
    )
    AD
    (
        .clock                  (clock),

        .A_raw_addr             (read_addr_A),
        .B_raw_addr             (read_addr_B),
        .DA_raw_addr            (write_addr_A),
        .DB_raw_addr            (write_addr_B),

        .IO_Ready_current       (IO_ready),
        .Cancel_current         (cancel),

        .IO_Ready_previous      (IO_ready_previous),
        .Cancel_previous        (cancel_previous),

        .write_addr             (write_addr_Rb),
        .write_data             (Rb),

        .A_offset_addr          (read_addr_A_offset),
        .B_offset_addr          (read_addr_B_offset),
        .DA_offset_addr         (write_addr_A_offset),
        .DB_offset_addr         (write_addr_B_offset)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stages 3 and 4

    // Pass signals alongside the Datapath Memory

    localparam DATA_MEMORY_PIPE_DEPTH = 2;
    localparam DATA_MEMORY_PIPE_WIDTH = `TRIADIC_ALU_CTRL_WIDTH + 1 + 1 + WRITE_ADDR_WIDTH + WRITE_ADDR_WIDTH;

    wire [`TRIADIC_ALU_CTRL_WIDTH-1:0]  control_stage4;
    wire                                write_addr_is_IO_A_stage4;
    wire                                write_addr_is_IO_B_stage4;
    wire [WRITE_ADDR_WIDTH-1:0]         write_addr_A_offset_stage4;
    wire [WRITE_ADDR_WIDTH-1:0]         write_addr_B_offset_stage4;

    Delay_Line 
    #(
        .DEPTH  (DATA_MEMORY_PIPE_DEPTH), 
        .WIDTH  (DATA_MEMORY_PIPE_WIDTH)
    ) 
    DL_DM
    (
        .clock  (clock),
        .in     ({control_stage2, write_addr_is_IO_A,        write_addr_is_IO_B,        write_addr_A_offset,        write_addr_B_offset}),
        .out    ({control_stage4, write_addr_is_IO_A_stage4, write_addr_is_IO_B_stage4, write_addr_A_offset_stage4, write_addr_B_offset_stage4})
    );

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0]       read_data_A;
    wire [WORD_WIDTH-1:0]       read_data_B;
    wire                        write_addr_is_IO_A_stage8;
    wire                        write_addr_is_IO_B_stage8;


    Datapath_Memory
    #(
        .WORD_WIDTH             (WORD_WIDTH),
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),
        .MEM_ADDR_WIDTH         (MEM_ADDR_WIDTH),
        .MEM_RAMSTYLE           (MEM_RAMSTYLE),
        .MEM_READ_NEW_DATA      (MEM_READ_NEW_DATA),
        .MEM_INIT_FILE_A        (MEM_INIT_FILE_A),
        .MEM_INIT_FILE_B        (MEM_INIT_FILE_B),
        .MEM_READ_BASE_ADDR_A   (MEM_READ_BASE_ADDR_A),
        .MEM_READ_BOUND_ADDR_A  (MEM_READ_BOUND_ADDR_A),
        .MEM_WRITE_BASE_ADDR_A  (MEM_WRITE_BASE_ADDR_A),
        .MEM_WRITE_BOUND_ADDR_A (MEM_WRITE_BOUND_ADDR_A),
        .MEM_READ_BASE_ADDR_B   (MEM_READ_BASE_ADDR_B),
        .MEM_READ_BOUND_ADDR_B  (MEM_READ_BOUND_ADDR_B),
        .MEM_WRITE_BASE_ADDR_B  (MEM_WRITE_BASE_ADDR_B),
        .MEM_WRITE_BOUND_ADDR_B (MEM_WRITE_BOUND_ADDR_B),
        .IO_PORT_COUNT          (IO_PORT_COUNT),
        .IO_PORT_BASE_ADDR      (IO_PORT_BASE_ADDR),
        .IO_PORT_ADDR_WIDTH     (IO_PORT_ADDR_WIDTH) 
    )
    DM
    (
        .clock                  (clock),

        .IOR                    (IO_ready),
        .cancel                 (cancel),
        .IOR_previous           (IO_ready_previous),
        .cancel_previous        (cancel_previous),

        .read_addr_A            (read_addr_A_offset),
        .read_addr_B            (read_addr_B_offset),
        .write_addr_A           (write_addr_Ra),
        .write_addr_B           (write_addr_Rb),
        
        .write_data_A           (Ra),
        .write_data_B           (Rb),

        .io_read_data_A         (io_read_data_A),
        .io_read_data_B         (io_read_data_B),
        .io_write_data_A        (io_write_data_A),
        .io_write_data_B        (io_write_data_B),

        .read_addr_is_IO_A      (read_addr_is_IO_A),
        .read_addr_is_IO_B      (read_addr_is_IO_B),
        .write_addr_is_IO_A     (write_addr_is_IO_A_stage8),
        .write_addr_is_IO_B     (write_addr_is_IO_B_stage8),

        .io_wren_A              (io_wren_A),
        .io_wren_B              (io_wren_B),

        .read_data_A            (read_data_A),
        .read_data_B            (read_data_B)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stages 5 through 8

    // Pass signals alongside the ALU, to the Datapath output stage.

    localparam ALU_PIPE_DEPTH = 4;
    localparam ALU_PIPE_WIDTH = 1 + 1 + WRITE_ADDR_WIDTH + WRITE_ADDR_WIDTH;

    Delay_Line 
    #(
        .DEPTH  (ALU_PIPE_DEPTH), 
        .WIDTH  (ALU_PIPE_WIDTH)
    ) 
    DL_ALU
    (
        .clock  (clock),
        .in     ({write_addr_is_IO_A_stage4, write_addr_is_IO_B_stage4, write_addr_A_offset_stage4, write_addr_B_offset_stage4}),
        .out    ({write_addr_is_IO_A_stage8, write_addr_is_IO_B_stage8, write_addr_Ra,              write_addr_Rb})
    );

// --------------------------------------------------------------------

    wire                        R_zero;
    wire                        R_negative;

    Triadic_ALU
    #(
        .WORD_WIDTH         (WORD_WIDTH), 
        .ADDR_WIDTH         (WRITE_ADDR_WIDTH),
        .S_WRITE_ADDR       (S_WRITE_ADDR),
        .S_RAMSTYLE         (S_RAMSTYLE),
        .S_READ_NEW_DATA    (S_READ_NEW_DATA),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    ALU
    (
        .clock              (clock),
        .IO_Ready           (IO_ready_previous),
        .Cancel             (cancel_previous),
        .DB                 (write_addr_Rb),
        .control            (control_stage4),
        .A                  (read_data_A),
        .B                  (read_data_B),
        .Ra                 (Ra),
        .Rb                 (Rb),
        .carry_out          (Rcarry_out),
        .overflow           (Roverflow)
    );

endmodule

