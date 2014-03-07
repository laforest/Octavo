
// Scalar Octavo CPU. I/O lines are flat vectors of words.
// Wrap as necessary to break-out I/O ports and set parameters.

module Scalar
#(
    parameter       ALU_WORD_WIDTH              = 0,

    parameter       INSTR_WIDTH                 = 0,
    parameter       OPCODE_WIDTH                = 0,
    parameter       D_OPERAND_WIDTH             = 0,
    parameter       A_OPERAND_WIDTH             = 0,
    parameter       B_OPERAND_WIDTH             = 0,

    parameter       A_WRITE_ADDR_OFFSET         = 0,
    parameter       A_WORD_WIDTH                = 0,
    parameter       A_ADDR_WIDTH                = 0,
    parameter       A_DEPTH                     = 0,
    parameter       A_RAMSTYLE                  = "",
    parameter       A_INIT_FILE                 = "",
    parameter       A_IO_READ_PORT_COUNT        = 0,
    parameter       A_IO_READ_PORT_BASE_ADDR    = 0,
    parameter       A_IO_READ_PORT_ADDR_WIDTH   = 0,
    parameter       A_IO_WRITE_PORT_COUNT       = 0,
    parameter       A_IO_WRITE_PORT_BASE_ADDR   = 0,
    parameter       A_IO_WRITE_PORT_ADDR_WIDTH  = 0,

    parameter       B_WRITE_ADDR_OFFSET         = 0,
    parameter       B_WORD_WIDTH                = 0,
    parameter       B_ADDR_WIDTH                = 0,
    parameter       B_DEPTH                     = 0,
    parameter       B_RAMSTYLE                  = "",
    parameter       B_INIT_FILE                 = "",
    parameter       B_IO_READ_PORT_COUNT        = 0,
    parameter       B_IO_READ_PORT_BASE_ADDR    = 0,
    parameter       B_IO_READ_PORT_ADDR_WIDTH   = 0,
    parameter       B_IO_WRITE_PORT_COUNT       = 0,
    parameter       B_IO_WRITE_PORT_BASE_ADDR   = 0,
    parameter       B_IO_WRITE_PORT_ADDR_WIDTH  = 0,

    parameter       I_WRITE_ADDR_OFFSET         = 0,
    parameter       I_WORD_WIDTH                = 0,
    parameter       I_ADDR_WIDTH                = 0,
    parameter       I_DEPTH                     = 0,
    parameter       I_RAMSTYLE                  = "",
    parameter       I_INIT_FILE                 = "",

    parameter       H_WRITE_ADDR_OFFSET         = 0,
    parameter       H_WORD_WIDTH                = 0,
    parameter       H_ADDR_WIDTH                = 0,
    parameter       H_DEPTH                     = 0,

    parameter       PC_RAMSTYLE                 = "",
    parameter       PC_INIT_FILE                = "",
    parameter       THREAD_COUNT                = 0, 
    parameter       THREAD_ADDR_WIDTH           = 0, 

    parameter       I_TAP_PIPELINE_DEPTH        = 0,
    parameter       TAP_AB_PIPELINE_DEPTH       = 0,
    parameter       I_PASSTHRU_PIPELINE_DEPTH   = 0,
    parameter       AB_READ_PIPELINE_DEPTH      = 0,
    parameter       AB_ALU_PIPELINE_DEPTH       = 0,

    parameter       LOGIC_OPCODE_WIDTH          = 0,
    parameter       ADDSUB_CARRY_SELECT         = 0,
    parameter       MULT_DOUBLE_PIPE            = 0,
    parameter       MULT_HETEROGENEOUS          = 0,    
    parameter       MULT_USE_DSP                = 0,

    parameter   ORIGIN_WRITE_WORD_OFFSET        = 0,
    parameter   ORIGIN_WRITE_ADDR_OFFSET        = 0,
    parameter   ORIGIN_WORD_WIDTH               = 0,
    parameter   ORIGIN_ADDR_WIDTH               = 0,
    parameter   ORIGIN_DEPTH                    = 0,
    parameter   ORIGIN_RAMSTYLE                 = 0,
    parameter   ORIGIN_INIT_FILE                = 0,

    parameter   BRANCH_COUNT                    = 0,

    parameter   DESTINATION_WRITE_WORD_OFFSET   = 0,
    parameter   DESTINATION_WRITE_ADDR_OFFSET   = 0,
    parameter   DESTINATION_WORD_WIDTH          = 0,
    parameter   DESTINATION_ADDR_WIDTH          = 0,
    parameter   DESTINATION_DEPTH               = 0,
    parameter   DESTINATION_RAMSTYLE            = 0,
    parameter   DESTINATION_INIT_FILE           = 0,

    parameter   CONDITION_WRITE_WORD_OFFSET     = 0,
    parameter   CONDITION_WRITE_ADDR_OFFSET     = 0,
    parameter   CONDITION_WORD_WIDTH            = 0,
    parameter   CONDITION_ADDR_WIDTH            = 0,
    parameter   CONDITION_DEPTH                 = 0,
    parameter   CONDITION_RAMSTYLE              = 0,
    parameter   CONDITION_INIT_FILE             = 0,

    parameter   PREDICTION_WRITE_WORD_OFFSET        = 0,
    parameter   PREDICTION_WRITE_ADDR_OFFSET        = 0,
    parameter   PREDICTION_WORD_WIDTH               = 0,
    parameter   PREDICTION_ADDR_WIDTH               = 0,
    parameter   PREDICTION_DEPTH                    = 0,
    parameter   PREDICTION_RAMSTYLE                 = 0,
    parameter   PREDICTION_INIT_FILE                = 0,

    parameter   PREDICTION_ENABLE_WRITE_WORD_OFFSET = 0,
    parameter   PREDICTION_ENABLE_WRITE_ADDR_OFFSET = 0,
    parameter   PREDICTION_ENABLE_WORD_WIDTH        = 0,
    parameter   PREDICTION_ENABLE_ADDR_WIDTH        = 0,
    parameter   PREDICTION_ENABLE_DEPTH             = 0,
    parameter   PREDICTION_ENABLE_RAMSTYLE          = 0,
    parameter   PREDICTION_ENABLE_INIT_FILE         = 0,

    parameter   FLAGS_WORD_WIDTH                = 0,
    parameter   FLAGS_ADDR_WIDTH                = 0
)
(
    input   wire                                                    clock,
    input   wire                                                    half_clock,

    // Memory write enables for external control by accelerators    
    input   wire                                                    I_wren_other,
    input   wire                                                    A_wren_other,
    input   wire                                                    B_wren_other,
    
    // ALU AddSub carry-in/out for external control by accelerators
    input   wire                                                    ALU_c_in,
    output  wire                                                    ALU_c_out,

    // Instruction sent to SIMD lanes
    output  wire    [INSTR_WIDTH-1:0]                               I_read_data,

    // Group I/O:   *******************Scalar*******************
    input   wire    [(               A_IO_READ_PORT_COUNT)-1:0]     A_io_in_EF,
    output  wire    [(               A_IO_READ_PORT_COUNT)-1:0]     A_io_rden,
    input   wire    [(A_WORD_WIDTH * A_IO_READ_PORT_COUNT)-1:0]     A_io_in,
    input   wire    [(               A_IO_WRITE_PORT_COUNT)-1:0]    A_io_out_EF,
    output  wire    [(               A_IO_WRITE_PORT_COUNT)-1:0]    A_io_wren,
    output  wire    [(A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT)-1:0]    A_io_out,

    input   wire    [(               B_IO_READ_PORT_COUNT)-1:0]     B_io_in_EF,
    output  wire    [(               B_IO_READ_PORT_COUNT)-1:0]     B_io_rden,
    input   wire    [(B_WORD_WIDTH * B_IO_READ_PORT_COUNT)-1:0]     B_io_in,
    input   wire    [(               B_IO_WRITE_PORT_COUNT)-1:0]    B_io_out_EF,
    output  wire    [(               B_IO_WRITE_PORT_COUNT)-1:0]    B_io_wren,
    output  wire    [(B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT)-1:0]    B_io_out
);

