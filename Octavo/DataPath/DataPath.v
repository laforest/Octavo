module DataPath
#(
    parameter       ALU_WORD_WIDTH                                  = 0,

    parameter       INSTR_WIDTH                                     = 0,
    parameter       OPCODE_WIDTH                                    = 0,
    parameter       D_OPERAND_WIDTH                                 = 0,
    parameter       A_OPERAND_WIDTH                                 = 0,
    parameter       B_OPERAND_WIDTH                                 = 0,

    parameter       A_WRITE_ADDR_OFFSET                             = 0,
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

    parameter       B_WRITE_ADDR_OFFSET                             = 0,
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
    parameter       MULT_USE_DSP                                    = 0,

    parameter       OFFSETS_WRITE_ADDR_BASE                         = 0,
    parameter       OFFSETS_WRITE_DELAY                             = 0,
    parameter       OFFSETS_COUNT                                   = 0,
    parameter       OFFSETS_RAMTYLE                                 = 0,
    parameter       OFFSETS_INIT_FILE                               = 0,
    parameter       OFFSETS_INITIAL_THREAD                          = 0,

    parameter       H_WRITE_ADDR_OFFSET                             = 0,
    parameter       H_DEPTH                                         = 0
)
(
    input   wire                                                    clock,
    input   wire                                                    half_clock,

    input   wire    [INSTR_WIDTH-1:0]                               I_read_data_in,
    output  wire    [INSTR_WIDTH-1:0]                               I_read_data_out,

    input   wire                                                    A_wren_other,
    input   wire                                                    B_wren_other,

    output  wire    [A_WORD_WIDTH-1:0]                              A_read_data,

    input   wire                                                    ALU_c_in,
    output  wire    [ALU_WORD_WIDTH-1:0]                            ALU_result_out,
    output  wire    [OPCODE_WIDTH-1:0]                              ALU_op_out,
    output  wire    [D_OPERAND_WIDTH-1:0]                           ALU_D_out,
    output  wire                                                    ALU_c_out,

    output  wire                                                    IO_ready,

    input   wire    [A_IO_READ_PORT_COUNT-1:0]                      A_io_in_EF,
    output  wire    [A_IO_READ_PORT_COUNT-1:0]                      A_io_rden,
    input   wire    [(A_WORD_WIDTH * A_IO_READ_PORT_COUNT)-1:0]     A_io_in,
    input   wire    [A_IO_WRITE_PORT_COUNT-1:0]                     A_io_out_EF,
    output  wire    [A_IO_WRITE_PORT_COUNT-1:0]                     A_io_wren,
    output  wire    [(A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT)-1:0]    A_io_out,

    input   wire    [B_IO_READ_PORT_COUNT-1:0]                      B_io_in_EF,
    output  wire    [B_IO_READ_PORT_COUNT-1:0]                      B_io_rden,
    input   wire    [(B_WORD_WIDTH * B_IO_READ_PORT_COUNT)-1:0]     B_io_in,
    input   wire    [B_IO_WRITE_PORT_COUNT-1:0]                     B_io_out_EF,
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

    wire    [A_OPERAND_WIDTH-1:0]  A_read_addr_in;
    wire    [B_OPERAND_WIDTH-1:0]  B_read_addr_in;
    wire    [D_OPERAND_WIDTH-1:0]  D_write_addr_in;

    Instr_Decoder
    #(
        .OPCODE_WIDTH       (OPCODE_WIDTH),
        .INSTR_WIDTH        (INSTR_WIDTH),
        .D_OPERAND_WIDTH    (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH    (A_OPERAND_WIDTH), 
        .B_OPERAND_WIDTH    (B_OPERAND_WIDTH)
    )
    I_in_decoder
    (
        .instr              (I_read_data_in),
        .op                 (),
        .D                  (D_write_addr_in),
        .A                  (A_read_addr_in),
        .B                  (B_read_addr_in)
    );

    wire    [A_OPERAND_WIDTH-1:0]  A_read_addr_AB;
    wire    [B_OPERAND_WIDTH-1:0]  B_read_addr_AB;
    wire    [D_OPERAND_WIDTH-1:0]  D_write_addr_AB;

    Addressing
    #(
        .OFFSETS_WRITE_ADDR_BASE    (OFFSETS_WRITE_ADDR_BASE),
        .OFFSETS_WRITE_DELAY        (OFFSETS_WRITE_DELAY),

        .WORD_WIDTH                 (A_ADDR_WIDTH),
        .ADDR_WIDTH                 (A_OPERAND_WIDTH)
        .DEPTH                      (OFFSETS_COUNT),
        .RAMSTYLE                   (OFFSETS_RAMTYLE),
        .INIT_FILE                  (OFFSETS_INIT_FILE),

        .H_WRITE_ADDR_OFFSET        (H_WRITE_ADDR_OFFSET),
        .H_DEPTH                    (H_DEPTH),

        .IO_ADDR_BASE               (A_IO_READ_PORT_BASE_ADDR),
        .IO_ADDR_COUNT              (A_IO_READ_PORT_COUNT),

        .INITIAL_THREAD             (OFFSETS_INITIAL_THREAD),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH          (THREAD_ADDR_WIDTH)
    )
    TAP_AB_A
    (
        .clock                      (clock),
        .addr_in                    (A_read_addr_in),
        .write_addr                 (ALU_D_out),
        .write_data                 (ALU_result_out),
        .addr_out                   (A_read_addr_AB)
    );

    // ECL replace with Addressing
    delay_line 
    #(
        .DEPTH  (TAP_AB_PIPELINE_DEPTH),
        .WIDTH  (B_OPERAND_WIDTH)
    ) 
    TAP_AB_pipeline_B
    (
        .clock  (clock),
        .in     (B_read_addr_in), // raw addr. stage 1
        .out    (B_read_addr_AB)  // "translated" addr stage 3
    );

    // ECL replace with Addressing
    delay_line 
    #(
        .DEPTH  (TAP_AB_PIPELINE_DEPTH),
        .WIDTH  (D_OPERAND_WIDTH)
    ) 
    TAP_AB_pipeline_D
    (
        .clock  (clock),
        .in     (D_read_addr_in), // raw addr. stage 1
        .out    (D_read_addr_AB)  // "translated" addr stage 3
    );

    wire    [A_WORD_WIDTH-1:0]      A_read_data_RAM;
    wire                            A_io_in_EF_masked;

    IO_Read
    #(
        .WORD_WIDTH                 (A_WORD_WIDTH),
        .ADDR_WIDTH                 (A_ADDR_WIDTH),
        .IO_READ_PORT_COUNT         (A_IO_READ_PORT_COUNT),
        .IO_READ_PORT_BASE_ADDR     (A_IO_READ_PORT_BASE_ADDR),
        .IO_READ_PORT_ADDR_WIDTH    (A_IO_READ_PORT_ADDR_WIDTH)
    )
    A_IO_Read
    (
        .clock                      (clock),
        .addr_raw                   (A_read_addr_in),
        .addr_translated            (A_read_addr_AB),
        .EmptyFull                  (A_io_in_EF),
        .data_IO                    (A_io_in),
        .data_RAM                   (A_read_data_RAM),
        .IO_ready                   (IO_ready),
        .EmptyFull_masked           (A_io_in_EF_masked),
        .active_IO                  (A_io_rden),
        .data_out                   (A_read_data)
    );

    wire                A_wren_RAM;
    wire                A_wren_ALU;

    Write_Enable 
    #(
        .OPCODE_WIDTH   (OPCODE_WIDTH),
        .ADDR_COUNT     (A_DEPTH),
        .ADDR_BASE      (A_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH)

    )
    A_wren
    (
        .op             (ALU_op_out),
        .addr           (ALU_D_out),
        .wren_other     (A_wren_other),
        .wren           (A_wren_ALU)
    );

    wire        A_write_is_IO;
    wire        A_write_is_IO_ALU;

    // ECL FIXME This points to a magic number in the parameters. 
    // The base and total depth of the ALU should be a parameter, 
    // not calculated.

    delay_line 
    #(
        .DEPTH  (4),
        .WIDTH  (1)
    ) 
    A_write_is_io_pipeline
    (
        .clock  (clock),
        .in     (A_write_is_IO),
        .out    (A_write_is_IO_ALU)
    );

    wire    [A_WORD_WIDTH-1:0]      A_write_data;
    wire    [A_ADDR_WIDTH-1:0]      A_write_addr;
    wire                            A_io_out_EF_masked;

    IO_Write
    #(
        .WORD_WIDTH                 (A_WORD_WIDTH),
        .ADDR_WIDTH                 (D_OPERAND_WIDTH),
        .RAM_ADDR_WIDTH             (A_ADDR_WIDTH),
        .IO_WRITE_PORT_COUNT        (A_IO_WRITE_PORT_COUNT),
        .IO_WRITE_PORT_BASE_ADDR    (A_IO_WRITE_PORT_BASE_ADDR),
        .IO_WRITE_PORT_ADDR_WIDTH   (A_IO_WRITE_PORT_ADDR_WIDTH)
    )
    A_IO_Write
    (
        .clock                      (clock),
        .addr_raw                   (D_write_addr_in),
        .EmptyFull                  (A_io_out_EF),
        .IO_ready                   (IO_ready),
        .ALU_result                 (ALU_result_out),
        .ALU_addr                   (ALU_D_out),
        .ALU_write_is_IO            (A_write_is_IO_ALU),
        .ALU_wren                   (A_wren_ALU),
        .write_is_IO                (A_write_is_IO),
        .EmptyFull_masked           (A_io_out_EF_masked),
        .active_IO                  (A_io_wren),
        .data_IO                    (A_io_out),
        .data_RAM                   (A_write_data),
        .addr_RAM                   (A_write_addr),
        .wren_RAM                   (A_wren_RAM)
    );

    RAM_SDP
    #(
        .WORD_WIDTH     (A_WORD_WIDTH),
        .ADDR_WIDTH     (A_ADDR_WIDTH),
        .DEPTH          (A_DEPTH),
        .RAMSTYLE       (A_RAMSTYLE),
        .INIT_FILE      (A_INIT_FILE)
    )
    A_RAM
    (
        .clock          (clock),
        .wren           (A_wren_RAM),
        .write_addr     (A_write_addr),
        .write_data     (A_write_data),
        .read_addr      (A_read_addr_AB),
        .read_data      (A_read_data_RAM)
    );


    wire    [B_WORD_WIDTH-1:0]      B_read_data_RAM;
    wire    [B_WORD_WIDTH-1:0]      B_read_data;
    wire                            B_io_in_EF_masked;

    IO_Read
    #(
        .WORD_WIDTH                 (B_WORD_WIDTH),
        .ADDR_WIDTH                 (B_ADDR_WIDTH),
        .IO_READ_PORT_COUNT         (B_IO_READ_PORT_COUNT),
        .IO_READ_PORT_BASE_ADDR     (B_IO_READ_PORT_BASE_ADDR),
        .IO_READ_PORT_ADDR_WIDTH    (B_IO_READ_PORT_ADDR_WIDTH)
    )
    B_IO_Read
    (
        .clock                      (clock),
        .addr_raw                   (B_read_addr_in),
        .addr_translated            (B_read_addr_AB),
        .EmptyFull                  (B_io_in_EF),
        .data_IO                    (B_io_in),
        .data_RAM                   (B_read_data_RAM),
        .IO_ready                   (IO_ready),
        .EmptyFull_masked           (B_io_in_EF_masked),
        .active_IO                  (B_io_rden),
        .data_out                   (B_read_data)
    );

    wire                B_wren_RAM;
    wire                B_wren_ALU;

    Write_Enable 
    #(
        .OPCODE_WIDTH   (OPCODE_WIDTH),
        .ADDR_COUNT     (B_DEPTH),
        .ADDR_BASE      (B_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH)
    )
    B_wren
    (
        .op             (ALU_op_out),
        .addr           (ALU_D_out),
        .wren_other     (B_wren_other),
        .wren           (B_wren_ALU)
    );

    wire        B_write_is_IO;
    wire        B_write_is_IO_ALU;

    // ECL FIXME This points to a magic number in the parameters. 
    // The base and total depth of the ALU should be a parameter, 
    // not calculated.

    delay_line 
    #(
        .DEPTH  (4),
        .WIDTH  (1)
    ) 
    B_write_is_io_pipeline
    (
        .clock  (clock),
        .in     (B_write_is_IO),
        .out    (B_write_is_IO_ALU)
    );

    wire    [B_WORD_WIDTH-1:0]      B_write_data;
    wire    [B_ADDR_WIDTH-1:0]      B_write_addr;
    wire                            B_io_out_EF_masked;

    IO_Write
    #(
        .WORD_WIDTH                 (B_WORD_WIDTH),
        .ADDR_WIDTH                 (D_OPERAND_WIDTH),
        .RAM_ADDR_WIDTH             (B_ADDR_WIDTH),
        .IO_WRITE_PORT_COUNT        (B_IO_WRITE_PORT_COUNT),
        .IO_WRITE_PORT_BASE_ADDR    (B_IO_WRITE_PORT_BASE_ADDR),
        .IO_WRITE_PORT_ADDR_WIDTH   (B_IO_WRITE_PORT_ADDR_WIDTH)
    )
    B_IO_Write
    (
        .clock                      (clock),
        .addr_raw                   (D_write_addr_in),
        .EmptyFull                  (B_io_out_EF),
        .IO_ready                   (IO_ready),
        .ALU_result                 (ALU_result_out),
        .ALU_addr                   (ALU_D_out),
        .ALU_write_is_IO            (B_write_is_IO_ALU),
        .ALU_wren                   (B_wren_ALU),
        .write_is_IO                (B_write_is_IO),
        .EmptyFull_masked           (B_io_out_EF_masked),
        .active_IO                  (B_io_wren),
        .data_IO                    (B_io_out),
        .data_RAM                   (B_write_data),
        .addr_RAM                   (B_write_addr),
        .wren_RAM                   (B_wren_RAM)
    );

    RAM_SDP
    #(
        .WORD_WIDTH     (B_WORD_WIDTH),
        .ADDR_WIDTH     (B_ADDR_WIDTH),
        .DEPTH          (B_DEPTH),
        .RAMSTYLE       (B_RAMSTYLE),
        .INIT_FILE      (B_INIT_FILE)
    )
    B_RAM
    (
        .clock          (clock),
        .wren           (B_wren_RAM),
        .write_addr     (B_write_addr),
        .write_data     (B_write_data),
        .read_addr      (B_read_addr_AB),
        .read_data      (B_read_data_RAM)
    );

    IO_All_Ready
    #(
        .READ_PORT_COUNT    (2),
        .WRITE_PORT_COUNT   (2)
    )
    IO_All_Ready
    (
        .clock              (clock),
        .read_EF            ({A_io_in_EF_masked,  B_io_in_EF_masked}),
        .write_EF           ({A_io_out_EF_masked, B_io_out_EF_masked}),
        .ready              (IO_ready)
    );

    wire    [INSTR_WIDTH-1:0]   I_read_data_AB_masked;

    Instruction_Annuller
    #(
        .INSTR_WIDTH    (INSTR_WIDTH)
    )
    DataPath_Annuller
    (
        .instr_in       (I_read_data_AB),
        .annul          (~IO_ready),
        .instr_out      (I_read_data_AB_masked)
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
        .in     (I_read_data_AB_masked),
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
