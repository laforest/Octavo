
// SIMD Octavo CPU. I/O Lines are flat vectors of words.
// Note that SIMD ports may have a different word width from Scalar.
// Wrap as necessary to break-out I/O ports and set parameters.

module SIMD
#(
    parameter       ALU_WORD_WIDTH                      = 0,
    parameter       SIMD_ALU_WORD_WIDTH                 = 0,

    parameter       INSTR_WIDTH                         = 0,
    parameter       OPCODE_WIDTH                        = 0,
    parameter       D_OPERAND_WIDTH                     = 0,
    parameter       A_OPERAND_WIDTH                     = 0,
    parameter       B_OPERAND_WIDTH                     = 0,

// -----------------------------------------------------------

    parameter       A_WRITE_ADDR_OFFSET                 = 0,
    parameter       A_WORD_WIDTH                        = 0,
    parameter       A_ADDR_WIDTH                        = 0,
    parameter       A_DEPTH                             = 0,
    parameter       A_RAMSTYLE                          = "",
    parameter       A_INIT_FILE                         = "",
    parameter       A_IO_READ_PORT_COUNT                = 0,
    parameter       A_IO_READ_PORT_BASE_ADDR            = 0,
    parameter       A_IO_READ_PORT_ADDR_WIDTH           = 0,
    parameter       A_IO_WRITE_PORT_COUNT               = 0,
    parameter       A_IO_WRITE_PORT_BASE_ADDR           = 0,
    parameter       A_IO_WRITE_PORT_ADDR_WIDTH          = 0,

// -----------------------------------------------------------

    parameter       SIMD_A_WRITE_ADDR_OFFSET            = 0,
    parameter       SIMD_A_WORD_WIDTH                   = 0,
    parameter       SIMD_A_ADDR_WIDTH                   = 0,
    parameter       SIMD_A_DEPTH                        = 0,
    parameter       SIMD_A_RAMSTYLE                     = "",
    parameter       SIMD_A_INIT_FILE                    = "",
    parameter       SIMD_A_IO_READ_PORT_COUNT           = 0,
    parameter       SIMD_A_IO_READ_PORT_BASE_ADDR       = 0,
    parameter       SIMD_A_IO_READ_PORT_ADDR_WIDTH      = 0,
    parameter       SIMD_A_IO_WRITE_PORT_COUNT          = 0,
    parameter       SIMD_A_IO_WRITE_PORT_BASE_ADDR      = 0,
    parameter       SIMD_A_IO_WRITE_PORT_ADDR_WIDTH     = 0,

// -----------------------------------------------------------

    parameter       B_WRITE_ADDR_OFFSET                 = 0,
    parameter       B_WORD_WIDTH                        = 0,
    parameter       B_ADDR_WIDTH                        = 0,
    parameter       B_DEPTH                             = 0,
    parameter       B_RAMSTYLE                          = "",
    parameter       B_INIT_FILE                         = "",
    parameter       B_IO_READ_PORT_COUNT                = 0,
    parameter       B_IO_READ_PORT_BASE_ADDR            = 0,
    parameter       B_IO_READ_PORT_ADDR_WIDTH           = 0,
    parameter       B_IO_WRITE_PORT_COUNT               = 0,
    parameter       B_IO_WRITE_PORT_BASE_ADDR           = 0,
    parameter       B_IO_WRITE_PORT_ADDR_WIDTH          = 0,

// -----------------------------------------------------------

    parameter       SIMD_B_WRITE_ADDR_OFFSET            = 0,
    parameter       SIMD_B_WORD_WIDTH                   = 0,
    parameter       SIMD_B_ADDR_WIDTH                   = 0,
    parameter       SIMD_B_DEPTH                        = 0,
    parameter       SIMD_B_RAMSTYLE                     = "",
    parameter       SIMD_B_INIT_FILE                    = "",
    parameter       SIMD_B_IO_READ_PORT_COUNT           = 0,
    parameter       SIMD_B_IO_READ_PORT_BASE_ADDR       = 0,
    parameter       SIMD_B_IO_READ_PORT_ADDR_WIDTH      = 0,
    parameter       SIMD_B_IO_WRITE_PORT_COUNT          = 0,
    parameter       SIMD_B_IO_WRITE_PORT_BASE_ADDR      = 0,
    parameter       SIMD_B_IO_WRITE_PORT_ADDR_WIDTH     = 0,

// -----------------------------------------------------------

    parameter       I_WRITE_ADDR_OFFSET                 = 0,
    parameter       I_WORD_WIDTH                        = 0,
    parameter       I_ADDR_WIDTH                        = 0,
    parameter       I_DEPTH                             = 0,
    parameter       I_RAMSTYLE                          = "",
    parameter       I_INIT_FILE                         = "",

// -----------------------------------------------------------

    parameter       H_WRITE_ADDR_OFFSET                 = 0,
    parameter       H_WORD_WIDTH                        = 0,
    parameter       H_ADDR_WIDTH                        = 0,
    parameter       H_DEPTH                             = 0,

// -----------------------------------------------------------

    parameter       SIMD_H_WRITE_ADDR_OFFSET            = 0,
    parameter       SIMD_H_WORD_WIDTH                   = 0,
    parameter       SIMD_H_ADDR_WIDTH                   = 0,
    parameter       SIMD_H_DEPTH                        = 0,