// -----------------------------------------------------------

    // DataPath output back to all Memories 
    wire    [D_OPERAND_WIDTH-1:0]   ALU_D_mem;
    wire    [ALU_WORD_WIDTH-1:0]    ALU_result_mem;

    wire    [INSTR_WIDTH-1:0]       I_read_data_DataPath;

    wire                            cancel;
    wire                            IO_ready;

    ControlPath
    #(
        .ALU_WORD_WIDTH                 (ALU_WORD_WIDTH),

        .INSTR_WIDTH                    (INSTR_WIDTH),
        .D_OPERAND_WIDTH                (D_OPERAND_WIDTH),

        .I_WRITE_ADDR_OFFSET            (I_WRITE_ADDR_OFFSET),
        .I_WORD_WIDTH                   (I_WORD_WIDTH),
        .I_ADDR_WIDTH                   (I_ADDR_WIDTH),
        .I_DEPTH                        (I_DEPTH),
        .I_RAMSTYLE                     (I_RAMSTYLE),
        .I_INIT_FILE                    (I_INIT_FILE),

        .PC_RAMSTYLE                    (PC_RAMSTYLE),
        .PC_INIT_FILE                   (PC_INIT_FILE),
        .THREAD_COUNT                   (THREAD_COUNT), 
        .THREAD_ADDR_WIDTH              (THREAD_ADDR_WIDTH), 

        .I_TAP_PIPELINE_DEPTH           (I_TAP_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH         (AB_READ_PIPELINE_DEPTH),
        .ORIGIN_WRITE_WORD_OFFSET       (ORIGIN_WRITE_WORD_OFFSET),
        .ORIGIN_WRITE_ADDR_OFFSET       (ORIGIN_WRITE_ADDR_OFFSET),
        .ORIGIN_WORD_WIDTH              (ORIGIN_WORD_WIDTH),
        .ORIGIN_ADDR_WIDTH              (ORIGIN_ADDR_WIDTH),
        .ORIGIN_DEPTH                   (ORIGIN_DEPTH),
        .ORIGIN_RAMSTYLE                (ORIGIN_RAMSTYLE),
        .ORIGIN_INIT_FILE               (ORIGIN_INIT_FILE),

        .BRANCH_COUNT                   (BRANCH_COUNT),

        .DESTINATION_WRITE_WORD_OFFSET  (DESTINATION_WRITE_WORD_OFFSET),
        .DESTINATION_WRITE_ADDR_OFFSET  (DESTINATION_WRITE_ADDR_OFFSET),
        .DESTINATION_WORD_WIDTH         (DESTINATION_WORD_WIDTH),
        .DESTINATION_ADDR_WIDTH         (DESTINATION_ADDR_WIDTH),
        .DESTINATION_DEPTH              (DESTINATION_DEPTH),
        .DESTINATION_RAMSTYLE           (DESTINATION_RAMSTYLE),
        .DESTINATION_INIT_FILE          (DESTINATION_INIT_FILE),

        .CONDITION_WRITE_WORD_OFFSET    (CONDITION_WRITE_WORD_OFFSET),
        .CONDITION_WRITE_ADDR_OFFSET    (CONDITION_WRITE_ADDR_OFFSET),
        .CONDITION_WORD_WIDTH           (CONDITION_WORD_WIDTH),
        .CONDITION_ADDR_WIDTH           (CONDITION_ADDR_WIDTH),
        .CONDITION_DEPTH                (CONDITION_DEPTH),
        .CONDITION_RAMSTYLE             (CONDITION_RAMSTYLE),
        .CONDITION_INIT_FILE            (CONDITION_INIT_FILE),

        .PREDICTION_WRITE_WORD_OFFSET   (PREDICTION_WRITE_WORD_OFFSET),       
        .PREDICTION_WRITE_ADDR_OFFSET   (PREDICTION_WRITE_ADDR_OFFSET),
        .PREDICTION_WORD_WIDTH          (PREDICTION_WORD_WIDTH),
        .PREDICTION_ADDR_WIDTH          (PREDICTION_ADDR_WIDTH),
        .PREDICTION_DEPTH               (PREDICTION_DEPTH),
        .PREDICTION_RAMSTYLE            (PREDICTION_RAMSTYLE),
        .PREDICTION_INIT_FILE           (PREDICTION_INIT_FILE),
                                            
        .PREDICTION_ENABLE_WRITE_WORD_OFFSET    (PREDICTION_ENABLE_WRITE_WORD_OFFSET),
        .PREDICTION_ENABLE_WRITE_ADDR_OFFSET    (PREDICTION_ENABLE_WRITE_ADDR_OFFSET),
        .PREDICTION_ENABLE_WORD_WIDTH           (PREDICTION_ENABLE_WORD_WIDTH),
        .PREDICTION_ENABLE_ADDR_WIDTH           (PREDICTION_ENABLE_ADDR_WIDTH),
        .PREDICTION_ENABLE_DEPTH                (PREDICTION_ENABLE_DEPTH),
        .PREDICTION_ENABLE_RAMSTYLE             (PREDICTION_ENABLE_RAMSTYLE),
        .PREDICTION_ENABLE_INIT_FILE            (PREDICTION_ENABLE_INIT_FILE),

        .FLAGS_WORD_WIDTH               (FLAGS_WORD_WIDTH),
        .FLAGS_ADDR_WIDTH               (FLAGS_ADDR_WIDTH)
    )
    ControlPath
    (
        .clock                          (clock),

        .I_wren_other                   (I_wren_other),
        .ALU_write_addr                 (ALU_D_mem),
        .ALU_write_data                 (ALU_result_mem),
        .IO_ready                       (IO_ready),

        .I_read_data                    (I_read_data_DataPath),
        .cancel                         (cancel)
    );

