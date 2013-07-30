module DataPath
#(
    parameter       ALU_WORD_WIDTH                                  = 0,

    parameter       INSTR_WIDTH                                     = 0,
    parameter       OPCODE_WIDTH                                    = 0,
    parameter       D_OPERAND_WIDTH                                 = 0,
    parameter       A_OPERAND_WIDTH                                 = 0,
    parameter       B_OPERAND_WIDTH                                 = 0,

    parameter       A_WORD_WIDTH                                    = 0,
    parameter       A_ADDR_WIDTH                                    = 0,
    parameter       A_DEPTH                                         = 0,
    parameter       A_RAMSTYLE                                      = "",
    parameter       A_INIT_FILE                                     = "",
    parameter       A_IO_READ_PORT_COUNT                            = 0,
    parameter       A_IO_READ_PORT_BASE_ADDR                        = 0,
    parameter       A_IO_READ_PORT_ADDR_WIDTH                       = 0,
    parameter       A_IO_WRITE_PORT_COUNT                           = 0,
    parameter       A_IO_WRITE_PORT_BASE_ADDR                       = 0,
    parameter       A_IO_WRITE_PORT_ADDR_WIDTH                      = 0,

    parameter       B_WORD_WIDTH                                    = 0,
    parameter       B_ADDR_WIDTH                                    = 0,
    parameter       B_DEPTH                                         = 0,
    parameter       B_RAMSTYLE                                      = "",
    parameter       B_INIT_FILE                                     = "",
    parameter       B_IO_READ_PORT_COUNT                            = 0,
    parameter       B_IO_READ_PORT_BASE_ADDR                        = 0,
    parameter       B_IO_READ_PORT_ADDR_WIDTH                       = 0,
    parameter       B_IO_WRITE_PORT_COUNT                           = 0,
    parameter       B_IO_WRITE_PORT_BASE_ADDR                       = 0,
    parameter       B_IO_WRITE_PORT_ADDR_WIDTH                      = 0,

    parameter       I_PASSTHRU_PIPELINE_DEPTH                       = 0,
    parameter       TAP_AB_PIPELINE_DEPTH                           = 0,
    parameter       AB_READ_PIPELINE_DEPTH                          = 0,
    parameter       AB_ALU_PIPELINE_DEPTH                           = 0,

    parameter       LOGIC_OPCODE_WIDTH                              = 0,
    parameter       ADDSUB_CARRY_SELECT                             = 0,
    parameter       MULT_DOUBLE_PIPE                                = 0,
    parameter       MULT_HETEROGENEOUS                              = 0,    
    parameter       MULT_USE_DSP                                    = 0
)
(
    input   wire                                                    clock,
    input   wire                                                    half_clock,

    input   wire    [INSTR_WIDTH-1:0]                               I_read_data_in,
    output  wire    [INSTR_WIDTH-1:0]                               I_read_data_out,

    input   wire    [A_ADDR_WIDTH-1:0]                              A_write_addr,
    input   wire    [B_ADDR_WIDTH-1:0]                              B_write_addr,
    input   wire    [ALU_WORD_WIDTH-1:0]                            mem_write_data,
    input   wire    [OPCODE_WIDTH-1:0]                              mem_write_op,
    input   wire                                                    A_wren_other,
    input   wire                                                    B_wren_other,
    output  wire    [A_WORD_WIDTH-1:0]                              A_read_data,

    input   wire                                                    ALU_c_in,
    output  wire    [ALU_WORD_WIDTH-1:0]                            ALU_result_out,
    output  wire    [OPCODE_WIDTH-1:0]                              ALU_op_out,
    output  wire    [D_OPERAND_WIDTH-1:0]                           ALU_D_out,
    output  wire                                                    ALU_c_out,

    output  wire    [A_IO_READ_PORT_COUNT-1:0]                      A_io_rden,
    input   wire    [(A_WORD_WIDTH * A_IO_READ_PORT_COUNT)-1:0]     A_io_in,
    output  wire    [A_IO_WRITE_PORT_COUNT-1:0]                     A_io_wren,
    output  wire    [(A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT)-1:0]    A_io_out,

    output  wire    [B_IO_READ_PORT_COUNT-1:0]                      B_io_rden,
    input   wire    [(B_WORD_WIDTH * B_IO_READ_PORT_COUNT)-1:0]     B_io_in,
    output  wire    [B_IO_WRITE_PORT_COUNT-1:0]                     B_io_wren,
    output  wire    [(B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT)-1:0]    B_io_out

);
    delay_line 
    #(
        .DEPTH  (I_PASSTHRU_PIPELINE_DEPTH),
        .WIDTH  (INSTR_WIDTH)
    ) 
    I_passthru_pipeline
    (
        .clock  (clock),
        .in     (I_read_data_in),
        .out    (I_read_data_out)
    );

    wire    [INSTR_WIDTH-1:0]   I_read_data_AB;

    delay_line 
    #(
        .DEPTH  (TAP_AB_PIPELINE_DEPTH),
        .WIDTH  (INSTR_WIDTH)
    ) 
    TAP_AB_pipeline
    (
        .clock  (clock),
        .in     (I_read_data_in),
        .out    (I_read_data_AB)
    );

    wire    [A_OPERAND_WIDTH-1:0]  A_read_addr;
    wire    [B_OPERAND_WIDTH-1:0]  B_read_addr;

    Instr_Decoder
    #(
        .OPCODE_WIDTH       (OPCODE_WIDTH),
        .INSTR_WIDTH        (INSTR_WIDTH),
        .D_OPERAND_WIDTH    (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH    (A_OPERAND_WIDTH), 
        .B_OPERAND_WIDTH    (B_OPERAND_WIDTH)
    )
    IAB_decoder
    (
        .instr              (I_read_data_AB),
        .op                 (),
        .D                  (),
        .A                  (A_read_addr),
        .B                  (B_read_addr)
    );

    wire    [INSTR_WIDTH-1:0]   AB_instr;

    delay_line 
    #(
        .DEPTH  (AB_READ_PIPELINE_DEPTH),
        .WIDTH  (INSTR_WIDTH)
    ) 
    AB_read_pipeline
    (
        .clock  (clock),
        .in     (I_read_data_AB),
        .out    (AB_instr)
    );

    wire    [OPCODE_WIDTH-1:0]      ALU_op_in;
    wire    [D_OPERAND_WIDTH-1:0]   ALU_D_in;

    Instr_Decoder
    #(
        .OPCODE_WIDTH       (OPCODE_WIDTH),
        .INSTR_WIDTH        (INSTR_WIDTH),
        .D_OPERAND_WIDTH    (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH    (A_OPERAND_WIDTH), 
        .B_OPERAND_WIDTH    (B_OPERAND_WIDTH)
    )
    AB_read_decoder
    (
        .instr              (AB_instr),
        .op                 (ALU_op_in),
        .D                  (ALU_D_in),
        .A                  (),
        .B                  ()
    );

    wire    A_wren;

    Write_Enable 
    #(
        .OPCODE_WIDTH   (OPCODE_WIDTH)
    )
    A_mem_wren
    (
        .op             (mem_write_op),
        .wren_other     (A_wren_other),
        .wren           (A_wren)
    );

    Memory 
    #(
        .WORD_WIDTH                 (A_WORD_WIDTH),
        .ADDR_WIDTH                 (A_ADDR_WIDTH),
        .DEPTH                      (A_DEPTH),
        .RAMSTYLE                   (A_RAMSTYLE),
        .INIT_FILE                  (A_INIT_FILE),
        .IO_READ_PORT_COUNT         (A_IO_READ_PORT_COUNT),
        .IO_READ_PORT_BASE_ADDR     (A_IO_READ_PORT_BASE_ADDR),
        .IO_READ_PORT_ADDR_WIDTH    (A_IO_READ_PORT_ADDR_WIDTH),
        .IO_WRITE_PORT_COUNT        (A_IO_WRITE_PORT_COUNT),
        .IO_WRITE_PORT_BASE_ADDR    (A_IO_WRITE_PORT_BASE_ADDR),
        .IO_WRITE_PORT_ADDR_WIDTH   (A_IO_WRITE_PORT_ADDR_WIDTH)
    )
    A_mem
    (
        .clock                      (clock),
        .wren                       (A_wren),
        .write_addr                 (A_write_addr),
        .write_data                 (mem_write_data),
        .read_addr                  (A_read_addr),
        .read_data                  (A_read_data),
        .io_rden                    (A_io_rden),
        .io_in                      (A_io_in),
        .io_wren                    (A_io_wren),
        .io_out                     (A_io_out)
    );

    wire    B_wren;

    Write_Enable 
    #(
        .OPCODE_WIDTH   (OPCODE_WIDTH)
    )
    B_mem_wren 
    (
        .op             (mem_write_op),
        .wren_other     (B_wren_other),
        .wren           (B_wren)
    );

    wire    [B_WORD_WIDTH-1:0]      B_read_data;

    Memory 
    #(
        .WORD_WIDTH                 (B_WORD_WIDTH),
        .ADDR_WIDTH                 (B_ADDR_WIDTH),
        .DEPTH                      (B_DEPTH),
        .RAMSTYLE                   (B_RAMSTYLE),
        .INIT_FILE                  (B_INIT_FILE),
        .IO_READ_PORT_COUNT         (B_IO_READ_PORT_COUNT),
        .IO_READ_PORT_BASE_ADDR     (B_IO_READ_PORT_BASE_ADDR),
        .IO_READ_PORT_ADDR_WIDTH    (B_IO_READ_PORT_ADDR_WIDTH),
        .IO_WRITE_PORT_COUNT        (B_IO_WRITE_PORT_COUNT),
        .IO_WRITE_PORT_BASE_ADDR    (B_IO_WRITE_PORT_BASE_ADDR),
        .IO_WRITE_PORT_ADDR_WIDTH   (B_IO_WRITE_PORT_ADDR_WIDTH)
    )
    B_mem
    (
        .clock                      (clock),
        .wren                       (B_wren),
        .write_addr                 (B_write_addr),
        .write_data                 (mem_write_data),
        .read_addr                  (B_read_addr),
        .read_data                  (B_read_data),
        .io_rden                    (B_io_rden),
        .io_in                      (B_io_in),
        .io_wren                    (B_io_wren),
        .io_out                     (B_io_out)
    );

    ALU 
    #(
        .OPCODE_WIDTH           (OPCODE_WIDTH),
        .D_OPERAND_WIDTH        (D_OPERAND_WIDTH),
        .WORD_WIDTH             (ALU_WORD_WIDTH),
        .AB_ALU_PIPELINE_DEPTH  (AB_ALU_PIPELINE_DEPTH),
        .ADDSUB_CARRY_SELECT    (ADDSUB_CARRY_SELECT),
        .LOGIC_OPCODE_WIDTH     (LOGIC_OPCODE_WIDTH),
        .MULT_DOUBLE_PIPE       (MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS     (MULT_HETEROGENEOUS),
        .MULT_USE_DSP           (MULT_USE_DSP)
    )
    ALU 
    (
        .clock                  (clock),
        .half_clock             (half_clock),
        .c_in                   (ALU_c_in),
        .op_in                  (ALU_op_in),
        .D_in                   (ALU_D_in),
        .A                      (A_read_data),
        .B                      (B_read_data),
        .R                      (ALU_result_out),
        .op_out                 (ALU_op_out),
        .c_out                  (ALU_c_out),
        .D_out                  (ALU_D_out)
    );
endmodule