// -----------------------------------------------------------

    parameter       PC_RAMSTYLE                         = "",
    parameter       PC_INIT_FILE                        = "",
    parameter       THREAD_COUNT                        = 0, 
    parameter       THREAD_ADDR_WIDTH                   = 0, 

// -----------------------------------------------------------

    parameter       PC_PIPELINE_DEPTH                   = 0,
    parameter       I_TAP_PIPELINE_DEPTH                = 0,
    parameter       TAP_AB_PIPELINE_DEPTH               = 0,
    parameter       AB_READ_PIPELINE_DEPTH              = 0,
    parameter       AB_ALU_PIPELINE_DEPTH               = 0,

// -----------------------------------------------------------

    parameter       LOGIC_OPCODE_WIDTH                  = 0,
    parameter       ADDSUB_CARRY_SELECT                 = 0,
    parameter       MULT_DOUBLE_PIPE                    = 0,
    parameter       MULT_HETEROGENEOUS                  = 0,    
    parameter       MULT_USE_DSP                        = 0,

// -----------------------------------------------------------

    parameter       SIMD_ADDSUB_CARRY_SELECT            = 0,
    parameter       SIMD_MULT_DOUBLE_PIPE               = 0,
    parameter       SIMD_MULT_HETEROGENEOUS             = 0,    
    parameter       SIMD_MULT_USE_DSP                   = 0,

// -----------------------------------------------------------

    parameter       SIMD_LANE_COUNT                     = 0,

// -----------------------------------------------------------

    parameter   ADDRESS_TRANSLATION_INITIAL_THREAD          = 0,

// -----------------------------------------------------------

    parameter   A_DEFAULT_OFFSET_WRITE_WORD_OFFSET          = 0,
    parameter   A_DEFAULT_OFFSET_WRITE_ADDR_OFFSET          = 0,
    parameter   A_DEFAULT_OFFSET_WORD_WIDTH                 = 0,
    parameter   A_DEFAULT_OFFSET_ADDR_WIDTH                 = 0,
    parameter   A_DEFAULT_OFFSET_DEPTH                      = 0,
    parameter   A_DEFAULT_OFFSET_RAMSTYLE                   = 0,
    parameter   A_DEFAULT_OFFSET_INIT_FILE                  = 0,

    parameter   A_PO_INC_READ_BASE_ADDR                     = 0,
    parameter   A_PO_INC_COUNT                              = 0,
    parameter   A_PO_INC_COUNT_ADDR_WIDTH                   = 0,

    parameter   A_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET      = 0,
    parameter   A_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET      = 0,
    parameter   A_PROGRAMMED_OFFSETS_WORD_WIDTH             = 0,
    parameter   A_PROGRAMMED_OFFSETS_ADDR_WIDTH             = 0,
    parameter   A_PROGRAMMED_OFFSETS_DEPTH                  = 0,
    parameter   A_PROGRAMMED_OFFSETS_RAMSTYLE               = 0,
    parameter   A_PROGRAMMED_OFFSETS_INIT_FILE              = 0,

    parameter   A_INCREMENTS_WRITE_WORD_OFFSET              = 0,
    parameter   A_INCREMENTS_WRITE_ADDR_OFFSET              = 0,
    parameter   A_INCREMENTS_WORD_WIDTH                     = 0,
    parameter   A_INCREMENTS_ADDR_WIDTH                     = 0,
    parameter   A_INCREMENTS_DEPTH                          = 0,
    parameter   A_INCREMENTS_RAMSTYLE                       = 0,
    parameter   A_INCREMENTS_INIT_FILE                      = 0,

// -----------------------------------------------------------

    parameter   B_DEFAULT_OFFSET_WRITE_WORD_OFFSET          = 0,
    parameter   B_DEFAULT_OFFSET_WRITE_ADDR_OFFSET          = 0,
    parameter   B_DEFAULT_OFFSET_WORD_WIDTH                 = 0,
    parameter   B_DEFAULT_OFFSET_ADDR_WIDTH                 = 0,
    parameter   B_DEFAULT_OFFSET_DEPTH                      = 0,
    parameter   B_DEFAULT_OFFSET_RAMSTYLE                   = 0,
    parameter   B_DEFAULT_OFFSET_INIT_FILE                  = 0,

    parameter   B_PO_INC_READ_BASE_ADDR                     = 0,
    parameter   B_PO_INC_COUNT                              = 0,
    parameter   B_PO_INC_COUNT_ADDR_WIDTH                   = 0,

    parameter   B_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET      = 0,
    parameter   B_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET      = 0,
    parameter   B_PROGRAMMED_OFFSETS_WORD_WIDTH             = 0,
    parameter   B_PROGRAMMED_OFFSETS_ADDR_WIDTH             = 0,
    parameter   B_PROGRAMMED_OFFSETS_DEPTH                  = 0,
    parameter   B_PROGRAMMED_OFFSETS_RAMSTYLE               = 0,
    parameter   B_PROGRAMMED_OFFSETS_INIT_FILE              = 0,

    parameter   B_INCREMENTS_WRITE_WORD_OFFSET              = 0,
    parameter   B_INCREMENTS_WRITE_ADDR_OFFSET              = 0,
    parameter   B_INCREMENTS_WORD_WIDTH                     = 0,
    parameter   B_INCREMENTS_ADDR_WIDTH                     = 0,
    parameter   B_INCREMENTS_DEPTH                          = 0,
    parameter   B_INCREMENTS_RAMSTYLE                       = 0,
    parameter   B_INCREMENTS_INIT_FILE                      = 0,

