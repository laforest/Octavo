
// The Octavo multi-threaded soft-processor

`default_nettype none

`include "Triadic_ALU_Operations.vh"

module Octavo
#(
    // Data Path
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
    parameter   IH_SHARED_WRITE_ADDR_BASE               = 0,
    parameter   IH_SHARED_WRITE_ADDR_BOUND              = 0,
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
    parameter   DO_INIT_FILE                            = "",
    parameter   AD_RAMSTYLE                             = "",
    parameter   AD_READ_NEW_DATA                        = 0,
    // Control Path
    // Flow Control
    parameter   PC_WIDTH                                = 0,
    parameter   BRANCH_COUNT                            = 0,
    parameter   FC_RAMSTYLE                             = 0,
    parameter   FC_READ_NEW_DATA                        = 0,
    // Controller: initial PC values
    parameter   PC_INIT_FILE                            = "",
    parameter   PC_PREV_INIT_FILE                       = "",
    // Instruction format
    parameter   OPCODE_WIDTH                            = 0,
    parameter   D_OPERAND_WIDTH                         = 0,
    parameter   A_OPERAND_WIDTH                         = 0,
    parameter   B_OPERAND_WIDTH                         = 0,
    // Instruction Memory (shared)
    parameter   IM_WORD_WIDTH                           = 0,
    parameter   IM_ADDR_WIDTH                           = 0,
    parameter   IM_READ_NEW                             = 0,
    parameter   IM_DEPTH                                = 0,
    parameter   IM_RAMSTYLE                             = "",
    parameter   IM_INIT_FILE                            = "",
    // Opcode Decoder Memory (multithreaded)
    parameter   OD_WORD_WIDTH                           = 0,
    parameter   OD_ADDR_WIDTH                           = 0,
    parameter   OD_READ_NEW                             = 0,
    parameter   OD_THREAD_DEPTH                         = 0,
    parameter   OD_RAMSTYLE                             = "",
    parameter   OD_INIT_FILE                            = "",
    parameter   OD_INITIAL_THREAD_READ                  = 0,
    parameter   OD_INITIAL_THREAD_WRITE                 = 0,
    // Memory-mapping
    parameter   FC_BASE_ADDR_WRITE                      = 0,
    parameter   IM_BASE_ADDR_WRITE                      = 0,
    parameter   OD_BASE_ADDR_WRITE                      = 0,
    // Multithreading (common)
    parameter   THREAD_COUNT                            = 0,
    parameter   THREAD_COUNT_WIDTH                      = 0,
    // Retiming
    parameter   WRITE_RETIME_STAGES                     = 0
)
(
    input   wire                                        clock,

    // Data Path
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

    // Control Path
    // External branch condition inputs
    input   wire                                        A_external,
    input   wire                                        B_external
);

// --------------------------------------------------------------------

    // Carry along the Cancel and I/O Ready signals to the end of the Control
    // and Data Paths. These originate in Stage 2, and are used in Stage 8 to
    // indicate if the associated instruction (the previous instruction, from
    // the destination's point-of-view) was Annulled or Cancelled.

    // These are crucial control signals used everywhere.
    // The Datapath annuls instructions (no-op and re-issue).
    // The Controlpath cancels instructions (no-op and continue).

    localparam IOR_CANCEL_PIPE_DEPTH = 6;

    wire Cancel, Cancel_previous;
    wire IOR,    IOR_previous;

    Delay_Line 
    #(
        .DEPTH  (IOR_CANCEL_PIPE_DEPTH), 
        .WIDTH  (2)
    ) 
    DL_C_IOR
    (
        .clock  (clock),
        .in     ({Cancel,          IOR}),
        .out    ({Cancel_previous, IOR_previous})
    );

// --------------------------------------------------------------------

    wire [`TRIADIC_ALU_CTRL_WIDTH-1:0]  control;
    wire                                carryout;
    wire                                overflow;
    wire [WRITE_ADDR_WIDTH-1:0]         DA;
    wire [WRITE_ADDR_WIDTH-1:0]         DB;
    wire [READ_ADDR_WIDTH-1:0]          A;
    wire [READ_ADDR_WIDTH-1:0]          B;
    wire [WORD_WIDTH-1:0]               Rb;
    wire [WRITE_ADDR_WIDTH-1:0]         write_addr_Rb;

    Datapath
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
        .DO_INIT_FILE               (DO_INIT_FILE),
        .AD_RAMSTYLE                (AD_RAMSTYLE),
        .AD_READ_NEW_DATA           (AD_READ_NEW_DATA),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH),
        .WRITE_RETIME_STAGES        (WRITE_RETIME_STAGES)
    )
    DP
    (
        .clock                      (clock),

        .control                    (control),
        .read_addr_A                (A),
        .read_addr_B                (B),
        .write_addr_A               (DA),
        .write_addr_B               (DB),
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
        .io_wren_B                  (io_wren_B),
        .Ra                         (),
        .Rb                         (Rb),
        .write_addr_Ra              (),
        .write_addr_Rb              (write_addr_Rb),
        .Rcarry_out                 (carryout),
        .Roverflow                  (overflow),

        .cancel                     (Cancel),
        .cancel_previous            (Cancel_previous),
        .IO_ready                   (IOR),
        .IO_ready_previous          (IOR_previous)
    );

// --------------------------------------------------------------------

    Controlpath
    #(
        .ADDR_WIDTH                 (WRITE_ADDR_WIDTH),
        .WORD_WIDTH                 (WORD_WIDTH),
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
        .DB_BASE_ADDR               (MEM_WRITE_BASE_ADDR_B),
        .IM_BASE_ADDR_WRITE         (IM_BASE_ADDR_WRITE),
        .OD_BASE_ADDR_WRITE         (OD_BASE_ADDR_WRITE),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH),
        .WRITE_RETIME_STAGES        (WRITE_RETIME_STAGES)
    )
    CP
    (
        .clock                      (clock),

        .cancel                     (Cancel),
        .cancel_previous            (Cancel_previous),
        .IOR                        (IOR),
        .IOR_previous               (IOR_previous),

        .config_addr                (write_addr_Rb),
        .config_data                (Rb),

        .carryout                   (carryout),
        .overflow                   (overflow),
        .A_external                 (A_external),
        .B_external                 (B_external),
        .R_previous                 (Rb),

        .ALU_control                (control),
        .DA                         (DA),
        .DB                         (DB),
        .A                          (A),
        .B                          (B)
    );

endmodule

