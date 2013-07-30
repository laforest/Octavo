
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

    parameter       I_WORD_WIDTH                        = 0,
    parameter       I_ADDR_WIDTH                        = 0,
    parameter       I_DEPTH                             = 0,
    parameter       I_RAMSTYLE                          = "",
    parameter       I_INIT_FILE                         = "",

    parameter       PC_RAMSTYLE                         = "",
    parameter       PC_INIT_FILE                        = "",
    parameter       THREAD_COUNT                        = 0, 
    parameter       THREAD_ADDR_WIDTH                   = 0, 

    parameter       PC_PIPELINE_DEPTH                   = 0,
    parameter       I_TAP_PIPELINE_DEPTH                = 0,
    parameter       TAP_AB_PIPELINE_DEPTH               = 0,
    parameter       I_PASSTHRU_PIPELINE_DEPTH           = 0,
    parameter       AB_READ_PIPELINE_DEPTH              = 0,
    parameter       AB_ALU_PIPELINE_DEPTH               = 0,

    parameter       LOGIC_OPCODE_WIDTH                  = 0,
    parameter       ADDSUB_CARRY_SELECT                 = 0,
    parameter       MULT_DOUBLE_PIPE                    = 0,
    parameter       MULT_HETEROGENEOUS                  = 0,    
    parameter       MULT_USE_DSP                        = 0,

    parameter       SIMD_ADDSUB_CARRY_SELECT            = 0,
    parameter       SIMD_MULT_DOUBLE_PIPE               = 0,
    parameter       SIMD_MULT_HETEROGENEOUS             = 0,    
    parameter       SIMD_MULT_USE_DSP                   = 0,

    parameter       SIMD_LANE_COUNT                     = 0
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
    output  wire    [(               A_IO_READ_PORT_COUNT)-1:0]                                A_io_rden,
    input   wire    [(A_WORD_WIDTH * A_IO_READ_PORT_COUNT)-1:0]                                A_io_in,
    output  wire    [(               A_IO_WRITE_PORT_COUNT)-1:0]                               A_io_wren,
    output  wire    [(A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT)-1:0]                               A_io_out,

    output  wire    [(               B_IO_READ_PORT_COUNT)-1:0]                                B_io_rden,
    input   wire    [(B_WORD_WIDTH * B_IO_READ_PORT_COUNT)-1:0]                                B_io_in,
    output  wire    [(               B_IO_WRITE_PORT_COUNT)-1:0]                               B_io_wren,
    output  wire    [(B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT)-1:0]                               B_io_out,

    // SIMD I/O
    output  wire    [(                    SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_rden,
    input   wire    [(SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_in,
    output  wire    [(                    SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_wren,
    output  wire    [(SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_A_io_out,

    output  wire    [(                    SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_rden,
    input   wire    [(SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_in,
    output  wire    [(                    SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_wren,
    output  wire    [(SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]   SIMD_B_io_out
);
    // Instruction common to all Datapaths
    wire    [INSTR_WIDTH-1:0]   I_read_data;

    Scalar
    #(
        .ALU_WORD_WIDTH             (ALU_WORD_WIDTH),

        .INSTR_WIDTH                (INSTR_WIDTH),
        .OPCODE_WIDTH               (OPCODE_WIDTH),
        .D_OPERAND_WIDTH            (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH            (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH            (B_OPERAND_WIDTH),

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

        .I_WORD_WIDTH               (I_WORD_WIDTH),
        .I_ADDR_WIDTH               (I_ADDR_WIDTH),
        .I_DEPTH                    (I_DEPTH),
        .I_RAMSTYLE                 (I_RAMSTYLE),
        .I_INIT_FILE                (I_INIT_FILE),

        .PC_RAMSTYLE                (PC_RAMSTYLE),
        .PC_INIT_FILE               (PC_INIT_FILE),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH          (THREAD_ADDR_WIDTH),

        .PC_PIPELINE_DEPTH          (PC_PIPELINE_DEPTH),
        .I_TAP_PIPELINE_DEPTH       (I_TAP_PIPELINE_DEPTH),
        .TAP_AB_PIPELINE_DEPTH      (TAP_AB_PIPELINE_DEPTH),
        .I_PASSTHRU_PIPELINE_DEPTH  (I_PASSTHRU_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH     (AB_READ_PIPELINE_DEPTH),
        .AB_ALU_PIPELINE_DEPTH      (AB_ALU_PIPELINE_DEPTH),

        .LOGIC_OPCODE_WIDTH         (LOGIC_OPCODE_WIDTH),
        .ADDSUB_CARRY_SELECT        (ADDSUB_CARRY_SELECT),
        .MULT_DOUBLE_PIPE           (MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS         (MULT_HETEROGENEOUS),
        .MULT_USE_DSP               (MULT_USE_DSP)
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

        .A_io_rden                  (A_io_rden),
        .A_io_in                    (A_io_in),
        .A_io_wren                  (A_io_wren),
        .A_io_out                   (A_io_out),

        .B_io_rden                  (B_io_rden),
        .B_io_in                    (B_io_in),
        .B_io_wren                  (B_io_wren),
        .B_io_out                   (B_io_out)
    );

    // SIMD Lanes output back to SIMD Lanes A/B Data Memory 
    wire    [(D_OPERAND_WIDTH * SIMD_LANE_COUNT)-1:0]   SIMD_ALU_D_mem;
    wire    [(ALU_WORD_WIDTH  * SIMD_LANE_COUNT)-1:0]   SIMD_ALU_result_mem;
    wire    [(OPCODE_WIDTH    * SIMD_LANE_COUNT)-1:0]   SIMD_ALU_op_mem;

    DataPath
    #(
        .ALU_WORD_WIDTH                 (SIMD_ALU_WORD_WIDTH),

        .INSTR_WIDTH                    (INSTR_WIDTH),
        .OPCODE_WIDTH                   (OPCODE_WIDTH),
        .D_OPERAND_WIDTH                (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH                (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH                (B_OPERAND_WIDTH),

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

        // SIMD Lanes don't pass instructions along
        .I_PASSTHRU_PIPELINE_DEPTH      (0),
        .TAP_AB_PIPELINE_DEPTH          (TAP_AB_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH         (AB_READ_PIPELINE_DEPTH),
        .AB_ALU_PIPELINE_DEPTH          (AB_ALU_PIPELINE_DEPTH),

        .LOGIC_OPCODE_WIDTH             (LOGIC_OPCODE_WIDTH),
        .ADDSUB_CARRY_SELECT            (SIMD_ADDSUB_CARRY_SELECT),
        .MULT_DOUBLE_PIPE               (SIMD_MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS             (SIMD_MULT_HETEROGENEOUS),    
        .MULT_USE_DSP                   (SIMD_MULT_USE_DSP) 
    )
    SIMD_Lane                           [SIMD_LANE_COUNT-1:0]
    (
        .clock                          (clock),
        .half_clock                     (half_clock),

        .I_read_data_in                 (I_read_data),
        // SIMD Lanes don't pass instructions along
        .I_read_data_out                (),

        .A_write_addr                   (SIMD_ALU_D_mem),
        .B_write_addr                   (SIMD_ALU_D_mem),
        .mem_write_data                 (SIMD_ALU_result_mem),
        .mem_write_op                   (SIMD_ALU_op_mem),
        .A_wren_other                   (SIMD_A_wren_other),
        .B_wren_other                   (SIMD_B_wren_other),
        // SIMD Lanes don't affect Scalar ControlPath 
        .A_read_data                    (),

        .ALU_c_in                       (SIMD_ALU_c_in),
        .ALU_result_out                 (SIMD_ALU_result_mem),
        .ALU_op_out                     (SIMD_ALU_op_mem),
        .ALU_D_out                      (SIMD_ALU_D_mem),
        .ALU_c_out                      (SIMD_ALU_c_out),

        .A_io_rden                      (SIMD_A_io_rden),
        .A_io_in                        (SIMD_A_io_in),
        .A_io_wren                      (SIMD_A_io_wren),
        .A_io_out                       (SIMD_A_io_out),

        .B_io_rden                      (SIMD_B_io_rden),
        .B_io_in                        (SIMD_B_io_in),
        .B_io_wren                      (SIMD_B_io_wren),
        .B_io_out                       (SIMD_B_io_out)
    );
endmodule