// -----------------------------------------------------------

    parameter   D_DEFAULT_OFFSET_WRITE_WORD_OFFSET          = 0,
    parameter   D_DEFAULT_OFFSET_WRITE_ADDR_OFFSET          = 0,
    parameter   D_DEFAULT_OFFSET_WORD_WIDTH                 = 0,
    parameter   D_DEFAULT_OFFSET_ADDR_WIDTH                 = 0,
    parameter   D_DEFAULT_OFFSET_DEPTH                      = 0,
    parameter   D_DEFAULT_OFFSET_RAMSTYLE                   = 0,
    parameter   D_DEFAULT_OFFSET_INIT_FILE                  = 0,

    parameter   D_PO_INC_READ_BASE_ADDR                     = 0,
    parameter   D_PO_INC_COUNT                              = 0,
    parameter   D_PO_INC_COUNT_ADDR_WIDTH                   = 0,

    parameter   D_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET      = 0,
    parameter   D_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET      = 0,
    parameter   D_PROGRAMMED_OFFSETS_WORD_WIDTH             = 0,
    parameter   D_PROGRAMMED_OFFSETS_ADDR_WIDTH             = 0,
    parameter   D_PROGRAMMED_OFFSETS_DEPTH                  = 0,
    parameter   D_PROGRAMMED_OFFSETS_RAMSTYLE               = 0,
    parameter   D_PROGRAMMED_OFFSETS_INIT_FILE              = 0,

    parameter   D_INCREMENTS_WRITE_WORD_OFFSET              = 0,
    parameter   D_INCREMENTS_WRITE_ADDR_OFFSET              = 0,
    parameter   D_INCREMENTS_WORD_WIDTH                     = 0,
    parameter   D_INCREMENTS_ADDR_WIDTH                     = 0,
    parameter   D_INCREMENTS_DEPTH                          = 0,
    parameter   D_INCREMENTS_RAMSTYLE                       = 0,
    parameter   D_INCREMENTS_INIT_FILE                      = 0,

// -----------------------------------------------------------

    parameter   ORIGIN_WRITE_WORD_OFFSET        = 0,
    parameter   ORIGIN_WRITE_ADDR_OFFSET        = 0,
    parameter   ORIGIN_WORD_WIDTH               = 0,
    parameter   ORIGIN_ADDR_WIDTH               = 0,
    parameter   ORIGIN_DEPTH                    = 0,
    parameter   ORIGIN_RAMSTYLE                 = 0,
    parameter   ORIGIN_INIT_FILE                = 0,

// -----------------------------------------------------------

    parameter   BRANCH_COUNT                    = 0,

// -----------------------------------------------------------

    parameter   DESTINATION_WRITE_WORD_OFFSET   = 0,
    parameter   DESTINATION_WRITE_ADDR_OFFSET   = 0,
    parameter   DESTINATION_WORD_WIDTH          = 0,
    parameter   DESTINATION_ADDR_WIDTH          = 0,
    parameter   DESTINATION_DEPTH               = 0,
    parameter   DESTINATION_RAMSTYLE            = 0,
    parameter   DESTINATION_INIT_FILE           = 0,

// -----------------------------------------------------------

    parameter   CONDITION_WRITE_WORD_OFFSET     = 0,
    parameter   CONDITION_WRITE_ADDR_OFFSET     = 0,
    parameter   CONDITION_WORD_WIDTH            = 0,
    parameter   CONDITION_ADDR_WIDTH            = 0,
    parameter   CONDITION_DEPTH                 = 0,
    parameter   CONDITION_RAMSTYLE              = 0,
    parameter   CONDITION_INIT_FILE             = 0,

// -----------------------------------------------------------

    parameter   PREDICTION_WRITE_WORD_OFFSET        = 0,
    parameter   PREDICTION_WRITE_ADDR_OFFSET        = 0,
    parameter   PREDICTION_WORD_WIDTH               = 0,
    parameter   PREDICTION_ADDR_WIDTH               = 0,
    parameter   PREDICTION_DEPTH                    = 0,
    parameter   PREDICTION_RAMSTYLE                 = 0,
    parameter   PREDICTION_INIT_FILE                = 0,

// -----------------------------------------------------------

    parameter   PREDICTION_ENABLE_WRITE_WORD_OFFSET = 0,
    parameter   PREDICTION_ENABLE_WRITE_ADDR_OFFSET = 0,
    parameter   PREDICTION_ENABLE_WORD_WIDTH        = 0,
    parameter   PREDICTION_ENABLE_ADDR_WIDTH        = 0,
    parameter   PREDICTION_ENABLE_DEPTH             = 0,
    parameter   PREDICTION_ENABLE_RAMSTYLE          = 0,
    parameter   PREDICTION_ENABLE_INIT_FILE         = 0,

