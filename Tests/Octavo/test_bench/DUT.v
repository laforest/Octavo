
// Device Under Test (DUT) for test bench

`default_nettype none

`include "Global_Defines.vh"
`include "Triadic_ALU_Operations.vh"

module DUT
#(
    // Data Path
    parameter   WORD_WIDTH                              = 36,
    parameter   READ_ADDR_WIDTH                         = 10,
    parameter   WRITE_ADDR_WIDTH                        = 12,
    // Data Memories (A/B)
    parameter   MEM_RAMSTYLE                            = "M10K, no_rw_check",
    parameter   MEM_READ_NEW_DATA                       = 0,
    parameter   MEM_INIT_FILE_A                         = "A.mem",
    parameter   MEM_INIT_FILE_B                         = "B.mem",
    parameter   MEM_READ_BASE_ADDR_A                    = 0,
    parameter   MEM_READ_BOUND_ADDR_A                   = 1023,
    parameter   MEM_WRITE_BASE_ADDR_A                   = 0,
    parameter   MEM_WRITE_BOUND_ADDR_A                  = 1023,
    parameter   MEM_READ_BASE_ADDR_B                    = 0,
    parameter   MEM_READ_BOUND_ADDR_B                   = 1023,
    parameter   MEM_WRITE_BASE_ADDR_B                   = 1024,
    parameter   MEM_WRITE_BOUND_ADDR_B                  = 2047,
    // S register in ALU
    parameter   S_WRITE_ADDR                            = 3072,
    parameter   S_RAMSTYLE                              = "MLAB, no_rw_check",
    parameter   S_READ_NEW_DATA                         = 0,
    // Same count and address for both A and B
    parameter   IO_PORT_COUNT                           = 8,
    parameter   IO_PORT_BASE_ADDR                       = 1,
    parameter   IO_PORT_ADDR_WIDTH                      = 3,
    // Addressing Module
    parameter   A_SHARED_READ_ADDR_BASE                 = 0,
    parameter   A_SHARED_READ_ADDR_BOUND                = 12,
    parameter   A_SHARED_WRITE_ADDR_BASE                = 0,
    parameter   A_SHARED_WRITE_ADDR_BOUND               = 12,
    parameter   B_SHARED_READ_ADDR_BASE                 = 0,
    parameter   B_SHARED_READ_ADDR_BOUND                = 12,
    parameter   B_SHARED_WRITE_ADDR_BASE                = 1024,
    parameter   B_SHARED_WRITE_ADDR_BOUND               = 1036,
    parameter   IH_SHARED_WRITE_ADDR_BASE               = 2048,
    parameter   IH_SHARED_WRITE_ADDR_BOUND              = 4095,
    parameter   A_INDIRECT_READ_ADDR_BASE               = 13,
    parameter   A_INDIRECT_WRITE_ADDR_BASE              = 13,
    parameter   B_INDIRECT_READ_ADDR_BASE               = 13,
    parameter   B_INDIRECT_WRITE_ADDR_BASE              = 1037,
    parameter   A_PO_ADDR_BASE                          = 3076,
    parameter   B_PO_ADDR_BASE                          = 3080,
    parameter   DA_PO_ADDR_BASE                         = 3084,
    parameter   DB_PO_ADDR_BASE                         = 3088,
    parameter   DO_ADDR                                 = 3092,
    parameter   PO_INCR_WIDTH                           = 4,
    parameter   PO_ENTRY_COUNT                          = 4,
    parameter   PO_ADDR_WIDTH                           = 2,
    parameter   A_PO_INIT_FILE                          = "PO_A.mem",
    parameter   B_PO_INIT_FILE                          = "PO_B.mem",
    parameter   DA_PO_INIT_FILE                         = "PO_DA.mem",
    parameter   DB_PO_INIT_FILE                         = "PO_DB.mem",
    parameter   DO_INIT_FILE                            = "DO.mem",
    parameter   AD_RAMSTYLE                             = "MLAB, no_rw_check",
    parameter   AD_READ_NEW_DATA                        = 0,
    // Control Path
    // Flow Control
    parameter   PC_WIDTH                                = 10,
    parameter   BRANCH_COUNT                            = 4,
    parameter   FC_RAMSTYLE                             = "MLAB, no_rw_check",
    parameter   FC_READ_NEW_DATA                        = 0,
    // Controller: initial PC values
    parameter   PC_INIT_FILE                            = "PC.mem",
    parameter   PC_PREV_INIT_FILE                       = "PC_prev.mem",
    // Instruction format
    parameter   OPCODE_WIDTH                            = `OPCODE_WIDTH,
    parameter   D_OPERAND_WIDTH                         = 12,
    parameter   A_OPERAND_WIDTH                         = 10,
    parameter   B_OPERAND_WIDTH                         = 10,
    // Instruction Memory (shared)
    parameter   IM_WORD_WIDTH                           = WORD_WIDTH,
    parameter   IM_ADDR_WIDTH                           = READ_ADDR_WIDTH,
    parameter   IM_READ_NEW                             = 0,
    parameter   IM_DEPTH                                = 1024,
    parameter   IM_RAMSTYLE                             = "M10K, no_rw_check",
    parameter   IM_INIT_FILE                            = "I.mem",
    // Opcode Decoder Memory (multithreaded)
    parameter   OD_WORD_WIDTH                           = `TRIADIC_ALU_CTRL_WIDTH,
    parameter   OD_ADDR_WIDTH                           = 4,
    parameter   OD_READ_NEW                             = 0,
    parameter   OD_THREAD_DEPTH                         = `OPCODE_COUNT,
    parameter   OD_RAMSTYLE                             = "MLAB, no_rw_check",
    parameter   OD_INIT_FILE                            = "OD.mem",
    parameter   OD_INITIAL_THREAD_READ                  = 0,
    parameter   OD_INITIAL_THREAD_WRITE                 = 0,
    // Memory-mapping
    parameter   IM_BASE_ADDR_WRITE                      = 2048,
    parameter   FC_BASE_ADDR_WRITE                      = 3100,
    parameter   OD_BASE_ADDR_WRITE                      = 3200,
    // Multithreading (common)
    parameter   THREAD_COUNT                            = `OCTAVO_THREAD_COUNT,
    parameter   THREAD_COUNT_WIDTH                      = `OCTAVO_THREAD_COUNT_WIDTH,
    // Retiming (write addresses of ALU results)
    parameter   WRITE_RETIME_STAGES                     = 3
)
(
    input   wire                                        clock,

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

    input   wire                                        A_external,
    input   wire                                        B_external
);

