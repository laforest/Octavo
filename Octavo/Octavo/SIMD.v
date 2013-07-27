
// SIMD lanes to extend a Scalar Octavo CPU
// I/O lines are flat vectors of words.

module SIMD
#(
    parameter       SIMD_ALU_WORD_WIDTH                 = 0,

    parameter       INSTR_WIDTH                         = 0,
    parameter       OPCODE_WIDTH                        = 0,
    parameter       D_OPERAND_WIDTH                     = 0,
    parameter       A_OPERAND_WIDTH                     = 0,
    parameter       B_OPERAND_WIDTH                     = 0,

    parameter       A_ADDR_WIDTH                        = 0,
    parameter       B_ADDR_WIDTH                        = 0,

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

    parameter       SIMD_I_PASSTHRU_PIPELINE_DEPTH      = 0,
    parameter       SIMD_TAP_AB_PIPELINE_DEPTH          = 0,
    parameter       AB_READ_PIPELINE_DEPTH              = 0,
    parameter       AB_ALU_PIPELINE_DEPTH               = 0,

    parameter       LOGIC_OPCODE_WIDTH                  = 0,
    parameter       SIMD_ADDSUB_CARRY_SELECT            = 0,
    parameter       SIMD_MULT_DOUBLE_PIPE               = 0,
    parameter       SIMD_MULT_HETEROGENEOUS             = 0,    
    parameter       SIMD_MULT_USE_DSP                   = 0,

    parameter       SIMD_LANE_COUNT                 = 0
)
(
    input   wire                                                                                clock,
    input   wire                                                                                half_clock,

    // Memory write enables for external control by accelerators
    input   wire    [SIMD_LANE_COUNT-1:0]                                                       A_wren_other,
    input   wire    [SIMD_LANE_COUNT-1:0]                                                       B_wren_other,
    
    // ALU AddSub carry-in/out for external control by accelerators
    input   wire    [SIMD_LANE_COUNT-1:0]                                                       ALU_c_in,
    output  wire    [SIMD_LANE_COUNT-1:0]                                                       ALU_c_out,

    // Instruction from parent SIMD lane
    input   wire    [INSTR_WIDTH-1:0]                                                           I_read_data_in,
    // Instruction to child SIMD lane
    output  wire    [INSTR_WIDTH-1:0]                                                           I_read_data_out,

    // Group I/O:   ************************************SIMD*******************************
    output  wire    [(                    SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]    A_io_rden,
    input   wire    [(SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]    A_io_in,
    output  wire    [(                    SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]    A_io_wren,
    output  wire    [(SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]    A_io_out,

    output  wire    [(                    SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]    B_io_rden,
    input   wire    [(SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT)-1:0]    B_io_in,
    output  wire    [(                    SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]    B_io_wren,
    output  wire    [(SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:0]    B_io_out
);
    // Bundle SIMD lane DataPath outputs  *******************SIMD*********************
    localparam ALU_D_mem_WIDTH          = (D_OPERAND_WIDTH     * SIMD_LANE_COUNT);
    localparam ALU_result_mem_WIDTH     = (SIMD_ALU_WORD_WIDTH * SIMD_LANE_COUNT);
    localparam ALU_op_mem_WIDTH         = (OPCODE_WIDTH        * SIMD_LANE_COUNT);

    wire    [ALU_D_mem_WIDTH-1:0]       ALU_D_mem;
    wire    [ALU_result_mem_WIDTH-1:0]  ALU_result_mem;
    wire    [ALU_op_mem_WIDTH-1:0]      ALU_op_mem;

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

        .I_PASSTHRU_PIPELINE_DEPTH      (SIMD_I_PASSTHRU_PIPELINE_DEPTH),
        .TAP_AB_PIPELINE_DEPTH          (SIMD_TAP_AB_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH         (AB_READ_PIPELINE_DEPTH),
        .AB_ALU_PIPELINE_DEPTH          (AB_ALU_PIPELINE_DEPTH),

        .LOGIC_OPCODE_WIDTH             (LOGIC_OPCODE_WIDTH),
        .ADDSUB_CARRY_SELECT            (SIMD_ADDSUB_CARRY_SELECT),
        .MULT_DOUBLE_PIPE               (SIMD_MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS             (SIMD_MULT_HETEROGENEOUS),    
        .MULT_USE_DSP                   (SIMD_MULT_USE_DSP) 
    )
    Lane_Passthru                            
    (
        .clock                          (clock),
        .half_clock                     (half_clock),

        .I_read_data_in                 (I_read_data_in),
        .I_read_data_out                (I_read_data_out),

        .A_write_addr                   (ALU_D_mem[D_OPERAND_WIDTH-1:0]),
        .B_write_addr                   (ALU_D_mem[D_OPERAND_WIDTH-1:0]),
        .mem_write_data                 (ALU_result_mem[SIMD_ALU_WORD_WIDTH-1:0]),
        .mem_write_op                   (ALU_op_mem[OPCODE_WIDTH-1:0]),
        .A_wren_other                   (A_wren_other[0]),
        .B_wren_other                   (B_wren_other[0]),
        // SIMD lanes do not affect Controller flow-control decisions
        .A_read_data                    (),

        .ALU_c_in                       (ALU_c_in[0]),
        .ALU_result_out                 (ALU_result_mem[SIMD_ALU_WORD_WIDTH-1:0]),
        .ALU_op_out                     (ALU_op_mem[OPCODE_WIDTH-1:0]),
        .ALU_D_out                      (ALU_D_mem[D_OPERAND_WIDTH-1:0]),
        .ALU_c_out                      (ALU_c_out[0]),

        .A_io_rden                      (A_io_rden[SIMD_A_IO_READ_PORT_COUNT-1:0]),
        .A_io_in                        (A_io_in[(SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT)-1:0]),
        .A_io_wren                      (A_io_wren[SIMD_A_IO_WRITE_PORT_COUNT-1:0]),
        .A_io_out                       (A_io_out[(SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT)-1:0]),

        .B_io_rden                      (B_io_rden[SIMD_B_IO_READ_PORT_COUNT-1:0]),
        .B_io_in                        (B_io_in[(SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT)-1:0]),
        .B_io_wren                      (B_io_wren[SIMD_B_IO_WRITE_PORT_COUNT-1:0]),
        .B_io_out                       (B_io_out[(SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT)-1:0])
    );

    generate
        if (SIMD_LANE_COUNT > 1) begin 
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

                // Must do this, else it would waste area in the partition
                .I_PASSTHRU_PIPELINE_DEPTH      (0),
                .TAP_AB_PIPELINE_DEPTH          (SIMD_TAP_AB_PIPELINE_DEPTH),
                .AB_READ_PIPELINE_DEPTH         (AB_READ_PIPELINE_DEPTH),
                .AB_ALU_PIPELINE_DEPTH          (AB_ALU_PIPELINE_DEPTH),

                .LOGIC_OPCODE_WIDTH             (LOGIC_OPCODE_WIDTH),
                .ADDSUB_CARRY_SELECT            (SIMD_ADDSUB_CARRY_SELECT),
                .MULT_DOUBLE_PIPE               (SIMD_MULT_DOUBLE_PIPE),
                .MULT_HETEROGENEOUS             (SIMD_MULT_HETEROGENEOUS),    
                .MULT_USE_DSP                   (SIMD_MULT_USE_DSP) 
            )
            Lanes                               [SIMD_LANE_COUNT-2:0]
            (
                .clock                          (clock),
                .half_clock                     (half_clock),

                .I_read_data_in                 (I_read_data_in),
                .I_read_data_out                (),

                .A_write_addr                   (ALU_D_mem[ALU_D_mem_WIDTH-1:D_OPERAND_WIDTH]),
                .B_write_addr                   (ALU_D_mem[ALU_D_mem_WIDTH-1:D_OPERAND_WIDTH]),
                .mem_write_data                 (ALU_result_mem[ALU_result_mem_WIDTH-1:SIMD_ALU_WORD_WIDTH]),
                .mem_write_op                   (ALU_op_mem[ALU_op_mem_WIDTH-1:OPCODE_WIDTH]),
                .A_wren_other                   (A_wren_other[SIMD_LANE_COUNT-1:1]),
                .B_wren_other                   (B_wren_other[SIMD_LANE_COUNT-1:1]),
                // SIMD lanes do not affect Controller flow-control decisions
                .A_read_data                    (),

                .ALU_c_in                       (ALU_c_in[SIMD_LANE_COUNT-1:1]),
                .ALU_result_out                 (ALU_result_mem[ALU_result_mem_WIDTH-1:SIMD_ALU_WORD_WIDTH]),
                .ALU_op_out                     (ALU_op_mem[ALU_op_mem_WIDTH-1:OPCODE_WIDTH]),
                .ALU_D_out                      (ALU_D_mem[ALU_D_mem_WIDTH-1:D_OPERAND_WIDTH]),
                .ALU_c_out                      (ALU_c_out[SIMD_LANE_COUNT-1:1]),

                .A_io_rden                      (A_io_rden[(SIMD_A_IO_READ_PORT_COUNT * SIMD_LANE_COUNT)-1:SIMD_A_IO_READ_PORT_COUNT]),
                .A_io_in                        (A_io_in[(SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT * SIMD_LANE_COUNT)-1:(SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT)]),
                .A_io_wren                      (A_io_wren[(SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:SIMD_A_IO_WRITE_PORT_COUNT]),
                .A_io_out                       (A_io_out[(SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:(SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT)]),

                .B_io_rden                      (B_io_rden[(SIMD_B_IO_READ_PORT_COUNT * SIMD_LANE_COUNT)-1:SIMD_B_IO_READ_PORT_COUNT]),
                .B_io_in                        (B_io_in[(SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT * SIMD_LANE_COUNT)-1:(SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT)]),
                .B_io_wren                      (B_io_wren[(SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:SIMD_B_IO_WRITE_PORT_COUNT]),
                .B_io_out                       (B_io_out[(SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT)-1:(SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT)])
            );
        end
    endgenerate
endmodule