// -----------------------------------------------------------

    parameter   FLAGS_WORD_WIDTH                = 0,
    parameter   FLAGS_ADDR_WIDTH                = 0
)
(
    input   wire                                                                               clock,
    input   wire                                                                               half_clock,

    // Memory write enables for external control by accelerators
    input   wire                                                                               I_wren_other,
    input   wire                                                                               A_wren_other,
    input   wire                                                                               B_wren_other,
    input   wire    [SIMD_LANE_COUNT-1:0]                                                      SIMD_A_wren_other,
    input   wire    [SIMD_LANE_COUNT-1:0]                                                      SIMD_B_wren_other,

    // ALU AddSub carry-in/out for external control by accelerators                            
    input   wire                                                                               ALU_c_in,
    output  wire                                                                               ALU_c_out,
    input   wire    [SIMD_LANE_COUNT-1:0]                                                      SIMD_ALU_c_in,
    output  wire    [SIMD_LANE_COUNT-1:0]                                                      SIMD_ALU_c_out,

    // Scalar I/O
    input   wire    [(               A_IO_READ_PORT_COUNT)-1:0]                                A_io_in_EF,
    output  wire    [(               A_IO_READ_PORT_COUNT)-1:0]                                A_io_rden,
    input   wire    [(A_WORD_WIDTH * A_IO_READ_PORT_COUNT)-1:0]                                A_io_in,
    input   wire    [(               A_IO_WRITE_PORT_COUNT)-1:0]                               A_io_out_EF,
    output  wire    [(               A_IO_WRITE_PORT_COUNT)-1:0]                               A_io_wren,
    output  wire    [(A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT)-1:0]                               A_io_out,

    input   wire    [(               B_IO_READ_PORT_COUNT)-1:0]                                B_io_in_EF,
    output  wire    [(               B_IO_READ_PORT_COUNT)-1:0]                                B_io_rden,
    input   wire    [(B_WORD_WIDTH * B_IO_READ_PORT_COUNT)-1:0]                                B_io_in,
    input   wire    [(               B_IO_WRITE_PORT_COUNT)-1:0]                               B_io_out_EF,
    output  wire    [(               B_IO_WRITE_PORT_COUNT)-1:0]                               B_io_wren,
    output  wire    [(B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT)-1:0]                               B_io_out,

    // SIMD I/O
    input   wire    [(                    SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_in_EF,
    output  wire    [(                    SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_rden,
    input   wire    [(SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_in,
    input   wire    [(                    SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_out_EF,
    output  wire    [(                    SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_wren,
    output  wire    [(SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_out,

    input   wire    [(                    SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_in_EF,
    output  wire    [(                    SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_rden,
    input   wire    [(SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_in,
    input   wire    [(                    SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_out_EF,
    output  wire    [(                    SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_wren,
    output  wire    [(SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_out
);

// -----------------------------------------------------------

    // Instruction and control common to all Datapaths
    wire    [INSTR_WIDTH-1:0]   I_read_data;
    wire    [INSTR_WIDTH-1:0]   I_read_data_translated;
    wire                        cancel;

    Scalar
    #(
        .ALU_WORD_WIDTH             (ALU_WORD_WIDTH),

        .INSTR_WIDTH                (INSTR_WIDTH),
        .OPCODE_WIDTH               (OPCODE_WIDTH),
        .D_OPERAND_WIDTH            (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH            (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH            (B_OPERAND_WIDTH),

        .A_WRITE_ADDR_OFFSET        (A_WRITE_ADDR_OFFSET),
        .A_WORD_WIDTH               (A_WORD_WIDTH),
        .A_ADDR_WIDTH               (A_ADDR_WIDTH),
        .A_DEPTH                    (A_DEPTH),
        .A_RAMSTYLE                 (A_RAMSTYLE),
        .A_INIT_FILE                (A_INIT_FILE),
        .A_IO_READ_PORT_COUNT       (A_IO_READ_PORT_COUNT),
        .A_IO_READ_PORT_BASE_ADDR   (A_IO_READ_PORT_BASE_ADDR),
        .A_IO_READ_PORT_ADDR_WIDTH  (A_IO_READ_PORT_ADDR_WIDTH),
        .A_IO_WRITE_PORT_COUNT      (A_IO_WRITE_PORT_COUNT),
        .A_IO_WRITE_PORT_BASE_ADDR  (A_IO_WRITE_PORT_BASE_ADDR),
        .A_IO_WRITE_PORT_ADDR_WIDTH (A_IO_WRITE_PORT_ADDR_WIDTH),

        .B_WRITE_ADDR_OFFSET        (B_WRITE_ADDR_OFFSET),
        .B_WORD_WIDTH               (B_WORD_WIDTH),
        .B_ADDR_WIDTH               (B_ADDR_WIDTH),
        .B_DEPTH                    (B_DEPTH),
        .B_RAMSTYLE                 (B_RAMSTYLE),
        .B_INIT_FILE                (B_INIT_FILE),
        .B_IO_READ_PORT_COUNT       (B_IO_READ_PORT_COUNT),
        .B_IO_READ_PORT_BASE_ADDR   (B_IO_READ_PORT_BASE_ADDR),
        .B_IO_READ_PORT_ADDR_WIDTH  (B_IO_READ_PORT_ADDR_WIDTH),
        .B_IO_WRITE_PORT_COUNT      (B_IO_WRITE_PORT_COUNT),
        .B_IO_WRITE_PORT_BASE_ADDR  (B_IO_WRITE_PORT_BASE_ADDR),
        .B_IO_WRITE_PORT_ADDR_WIDTH (B_IO_WRITE_PORT_ADDR_WIDTH),

        .I_WRITE_ADDR_OFFSET        (I_WRITE_ADDR_OFFSET),
        .I_WORD_WIDTH               (I_WORD_WIDTH),
        .I_ADDR_WIDTH               (I_ADDR_WIDTH),
        .I_DEPTH                    (I_DEPTH),
        .I_RAMSTYLE                 (I_RAMSTYLE),
        .I_INIT_FILE                (I_INIT_FILE),

        .H_WRITE_ADDR_OFFSET        (H_WRITE_ADDR_OFFSET),
        .H_WORD_WIDTH               (H_WORD_WIDTH),
        .H_ADDR_WIDTH               (H_ADDR_WIDTH),
        .H_DEPTH                    (H_DEPTH),

        .PC_RAMSTYLE                (PC_RAMSTYLE),
        .PC_INIT_FILE               (PC_INIT_FILE),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH          (THREAD_ADDR_WIDTH),

        .PC_PIPELINE_DEPTH          (PC_PIPELINE_DEPTH),
        .I_TAP_PIPELINE_DEPTH       (I_TAP_PIPELINE_DEPTH),
        .TAP_AB_PIPELINE_DEPTH      (TAP_AB_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH     (AB_READ_PIPELINE_DEPTH),
        .AB_ALU_PIPELINE_DEPTH      (AB_ALU_PIPELINE_DEPTH),

        .LOGIC_OPCODE_WIDTH         (LOGIC_OPCODE_WIDTH),
        .ADDSUB_CARRY_SELECT        (ADDSUB_CARRY_SELECT),
        .MULT_DOUBLE_PIPE           (MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS         (MULT_HETEROGENEOUS),
        .MULT_USE_DSP               (MULT_USE_DSP),

        .ADDRESS_TRANSLATION_INITIAL_THREAD         (ADDRESS_TRANSLATION_INITIAL_THREAD),

        .A_DEFAULT_OFFSET_WRITE_WORD_OFFSET         (A_DEFAULT_OFFSET_WRITE_WORD_OFFSET),
        .A_DEFAULT_OFFSET_WRITE_ADDR_OFFSET         (A_DEFAULT_OFFSET_WRITE_ADDR_OFFSET),
        .A_DEFAULT_OFFSET_WORD_WIDTH                (A_DEFAULT_OFFSET_WORD_WIDTH),
        .A_DEFAULT_OFFSET_ADDR_WIDTH                (A_DEFAULT_OFFSET_ADDR_WIDTH),
        .A_DEFAULT_OFFSET_DEPTH                     (A_DEFAULT_OFFSET_DEPTH),
        .A_DEFAULT_OFFSET_RAMSTYLE                  (A_DEFAULT_OFFSET_RAMSTYLE),
        .A_DEFAULT_OFFSET_INIT_FILE                 (A_DEFAULT_OFFSET_INIT_FILE),

        .A_PO_INC_READ_BASE_ADDR                    (A_PO_INC_READ_BASE_ADDR),
        .A_PO_INC_COUNT                             (A_PO_INC_COUNT),
        .A_PO_INC_COUNT_ADDR_WIDTH                  (A_PO_INC_COUNT_ADDR_WIDTH),

        .A_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET     (A_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET),
        .A_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET     (A_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET),
        .A_PROGRAMMED_OFFSETS_WORD_WIDTH            (A_PROGRAMMED_OFFSETS_WORD_WIDTH),
        .A_PROGRAMMED_OFFSETS_ADDR_WIDTH            (A_PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .A_PROGRAMMED_OFFSETS_DEPTH                 (A_PROGRAMMED_OFFSETS_DEPTH),
        .A_PROGRAMMED_OFFSETS_RAMSTYLE              (A_PROGRAMMED_OFFSETS_RAMSTYLE),
        .A_PROGRAMMED_OFFSETS_INIT_FILE             (A_PROGRAMMED_OFFSETS_INIT_FILE),

        .A_INCREMENTS_WRITE_WORD_OFFSET             (A_INCREMENTS_WRITE_WORD_OFFSET),
        .A_INCREMENTS_WRITE_ADDR_OFFSET             (A_INCREMENTS_WRITE_ADDR_OFFSET),
        .A_INCREMENTS_WORD_WIDTH                    (A_INCREMENTS_WORD_WIDTH),
        .A_INCREMENTS_ADDR_WIDTH                    (A_INCREMENTS_ADDR_WIDTH),
        .A_INCREMENTS_DEPTH                         (A_INCREMENTS_DEPTH),
        .A_INCREMENTS_RAMSTYLE                      (A_INCREMENTS_RAMSTYLE),
        .A_INCREMENTS_INIT_FILE                     (A_INCREMENTS_INIT_FILE),

        .B_DEFAULT_OFFSET_WRITE_WORD_OFFSET         (B_DEFAULT_OFFSET_WRITE_WORD_OFFSET),
        .B_DEFAULT_OFFSET_WRITE_ADDR_OFFSET         (B_DEFAULT_OFFSET_WRITE_ADDR_OFFSET),
        .B_DEFAULT_OFFSET_WORD_WIDTH                (B_DEFAULT_OFFSET_WORD_WIDTH),
        .B_DEFAULT_OFFSET_ADDR_WIDTH                (B_DEFAULT_OFFSET_ADDR_WIDTH),
        .B_DEFAULT_OFFSET_DEPTH                     (B_DEFAULT_OFFSET_DEPTH),
        .B_DEFAULT_OFFSET_RAMSTYLE                  (B_DEFAULT_OFFSET_RAMSTYLE),
        .B_DEFAULT_OFFSET_INIT_FILE                 (B_DEFAULT_OFFSET_INIT_FILE),

        .B_PO_INC_READ_BASE_ADDR                    (B_PO_INC_READ_BASE_ADDR),
        .B_PO_INC_COUNT                             (B_PO_INC_COUNT),
        .B_PO_INC_COUNT_ADDR_WIDTH                  (B_PO_INC_COUNT_ADDR_WIDTH),

        .B_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET     (B_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET),
        .B_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET     (B_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET),
        .B_PROGRAMMED_OFFSETS_WORD_WIDTH            (B_PROGRAMMED_OFFSETS_WORD_WIDTH),
        .B_PROGRAMMED_OFFSETS_ADDR_WIDTH            (B_PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .B_PROGRAMMED_OFFSETS_DEPTH                 (B_PROGRAMMED_OFFSETS_DEPTH),
        .B_PROGRAMMED_OFFSETS_RAMSTYLE              (B_PROGRAMMED_OFFSETS_RAMSTYLE),
        .B_PROGRAMMED_OFFSETS_INIT_FILE             (B_PROGRAMMED_OFFSETS_INIT_FILE),

        .B_INCREMENTS_WRITE_WORD_OFFSET             (B_INCREMENTS_WRITE_WORD_OFFSET),
        .B_INCREMENTS_WRITE_ADDR_OFFSET             (B_INCREMENTS_WRITE_ADDR_OFFSET),
        .B_INCREMENTS_WORD_WIDTH                    (B_INCREMENTS_WORD_WIDTH),
        .B_INCREMENTS_ADDR_WIDTH                    (B_INCREMENTS_ADDR_WIDTH),
        .B_INCREMENTS_DEPTH                         (B_INCREMENTS_DEPTH),
        .B_INCREMENTS_RAMSTYLE                      (B_INCREMENTS_RAMSTYLE),
        .B_INCREMENTS_INIT_FILE                     (B_INCREMENTS_INIT_FILE),

        .D_DEFAULT_OFFSET_WRITE_WORD_OFFSET         (D_DEFAULT_OFFSET_WRITE_WORD_OFFSET),
        .D_DEFAULT_OFFSET_WRITE_ADDR_OFFSET         (D_DEFAULT_OFFSET_WRITE_ADDR_OFFSET),
        .D_DEFAULT_OFFSET_WORD_WIDTH                (D_DEFAULT_OFFSET_WORD_WIDTH),
        .D_DEFAULT_OFFSET_ADDR_WIDTH                (D_DEFAULT_OFFSET_ADDR_WIDTH),
        .D_DEFAULT_OFFSET_DEPTH                     (D_DEFAULT_OFFSET_DEPTH),
        .D_DEFAULT_OFFSET_RAMSTYLE                  (D_DEFAULT_OFFSET_RAMSTYLE),
        .D_DEFAULT_OFFSET_INIT_FILE                 (D_DEFAULT_OFFSET_INIT_FILE),

        .D_PO_INC_READ_BASE_ADDR                    (D_PO_INC_READ_BASE_ADDR),
        .D_PO_INC_COUNT                             (D_PO_INC_COUNT),
        .D_PO_INC_COUNT_ADDR_WIDTH                  (D_PO_INC_COUNT_ADDR_WIDTH),

        .D_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET     (D_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET),
        .D_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET     (D_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET),
        .D_PROGRAMMED_OFFSETS_WORD_WIDTH            (D_PROGRAMMED_OFFSETS_WORD_WIDTH),
        .D_PROGRAMMED_OFFSETS_ADDR_WIDTH            (D_PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .D_PROGRAMMED_OFFSETS_DEPTH                 (D_PROGRAMMED_OFFSETS_DEPTH),
        .D_PROGRAMMED_OFFSETS_RAMSTYLE              (D_PROGRAMMED_OFFSETS_RAMSTYLE),
        .D_PROGRAMMED_OFFSETS_INIT_FILE             (D_PROGRAMMED_OFFSETS_INIT_FILE),

        .D_INCREMENTS_WRITE_WORD_OFFSET             (D_INCREMENTS_WRITE_WORD_OFFSET),
        .D_INCREMENTS_WRITE_ADDR_OFFSET             (D_INCREMENTS_WRITE_ADDR_OFFSET),
        .D_INCREMENTS_WORD_WIDTH                    (D_INCREMENTS_WORD_WIDTH),
        .D_INCREMENTS_ADDR_WIDTH                    (D_INCREMENTS_ADDR_WIDTH),
        .D_INCREMENTS_DEPTH                         (D_INCREMENTS_DEPTH),
        .D_INCREMENTS_RAMSTYLE                      (D_INCREMENTS_RAMSTYLE),
        .D_INCREMENTS_INIT_FILE                     (D_INCREMENTS_INIT_FILE),

        .ORIGIN_WRITE_WORD_OFFSET                   (ORIGIN_WRITE_WORD_OFFSET),
        .ORIGIN_WRITE_ADDR_OFFSET                   (ORIGIN_WRITE_ADDR_OFFSET),
        .ORIGIN_WORD_WIDTH                          (ORIGIN_WORD_WIDTH),
        .ORIGIN_ADDR_WIDTH                          (ORIGIN_ADDR_WIDTH),
        .ORIGIN_DEPTH                               (ORIGIN_DEPTH),
        .ORIGIN_RAMSTYLE                            (ORIGIN_RAMSTYLE),
        .ORIGIN_INIT_FILE                           (ORIGIN_INIT_FILE),

        .BRANCH_COUNT                               (BRANCH_COUNT),

        .DESTINATION_WRITE_WORD_OFFSET              (DESTINATION_WRITE_WORD_OFFSET),
        .DESTINATION_WRITE_ADDR_OFFSET              (DESTINATION_WRITE_ADDR_OFFSET),
        .DESTINATION_WORD_WIDTH                     (DESTINATION_WORD_WIDTH),
        .DESTINATION_ADDR_WIDTH                     (DESTINATION_ADDR_WIDTH),
        .DESTINATION_DEPTH                          (DESTINATION_DEPTH),
        .DESTINATION_RAMSTYLE                       (DESTINATION_RAMSTYLE),
        .DESTINATION_INIT_FILE                      (DESTINATION_INIT_FILE),

        .CONDITION_WRITE_WORD_OFFSET                (CONDITION_WRITE_WORD_OFFSET),
        .CONDITION_WRITE_ADDR_OFFSET                (CONDITION_WRITE_ADDR_OFFSET),
        .CONDITION_WORD_WIDTH                       (CONDITION_WORD_WIDTH),
        .CONDITION_ADDR_WIDTH                       (CONDITION_ADDR_WIDTH),
        .CONDITION_DEPTH                            (CONDITION_DEPTH),
        .CONDITION_RAMSTYLE                         (CONDITION_RAMSTYLE),
        .CONDITION_INIT_FILE                        (CONDITION_INIT_FILE),

        .PREDICTION_WRITE_WORD_OFFSET               (PREDICTION_WRITE_WORD_OFFSET),       
        .PREDICTION_WRITE_ADDR_OFFSET               (PREDICTION_WRITE_ADDR_OFFSET),
        .PREDICTION_WORD_WIDTH                      (PREDICTION_WORD_WIDTH),
        .PREDICTION_ADDR_WIDTH                      (PREDICTION_ADDR_WIDTH),
        .PREDICTION_DEPTH                           (PREDICTION_DEPTH),
        .PREDICTION_RAMSTYLE                        (PREDICTION_RAMSTYLE),
        .PREDICTION_INIT_FILE                       (PREDICTION_INIT_FILE),
                                            
        .PREDICTION_ENABLE_WRITE_WORD_OFFSET        (PREDICTION_ENABLE_WRITE_WORD_OFFSET),
        .PREDICTION_ENABLE_WRITE_ADDR_OFFSET        (PREDICTION_ENABLE_WRITE_ADDR_OFFSET),
        .PREDICTION_ENABLE_WORD_WIDTH               (PREDICTION_ENABLE_WORD_WIDTH),
        .PREDICTION_ENABLE_ADDR_WIDTH               (PREDICTION_ENABLE_ADDR_WIDTH),
        .PREDICTION_ENABLE_DEPTH                    (PREDICTION_ENABLE_DEPTH),
        .PREDICTION_ENABLE_RAMSTYLE                 (PREDICTION_ENABLE_RAMSTYLE),
        .PREDICTION_ENABLE_INIT_FILE                (PREDICTION_ENABLE_INIT_FILE),

        .FLAGS_WORD_WIDTH                           (FLAGS_WORD_WIDTH),
        .FLAGS_ADDR_WIDTH                           (FLAGS_ADDR_WIDTH)
    )
    Scalar
    (
        .clock                      (clock),
        .half_clock                 (half_clock),

        .I_wren_other               (I_wren_other),
        .A_wren_other               (A_wren_other),
        .B_wren_other               (B_wren_other),
        
        .ALU_c_in                   (ALU_c_in),
        .ALU_c_out                  (ALU_c_out),

        .I_read_data                (I_read_data),
        .I_read_data_translated     (I_read_data_translated),
        .cancel                     (cancel),

        .A_io_in_EF                 (A_io_in_EF),
        .A_io_rden                  (A_io_rden),
        .A_io_in                    (A_io_in),
        .A_io_out_EF                (A_io_out_EF),
        .A_io_wren                  (A_io_wren),
        .A_io_out                   (A_io_out),

        .B_io_in_EF                 (B_io_in_EF),
        .B_io_rden                  (B_io_rden),
        .B_io_in                    (B_io_in),
        .B_io_out_EF                (B_io_out_EF),
        .B_io_wren                  (B_io_wren),
        .B_io_out                   (B_io_out)
    );

// -----------------------------------------------------------

    localparam SIMD_CONTROL_PIPELINE_DEPTH = 1;

// -----------------------------------------------------------

    wire    [INSTR_WIDTH-1:0]   I_read_data_delayed;

    delay_line 
    #(
        .DEPTH  (SIMD_CONTROL_PIPELINE_DEPTH),
        .WIDTH  (INSTR_WIDTH)
    ) 
    I_read_data_pipeline
    (
        .clock  (clock),
        .in     (I_read_data),
        .out    (I_read_data_delayed)
    );

// -----------------------------------------------------------

    wire    [INSTR_WIDTH-1:0]   I_read_data_translated_delayed;

    delay_line 
    #(
        .DEPTH  (SIMD_CONTROL_PIPELINE_DEPTH),
        .WIDTH  (INSTR_WIDTH)
    ) 
    I_read_data_translated_pipeline
    (
        .clock  (clock),
        .in     (I_read_data_translated),
        .out    (I_read_data_translated_delayed)
    );

// -----------------------------------------------------------

    wire                        cancel_delayed;

    delay_line 
    #(
        .DEPTH  (SIMD_CONTROL_PIPELINE_DEPTH),
        .WIDTH  (1)
    ) 
    cancel_pipeline
    (
        .clock  (clock),
        .in     (cancel),
        .out    (cancel_delayed)
    );

// -----------------------------------------------------------

    DataPath
    #(
        .ALU_WORD_WIDTH                 (SIMD_ALU_WORD_WIDTH),

        .INSTR_WIDTH                    (INSTR_WIDTH),
        .OPCODE_WIDTH                   (OPCODE_WIDTH),
        .D_OPERAND_WIDTH                (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH                (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH                (B_OPERAND_WIDTH),

        .A_WRITE_ADDR_OFFSET            (SIMD_A_WRITE_ADDR_OFFSET),
        .A_WORD_WIDTH                   (SIMD_A_WORD_WIDTH),
        .A_ADDR_WIDTH                   (SIMD_A_ADDR_WIDTH),
        .A_DEPTH                        (SIMD_A_DEPTH),
        .A_RAMSTYLE                     (SIMD_A_RAMSTYLE),
        .A_INIT_FILE                    (SIMD_A_INIT_FILE),
        .A_IO_READ_PORT_COUNT           (SIMD_A_IO_READ_PORT_COUNT),
        .A_IO_READ_PORT_BASE_ADDR       (SIMD_A_IO_READ_PORT_BASE_ADDR),
        .A_IO_READ_PORT_ADDR_WIDTH      (SIMD_A_IO_READ_PORT_ADDR_WIDTH),
        .A_IO_WRITE_PORT_COUNT          (SIMD_A_IO_WRITE_PORT_COUNT),
        .A_IO_WRITE_PORT_BASE_ADDR      (SIMD_A_IO_WRITE_PORT_BASE_ADDR),
        .A_IO_WRITE_PORT_ADDR_WIDTH     (SIMD_A_IO_WRITE_PORT_ADDR_WIDTH),

        .B_WRITE_ADDR_OFFSET            (SIMD_B_WRITE_ADDR_OFFSET),
        .B_WORD_WIDTH                   (SIMD_B_WORD_WIDTH),
        .B_ADDR_WIDTH                   (SIMD_B_ADDR_WIDTH),
        .B_DEPTH                        (SIMD_B_DEPTH),
        .B_RAMSTYLE                     (SIMD_B_RAMSTYLE),
        .B_INIT_FILE                    (SIMD_B_INIT_FILE),
        .B_IO_READ_PORT_COUNT           (SIMD_B_IO_READ_PORT_COUNT),
        .B_IO_READ_PORT_BASE_ADDR       (SIMD_B_IO_READ_PORT_BASE_ADDR),
        .B_IO_READ_PORT_ADDR_WIDTH      (SIMD_B_IO_READ_PORT_ADDR_WIDTH),
        .B_IO_WRITE_PORT_COUNT          (SIMD_B_IO_WRITE_PORT_COUNT),
        .B_IO_WRITE_PORT_BASE_ADDR      (SIMD_B_IO_WRITE_PORT_BASE_ADDR),
        .B_IO_WRITE_PORT_ADDR_WIDTH     (SIMD_B_IO_WRITE_PORT_ADDR_WIDTH),

        .TAP_AB_PIPELINE_DEPTH          (TAP_AB_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH         (AB_READ_PIPELINE_DEPTH),
        .AB_ALU_PIPELINE_DEPTH          (AB_ALU_PIPELINE_DEPTH),

        .LOGIC_OPCODE_WIDTH             (LOGIC_OPCODE_WIDTH),
        .ADDSUB_CARRY_SELECT            (SIMD_ADDSUB_CARRY_SELECT),
        .MULT_DOUBLE_PIPE               (SIMD_MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS             (SIMD_MULT_HETEROGENEOUS),    
        .MULT_USE_DSP                   (SIMD_MULT_USE_DSP),

        .H_WRITE_ADDR_OFFSET            (H_WRITE_ADDR_OFFSET),
        .H_DEPTH                        (H_DEPTH)
    )
    SIMD_Lane                           [SIMD_LANE_COUNT-1:0]
    (
        .clock                          (clock),
        .half_clock                     (half_clock),

        .I_read_data_in                 (I_read_data_delayed),
        .I_read_data_translated         (I_read_data_translated_delayed),

        .A_wren_other                   (SIMD_A_wren_other),
        .B_wren_other                   (SIMD_B_wren_other),

        .ALU_c_in                       (SIMD_ALU_c_in),
        // SIMD Lanes don't feed data to Scalar ControlPath
        .ALU_result_out                 (),
        .ALU_D_out                      (),
        .ALU_c_out                      (SIMD_ALU_c_out),

        .cancel                         (cancel_delayed),
        // SIMD Lanes don't control I/O Predication
        // Might do so one day for scatter/gather and handling divergent program flow
        .IO_ready                       (),

        .A_io_in_EF                     (SIMD_A_io_in_EF),
        .A_io_rden                      (SIMD_A_io_rden),
        .A_io_in                        (SIMD_A_io_in),
        .A_io_out_EF                    (SIMD_A_io_out_EF),
        .A_io_wren                      (SIMD_A_io_wren),
        .A_io_out                       (SIMD_A_io_out),

        .B_io_in_EF                     (SIMD_B_io_in_EF),
        .B_io_rden                      (SIMD_B_io_rden),
        .B_io_in                        (SIMD_B_io_in),
        .B_io_out_EF                    (SIMD_B_io_out_EF),
        .B_io_wren                      (SIMD_B_io_wren),
        .B_io_out                       (SIMD_B_io_out)
    );
endmodule

