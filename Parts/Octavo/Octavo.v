
// Octavo CPU plus basic accelerators and peripherals.
// This set should be fairly constant and form the base architecture
// for SoCs.

`default_nettype none

module Octavo
#(

// --------------------------------------------------------------------------
// Octavo Core Parameters, passed unaltered to Octavo_Core
// Resources used up by connecting accelerators are accounted later.

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
    // Same count and address for both A and B,
    // and read and write ports
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
    parameter   WRITE_RETIME_STAGES                     = 0,

// --------------------------------------------------------------------------
// Accelerator Parameters
// Done this way so we give the true configuration of the Octavo Core, then
// can subtract the I/O resources used by the accelerators.
// If we calculated this internally, the enclosing module would have
// no way to know.

    // How many ports used-up by accelerators
    parameter   ACCELERATOR_READ_PORTS_A                = 0,
    parameter   ACCELERATOR_READ_PORTS_B                = 0,
    parameter   ACCELERATOR_WRITE_PORTS_A               = 0,
    parameter   ACCELERATOR_WRITE_PORTS_B               = 0,

    // Write address to set multiplier signed-ness
    parameter   MULTIPLIER_CONFIG_ADDR                  = 0,
    // Implementation of multithreaded buffers in multiplier pipeline
    parameter   MULTIPLIER_RAMSTYLE                     = "",

// --------------------------------------------------------------------------
// Computed parameters. Do not set at instantiation.
// REPEAT THESE CALCULATIONS IN THE ENCLOSING MODULE TO DETERMINE PORT WIDTHS

    // Top-level I/O port parameters, with resources used by accelerators subtracted.
    parameter   FREE_READ_PORT_COUNT_A  = IO_PORT_COUNT - ACCELERATOR_READ_PORTS_A,
    parameter   FREE_READ_PORT_COUNT_B  = IO_PORT_COUNT - ACCELERATOR_READ_PORTS_B,
    parameter   FREE_WRITE_PORT_COUNT_A = IO_PORT_COUNT - ACCELERATOR_WRITE_PORTS_A,
    parameter   FREE_WRITE_PORT_COUNT_B = IO_PORT_COUNT - ACCELERATOR_WRITE_PORTS_B,
    parameter   FREE_IO_READ_WIDTH_A    = FREE_READ_PORT_COUNT_A  * WORD_WIDTH,
    parameter   FREE_IO_READ_WIDTH_B    = FREE_READ_PORT_COUNT_B  * WORD_WIDTH,
    parameter   FREE_IO_WRITE_WIDTH_A   = FREE_WRITE_PORT_COUNT_A * WORD_WIDTH,
    parameter   FREE_IO_WRITE_WIDTH_B   = FREE_WRITE_PORT_COUNT_B * WORD_WIDTH

)
(

// --------------------------------------------------------------------------
// Ports

    input   wire                                        clock,

    // Data Path
    // External I/O: Empty/Full bits, data, and read/write enables
    input   wire    [FREE_READ_PORT_COUNT_A-1:0]        io_read_EF_A,
    input   wire    [FREE_READ_PORT_COUNT_B-1:0]        io_read_EF_B,
    input   wire    [FREE_WRITE_PORT_COUNT_A-1:0]       io_write_EF_A,
    input   wire    [FREE_WRITE_PORT_COUNT_B-1:0]       io_write_EF_B,

    input   wire    [FREE_IO_READ_WIDTH_A-1:0]          io_read_data_A,
    input   wire    [FREE_IO_READ_WIDTH_B-1:0]          io_read_data_B,
    output  wire    [FREE_IO_WRITE_WIDTH_A-1:0]         io_write_data_A,
    output  wire    [FREE_IO_WRITE_WIDTH_B-1:0]         io_write_data_B,

    output  wire    [FREE_READ_PORT_COUNT_A-1:0]        io_rden_A,
    output  wire    [FREE_READ_PORT_COUNT_B-1:0]        io_rden_B,
    output  wire    [FREE_WRITE_PORT_COUNT_A-1:0]       io_wren_A,
    output  wire    [FREE_WRITE_PORT_COUNT_B-1:0]       io_wren_B,

    // Control Path
    // External branch condition inputs, multithreaded
    input   wire                                        A_external,
    input   wire                                        B_external,

    // Direct Rb output from ALU.
    // Use to drive infrequent write-only destinations for external hardware
    // usually mapped in H address space.
    // (also internally connects Datapath to Controlpath for just that purpose)
    output  wire    [WORD_WIDTH-1:0]                    Rb,
    output  wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_Rb
);

// --------------------------------------------------------------------------
// Common local parameters and constants

    // None for now

// --------------------------------------------------------------------------
// Multiplier Accelerator. Just a plain signed/unsigned threaded multiplier.

    reg multiplier_config_signed = 1'b0;

    always @(*) begin
        multiplier_config_signed = Rb[0]; // 0 is unsigned (also the default)
    end

    wire [WORD_WIDTH-1:0]   multiplier_A;
    wire                    multiplier_A_wren;
    wire [WORD_WIDTH-1:0]   multiplier_B;
    wire                    multiplier_B_wren;
    wire [WORD_WIDTH-1:0]   multiplier_R_low;
    wire [WORD_WIDTH-1:0]   multiplier_R_high;

    Multiplier_Pipeline
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .CONFIG_ADDR        (MULTIPLIER_CONFIG_ADDR),
        .CONFIG_ADDR_WIDTH  (WRITE_ADDR_WIDTH),
        .THREAD_COUNT       (THREAD_COUNT),
        .RAMSTYLE           (MULTIPLIER_RAMSTYLE)
    )
    Multiplier_Pipeline
    (
        .clock              (clock),

        .config_addr        (write_addr_Rb),
        .config_signed      (multiplier_config_signed),
        .config_enable      (1'b1),

        .A                  (multiplier_A),
        .A_wren             (multiplier_A_wren),
        .B                  (multiplier_B),
        .B_wren             (multiplier_B_wren),

        .R_low              (multiplier_R_low),
        .R_high             (multiplier_R_high)
    );

// --------------------------------------------------------------------------
// Accumulator Accelerator. Each thread can write to accumulate, read to clear.

    wire [WORD_WIDTH-1:0]   accumulator_addend;
    wire                    accumulator_write;
    wire [WORD_WIDTH-1:0]   accumulator_total;
    wire                    accumulator_read;

    Accumulator
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .THREAD_COUNT   (THREAD_COUNT)
    )
    Accumulator
    (
        .clock          (clock),
        .write_addend   (accumulator_write),
        .addend         (accumulator_addend),
        .read_total     (accumulator_read),
        .total          (accumulator_total)
    );

// --------------------------------------------------------------------------
// Instantiate the Octavo CPU proper, with accelerator connections
// Accumulators use-up ports starting at zero (the LSB)

    // Placeholders for unused output port bits.
    // verilator lint_off UNUSED
    wire multiplier_rden_A_DUMMY;
    wire multiplier_rden_B_DUMMY;
    // verilator lint_on  UNUSED

    Octavo_Core
    #(
        .WORD_WIDTH                     (WORD_WIDTH),
        .READ_ADDR_WIDTH                (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH               (WRITE_ADDR_WIDTH),
        .MEM_RAMSTYLE                   (MEM_RAMSTYLE),
        .MEM_READ_NEW_DATA              (MEM_READ_NEW_DATA),
        .MEM_INIT_FILE_A                (MEM_INIT_FILE_A),
        .MEM_INIT_FILE_B                (MEM_INIT_FILE_B),
        .MEM_READ_BASE_ADDR_A           (MEM_READ_BASE_ADDR_A),
        .MEM_READ_BOUND_ADDR_A          (MEM_READ_BOUND_ADDR_A),
        .MEM_WRITE_BASE_ADDR_A          (MEM_WRITE_BASE_ADDR_A),
        .MEM_WRITE_BOUND_ADDR_A         (MEM_WRITE_BOUND_ADDR_A),
        .MEM_READ_BASE_ADDR_B           (MEM_READ_BASE_ADDR_B),
        .MEM_READ_BOUND_ADDR_B          (MEM_READ_BOUND_ADDR_B),
        .MEM_WRITE_BASE_ADDR_B          (MEM_WRITE_BASE_ADDR_B),
        .MEM_WRITE_BOUND_ADDR_B         (MEM_WRITE_BOUND_ADDR_B),
        .S_WRITE_ADDR                   (S_WRITE_ADDR),
        .S_RAMSTYLE                     (S_RAMSTYLE),
        .S_READ_NEW_DATA                (S_READ_NEW_DATA),
        .IO_PORT_COUNT                  (IO_PORT_COUNT),
        .IO_PORT_BASE_ADDR              (IO_PORT_BASE_ADDR),
        .IO_PORT_ADDR_WIDTH             (IO_PORT_ADDR_WIDTH),
        .A_SHARED_READ_ADDR_BASE        (A_SHARED_READ_ADDR_BASE),
        .A_SHARED_READ_ADDR_BOUND       (A_SHARED_READ_ADDR_BOUND),
        .A_SHARED_WRITE_ADDR_BASE       (A_SHARED_WRITE_ADDR_BASE),
        .A_SHARED_WRITE_ADDR_BOUND      (A_SHARED_WRITE_ADDR_BOUND),
        .B_SHARED_READ_ADDR_BASE        (B_SHARED_READ_ADDR_BASE),
        .B_SHARED_READ_ADDR_BOUND       (B_SHARED_READ_ADDR_BOUND),
        .B_SHARED_WRITE_ADDR_BASE       (B_SHARED_WRITE_ADDR_BASE),
        .B_SHARED_WRITE_ADDR_BOUND      (B_SHARED_WRITE_ADDR_BOUND),
        .IH_SHARED_WRITE_ADDR_BASE      (IH_SHARED_WRITE_ADDR_BASE),
        .IH_SHARED_WRITE_ADDR_BOUND     (IH_SHARED_WRITE_ADDR_BOUND),
        .A_INDIRECT_READ_ADDR_BASE      (A_INDIRECT_READ_ADDR_BASE),
        .A_INDIRECT_WRITE_ADDR_BASE     (A_INDIRECT_WRITE_ADDR_BASE),
        .B_INDIRECT_READ_ADDR_BASE      (B_INDIRECT_READ_ADDR_BASE),
        .B_INDIRECT_WRITE_ADDR_BASE     (B_INDIRECT_WRITE_ADDR_BASE),
        .A_PO_ADDR_BASE                 (A_PO_ADDR_BASE),
        .B_PO_ADDR_BASE                 (B_PO_ADDR_BASE),
        .DA_PO_ADDR_BASE                (DA_PO_ADDR_BASE),
        .DB_PO_ADDR_BASE                (DB_PO_ADDR_BASE),
        .DO_ADDR                        (DO_ADDR),
        .PO_INCR_WIDTH                  (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT                 (PO_ENTRY_COUNT),
        .PO_ADDR_WIDTH                  (PO_ADDR_WIDTH),
        .DO_INIT_FILE                   (DO_INIT_FILE),
        .AD_RAMSTYLE                    (AD_RAMSTYLE),
        .AD_READ_NEW_DATA               (AD_READ_NEW_DATA),
        .PC_WIDTH                       (PC_WIDTH),
        .BRANCH_COUNT                   (BRANCH_COUNT),
        .FC_RAMSTYLE                    (FC_RAMSTYLE),
        .FC_READ_NEW_DATA               (FC_READ_NEW_DATA),
        .PC_INIT_FILE                   (PC_INIT_FILE),
        .PC_PREV_INIT_FILE              (PC_PREV_INIT_FILE),
        .OPCODE_WIDTH                   (OPCODE_WIDTH),
        .D_OPERAND_WIDTH                (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH                (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH                (B_OPERAND_WIDTH),
        .IM_WORD_WIDTH                  (IM_WORD_WIDTH),
        .IM_ADDR_WIDTH                  (IM_ADDR_WIDTH),
        .IM_READ_NEW                    (IM_READ_NEW),
        .IM_DEPTH                       (IM_DEPTH),
        .IM_RAMSTYLE                    (IM_RAMSTYLE),
        .IM_INIT_FILE                   (IM_INIT_FILE),
        .OD_WORD_WIDTH                  (OD_WORD_WIDTH),
        .OD_ADDR_WIDTH                  (OD_ADDR_WIDTH),
        .OD_READ_NEW                    (OD_READ_NEW),
        .OD_THREAD_DEPTH                (OD_THREAD_DEPTH),
        .OD_RAMSTYLE                    (OD_RAMSTYLE),
        .OD_INIT_FILE                   (OD_INIT_FILE),
        .OD_INITIAL_THREAD_READ         (OD_INITIAL_THREAD_READ),
        .OD_INITIAL_THREAD_WRITE        (OD_INITIAL_THREAD_WRITE),
        .FC_BASE_ADDR_WRITE             (FC_BASE_ADDR_WRITE),
        .IM_BASE_ADDR_WRITE             (IM_BASE_ADDR_WRITE),
        .OD_BASE_ADDR_WRITE             (OD_BASE_ADDR_WRITE),
        .THREAD_COUNT                   (THREAD_COUNT),
        .THREAD_COUNT_WIDTH             (THREAD_COUNT_WIDTH),
        .WRITE_RETIME_STAGES            (WRITE_RETIME_STAGES)
    )
    Octavo_Core
    (
        .clock              (clock),

        // Ports start at the right (LSB)
        // The multiplier output is always valid (read full)
        // The multiplier input is always ready (empty write)
        // The accumulator output is always valid (read full)
        // The accumulator input is always ready (empty write)
        .io_read_EF_A       ({io_read_EF_A,     1'b1,               1'b1}),
        .io_read_EF_B       ({io_read_EF_B,                         1'b1}),
        .io_write_EF_A      ({io_write_EF_A,    1'b0,               1'b0}),
        .io_write_EF_B      ({io_write_EF_B,                        1'b0}),

        .io_read_data_A     ({io_read_data_A,   accumulator_total,  multiplier_R_low}),
        .io_read_data_B     ({io_read_data_B,                       multiplier_R_high}),
        .io_write_data_A    ({io_write_data_A,  accumulator_addend, multiplier_A}),
        .io_write_data_B    ({io_write_data_B,                      multiplier_B}),

        .io_rden_A          ({io_rden_A,        accumulator_read,   multiplier_rden_A_DUMMY}),
        .io_rden_B          ({io_rden_B,                            multiplier_rden_B_DUMMY}),
        .io_wren_A          ({io_wren_A,        accumulator_write,  multiplier_A_wren}),
        .io_wren_B          ({io_wren_B,                            multiplier_B_wren}),

        .A_external         (A_external),
        .B_external         (B_external),

        .Rb                 (Rb),
        .write_addr_Rb      (write_addr_Rb)
    );

endmodule

