
`default_nettype none

`include "Global_Defines.vh"
`include "Triadic_ALU_Operations.vh"

module Generic_test_harness
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
    parameter   IO_PORT_COUNT                           = 4,
    parameter   IO_PORT_BASE_ADDR                       = 28,
    parameter   IO_PORT_ADDR_WIDTH                      = 2,
    // Addressing Module
    parameter   A_SHARED_READ_ADDR_BASE                 = 0,
    parameter   A_SHARED_READ_ADDR_BOUND                = 31,
    parameter   A_SHARED_WRITE_ADDR_BASE                = 0,
    parameter   A_SHARED_WRITE_ADDR_BOUND               = 31,
    parameter   B_SHARED_READ_ADDR_BASE                 = 0,
    parameter   B_SHARED_READ_ADDR_BOUND                = 23,
    parameter   B_SHARED_WRITE_ADDR_BASE                = 1024,
    parameter   B_SHARED_WRITE_ADDR_BOUND               = 1055,
    parameter   IH_SHARED_WRITE_ADDR_BASE               = 2048,
    parameter   IH_SHARED_WRITE_ADDR_BOUND              = 4095,
    parameter   A_INDIRECT_READ_ADDR_BASE               = 24,
    parameter   A_INDIRECT_WRITE_ADDR_BASE              = 24,
    parameter   B_INDIRECT_READ_ADDR_BASE               = 24,
    parameter   B_INDIRECT_WRITE_ADDR_BASE              = 1048,
    parameter   A_PO_ADDR_BASE                          = 3076,
    parameter   B_PO_ADDR_BASE                          = 3080,
    parameter   DA_PO_ADDR_BASE                         = 3084,
    parameter   DB_PO_ADDR_BASE                         = 3088,
    parameter   DO_ADDR                                 = 3092,
    parameter   PO_INCR_WIDTH                           = 4,
    parameter   PO_ENTRY_COUNT                          = 4,
    parameter   PO_ADDR_WIDTH                           = 2,
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
    parameter   WRITE_RETIME_STAGES                     = 3,

    // How many ports used-up by accelerators
    parameter   ACCELERATOR_READ_PORTS_A                = 2,
    parameter   ACCELERATOR_READ_PORTS_B                = 1,
    parameter   ACCELERATOR_WRITE_PORTS_A               = 2,
    parameter   ACCELERATOR_WRITE_PORTS_B               = 1,

    // Write address to set multiplier signed-ness
    parameter   MULTIPLIER_CONFIG_ADDR                  = 4000,
    parameter   MULTIPLIER_RAMSTYLE                     = "MLAB"
)
(
    input   wire    clock,
    input   wire    test_in,
    output  wire    test_out
);

// --------------------------------------------------------------------

    // Top-level I/O port parameters, with resources used by accelerators subtracted.
    localparam  FREE_READ_PORT_COUNT_A  = IO_PORT_COUNT - ACCELERATOR_READ_PORTS_A;
    localparam  FREE_READ_PORT_COUNT_B  = IO_PORT_COUNT - ACCELERATOR_READ_PORTS_B;
    localparam  FREE_WRITE_PORT_COUNT_A = IO_PORT_COUNT - ACCELERATOR_WRITE_PORTS_A;
    localparam  FREE_WRITE_PORT_COUNT_B = IO_PORT_COUNT - ACCELERATOR_WRITE_PORTS_B;
    localparam  FREE_IO_READ_WIDTH_A    = FREE_READ_PORT_COUNT_A  * WORD_WIDTH;
    localparam  FREE_IO_READ_WIDTH_B    = FREE_READ_PORT_COUNT_B  * WORD_WIDTH;
    localparam  FREE_IO_WRITE_WIDTH_A   = FREE_WRITE_PORT_COUNT_A * WORD_WIDTH;
    localparam  FREE_IO_WRITE_WIDTH_B   = FREE_WRITE_PORT_COUNT_B * WORD_WIDTH;

    // The widths match the port order below for clarity.
    // "* 2" refers to the empty/full bits for both read and write.
    localparam INPUT_WIDTH  = 2 + (FREE_READ_PORT_COUNT_A * 2) + (FREE_READ_PORT_COUNT_B * 2) + FREE_IO_READ_WIDTH_A + FREE_IO_READ_WIDTH_B;
    // "* 2" refers to the enable bits for both read and write.
    localparam OUTPUT_WIDTH = FREE_IO_WRITE_WIDTH_A + FREE_IO_WRITE_WIDTH_B + (FREE_WRITE_PORT_COUNT_A * 2) + (FREE_WRITE_PORT_COUNT_B * 2) + WORD_WIDTH + WRITE_ADDR_WIDTH;

    wire    [INPUT_WIDTH-1:0]   test_input;
    reg     [OUTPUT_WIDTH-1:0]  test_output;

// --------------------------------------------------------------------

    reg                                 A_external      = 0;
    reg                                 B_external      = 0;
    reg  [FREE_READ_PORT_COUNT_A-1:0]   io_read_EF_A    = 0;
    reg  [FREE_READ_PORT_COUNT_B-1:0]   io_read_EF_B    = 0;
    reg  [FREE_READ_PORT_COUNT_A-1:0]   io_write_EF_A   = 0;
    reg  [FREE_READ_PORT_COUNT_B-1:0]   io_write_EF_B   = 0;

    reg  [FREE_IO_WRITE_WIDTH_A-1:0]    io_read_data_A  = 0;
    reg  [FREE_IO_WRITE_WIDTH_B-1:0]    io_read_data_B  = 0;
    wire [FREE_IO_WRITE_WIDTH_A-1:0]    io_write_data_A;
    wire [FREE_IO_WRITE_WIDTH_B-1:0]    io_write_data_B;

    wire [FREE_READ_PORT_COUNT_A-1:0]   io_rden_A;
    wire [FREE_READ_PORT_COUNT_B-1:0]   io_rden_B;
    wire [FREE_READ_PORT_COUNT_A-1:0]   io_wren_A;
    wire [FREE_READ_PORT_COUNT_B-1:0]   io_wren_B;

    wire [WORD_WIDTH-1:0]                   Rb;
    wire [WRITE_ADDR_WIDTH-1:0]             write_addr_Rb;

    always @(*) begin
        {A_external, B_external, io_read_EF_A, io_read_EF_B, io_write_EF_A, io_write_EF_B, io_read_data_A, io_read_data_B} = test_input;
        test_output = {io_write_data_A, io_write_data_B, io_rden_A, io_rden_B, io_wren_A, io_wren_B, Rb, write_addr_Rb};
    end

// --------------------------------------------------------------------
// Test Harness Registers

    harness_input_register
    #(
        .WIDTH  (INPUT_WIDTH)
    )
    i
    (
        .clock  (clock),    
        .in     (test_in),
        .rden   (1'b1),
        .out    (test_input)
    );

    harness_output_register 
    #(
        .WIDTH  (OUTPUT_WIDTH)
    )
    o
    (
        .clock  (clock),
        .in     (test_output),
        .wren   (1'b1),
        .out    (test_out)
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
        .WRITE_RETIME_STAGES        (WRITE_RETIME_STAGES),
        .ACCELERATOR_READ_PORTS_A   (ACCELERATOR_READ_PORTS_A),
        .ACCELERATOR_READ_PORTS_B   (ACCELERATOR_READ_PORTS_B),
        .ACCELERATOR_WRITE_PORTS_A  (ACCELERATOR_WRITE_PORTS_A),
        .ACCELERATOR_WRITE_PORTS_B  (ACCELERATOR_WRITE_PORTS_B),
        .MULTIPLIER_CONFIG_ADDR     (MULTIPLIER_CONFIG_ADDR),
        .MULTIPLIER_RAMSTYLE        (MULTIPLIER_RAMSTYLE)
    )
    DUT
    (
        .clock                      (clock),

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

        .A_external                 (A_external),
        .B_external                 (B_external),

        .Rb                         (Rb),
        .write_addr_Rb              (write_addr_Rb)
    );

endmodule