// --------------------------------------------------------------------

    Octavo
    #(
        .WORD_WIDTH                 (WORD_WIDTH),
        .READ_ADDR_WIDTH            (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH           (WRITE_ADDR_WIDTH),
        .MEM_RAMSTYLE               (MEM_RAMSTYLE),
        .MEM_READ_NEW_DATA          (MEM_READ_NEW_DATA),
        .MEM_INIT_FILE_A            (MEM_INIT_FILE_A),
        .MEM_INIT_FILE_B            (MEM_INIT_FILE_B),
        .MEM_READ_BASE_ADDR_A       (MEM_READ_BASE_ADDR_A),
        .MEM_READ_BOUND_ADDR_A      (MEM_READ_BOUND_ADDR_A),
        .MEM_WRITE_BASE_ADDR_A      (MEM_WRITE_BASE_ADDR_A),
        .MEM_WRITE_BOUND_ADDR_A     (MEM_WRITE_BOUND_ADDR_A),
        .MEM_READ_BASE_ADDR_B       (MEM_READ_BASE_ADDR_B),
        .MEM_READ_BOUND_ADDR_B      (MEM_READ_BOUND_ADDR_B),
        .MEM_WRITE_BASE_ADDR_B      (MEM_WRITE_BASE_ADDR_B),
        .MEM_WRITE_BOUND_ADDR_B     (MEM_WRITE_BOUND_ADDR_B),
        .S_WRITE_ADDR               (S_WRITE_ADDR),
        .S_RAMSTYLE                 (S_RAMSTYLE),
        .S_READ_NEW_DATA            (S_READ_NEW_DATA),
        .IO_PORT_COUNT              (IO_PORT_COUNT),
        .IO_PORT_BASE_ADDR          (IO_PORT_BASE_ADDR),
        .IO_PORT_ADDR_WIDTH         (IO_PORT_ADDR_WIDTH),
        .A_SHARED_READ_ADDR_BASE    (A_SHARED_READ_ADDR_BASE), 
        .A_SHARED_READ_ADDR_BOUND   (A_SHARED_READ_ADDR_BOUND),
        .A_SHARED_WRITE_ADDR_BASE   (A_SHARED_WRITE_ADDR_BASE),
        .A_SHARED_WRITE_ADDR_BOUND  (A_SHARED_WRITE_ADDR_BOUND),
        .B_SHARED_READ_ADDR_BASE    (B_SHARED_READ_ADDR_BASE),
        .B_SHARED_READ_ADDR_BOUND   (B_SHARED_READ_ADDR_BOUND),
        .B_SHARED_WRITE_ADDR_BASE   (B_SHARED_WRITE_ADDR_BASE),
        .B_SHARED_WRITE_ADDR_BOUND  (B_SHARED_WRITE_ADDR_BOUND),
        .IH_SHARED_WRITE_ADDR_BASE  (IH_SHARED_WRITE_ADDR_BASE),
        .IH_SHARED_WRITE_ADDR_BOUND (IH_SHARED_WRITE_ADDR_BOUND),
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
        .A_PO_INIT_FILE             (A_PO_INIT_FILE),
        .B_PO_INIT_FILE             (B_PO_INIT_FILE),
        .DA_PO_INIT_FILE            (DA_PO_INIT_FILE),
        .DB_PO_INIT_FILE            (DB_PO_INIT_FILE),
        .DO_INIT_FILE               (DO_INIT_FILE),
        .AD_RAMSTYLE                (AD_RAMSTYLE),
        .AD_READ_NEW_DATA           (AD_READ_NEW_DATA),
        .PC_WIDTH                   (PC_WIDTH),
        .BRANCH_COUNT               (BRANCH_COUNT),
        .FC_RAMSTYLE                (FC_RAMSTYLE),
        .FC_READ_NEW_DATA           (FC_READ_NEW_DATA),
        .PC_INIT_FILE               (PC_INIT_FILE),
        .PC_PREV_INIT_FILE          (PC_PREV_INIT_FILE),
        .OPCODE_WIDTH               (OPCODE_WIDTH),
        .D_OPERAND_WIDTH            (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH            (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH            (B_OPERAND_WIDTH),
        .IM_WORD_WIDTH              (IM_WORD_WIDTH),
        .IM_ADDR_WIDTH              (IM_ADDR_WIDTH),
        .IM_READ_NEW                (IM_READ_NEW),
        .IM_DEPTH                   (IM_DEPTH),
        .IM_RAMSTYLE                (IM_RAMSTYLE),
        .IM_INIT_FILE               (IM_INIT_FILE),
        .OD_WORD_WIDTH              (OD_WORD_WIDTH),
        .OD_ADDR_WIDTH              (OD_ADDR_WIDTH),
        .OD_READ_NEW                (OD_READ_NEW),
        .OD_THREAD_DEPTH            (OD_THREAD_DEPTH),
        .OD_RAMSTYLE                (OD_RAMSTYLE),
        .OD_INIT_FILE               (OD_INIT_FILE),
        .OD_INITIAL_THREAD_READ     (OD_INITIAL_THREAD_READ),
        .OD_INITIAL_THREAD_WRITE    (OD_INITIAL_THREAD_WRITE),
        .FC_BASE_ADDR_WRITE         (FC_BASE_ADDR_WRITE),
        .IM_BASE_ADDR_WRITE         (IM_BASE_ADDR_WRITE),
        .OD_BASE_ADDR_WRITE         (OD_BASE_ADDR_WRITE),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH),
        .WRITE_RETIME_STAGES        (WRITE_RETIME_STAGES)
    )
    CPU
    (
        .clock                      (clock),

        .A_external                 (A_external),
        .B_external                 (B_external),

        .io_read_EF_A               (io_read_EF_A),
        .io_read_EF_B               (io_read_EF_B),
        .io_write_EF_A              (io_write_EF_A),
        .io_write_EF_B              (io_write_EF_B),

        .io_read_data_A             (io_read_data_A),
        .io_read_data_B             (io_read_data_B),
        .io_write_data_A            (io_write_data_A),
        .io_write_data_B            (io_write_data_B),

        .io_rden_A                  (io_rden_A),
        .io_rden_B                  (io_rden_B),
        .io_wren_A                  (io_wren_A),
        .io_wren_B                  (io_wren_B)
    );

endmodule