// -----------------------------------------------------------

    DataPath
    #(
        .ALU_WORD_WIDTH                 (ALU_WORD_WIDTH),

        .INSTR_WIDTH                    (INSTR_WIDTH),
        .OPCODE_WIDTH                   (OPCODE_WIDTH),
        .D_OPERAND_WIDTH                (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH                (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH                (B_OPERAND_WIDTH),

        .A_WRITE_ADDR_OFFSET            (A_WRITE_ADDR_OFFSET),
        .A_WORD_WIDTH                   (A_WORD_WIDTH),
        .A_ADDR_WIDTH                   (A_ADDR_WIDTH),
        .A_DEPTH                        (A_DEPTH),
        .A_RAMSTYLE                     (A_RAMSTYLE),
        .A_INIT_FILE                    (A_INIT_FILE),
        .A_IO_READ_PORT_COUNT           (A_IO_READ_PORT_COUNT),
        .A_IO_READ_PORT_BASE_ADDR       (A_IO_READ_PORT_BASE_ADDR),
        .A_IO_READ_PORT_ADDR_WIDTH      (A_IO_READ_PORT_ADDR_WIDTH),
        .A_IO_WRITE_PORT_COUNT          (A_IO_WRITE_PORT_COUNT),
        .A_IO_WRITE_PORT_BASE_ADDR      (A_IO_WRITE_PORT_BASE_ADDR),
        .A_IO_WRITE_PORT_ADDR_WIDTH     (A_IO_WRITE_PORT_ADDR_WIDTH),

        .B_WRITE_ADDR_OFFSET            (B_WRITE_ADDR_OFFSET),
        .B_WORD_WIDTH                   (B_WORD_WIDTH),
        .B_ADDR_WIDTH                   (B_ADDR_WIDTH),
        .B_DEPTH                        (B_DEPTH),
        .B_RAMSTYLE                     (B_RAMSTYLE),
        .B_INIT_FILE                    (B_INIT_FILE),
        .B_IO_READ_PORT_COUNT           (B_IO_READ_PORT_COUNT),
        .B_IO_READ_PORT_BASE_ADDR       (B_IO_READ_PORT_BASE_ADDR),
        .B_IO_READ_PORT_ADDR_WIDTH      (B_IO_READ_PORT_ADDR_WIDTH),
        .B_IO_WRITE_PORT_COUNT          (B_IO_WRITE_PORT_COUNT),
        .B_IO_WRITE_PORT_BASE_ADDR      (B_IO_WRITE_PORT_BASE_ADDR),
        .B_IO_WRITE_PORT_ADDR_WIDTH     (B_IO_WRITE_PORT_ADDR_WIDTH),

        .I_PASSTHRU_PIPELINE_DEPTH      (I_PASSTHRU_PIPELINE_DEPTH),
        .TAP_AB_PIPELINE_DEPTH          (TAP_AB_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH         (AB_READ_PIPELINE_DEPTH),
        .AB_ALU_PIPELINE_DEPTH          (AB_ALU_PIPELINE_DEPTH),

        .LOGIC_OPCODE_WIDTH             (LOGIC_OPCODE_WIDTH),
        .ADDSUB_CARRY_SELECT            (ADDSUB_CARRY_SELECT),
        .MULT_DOUBLE_PIPE               (MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS             (MULT_HETEROGENEOUS),    
        .MULT_USE_DSP                   (MULT_USE_DSP) 
    )
    DataPath
    (
        .clock                          (clock),
        .half_clock                     (half_clock),

        .I_read_data_in                 (I_read_data_DataPath),
        .I_read_data_out                (I_read_data),

        .A_wren_other                   (A_wren_other),
        .B_wren_other                   (B_wren_other),

        .ALU_c_in                       (ALU_c_in),
        .ALU_result_out                 (ALU_result_mem),
        .ALU_D_out                      (ALU_D_mem),
        .ALU_c_out                      (ALU_c_out),

        .cancel                         (cancel),
        .IO_ready                       (IO_ready),

        .A_io_in_EF                     (A_io_in_EF),
        .A_io_rden                      (A_io_rden),
        .A_io_in                        (A_io_in),
        .A_io_out_EF                    (A_io_out_EF),
        .A_io_wren                      (A_io_wren),
        .A_io_out                       (A_io_out),

        .B_io_in_EF                     (B_io_in_EF),
        .B_io_rden                      (B_io_rden),
        .B_io_in                        (B_io_in),
        .B_io_out_EF                    (B_io_out_EF),
        .B_io_wren                      (B_io_wren),
        .B_io_out                       (B_io_out)
    );

endmodule

