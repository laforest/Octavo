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

    parameter       CONTROL_INPUT_PIPELINE_DEPTH                    = 0,
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

    input   wire    [INSTR_WIDTH-1:0]                               I_read_data_in,         // stage 1
    input   wire    [INSTR_WIDTH-1:0]                               I_read_data_translated, // stage 3

    input   wire                                                    A_wren_other,
    input   wire                                                    B_wren_other,

    input   wire                                                    ALU_c_in,
    output  wire    [ALU_WORD_WIDTH-1:0]                            ALU_result_out,
    output  wire    [D_OPERAND_WIDTH-1:0]                           ALU_D_out,
    output  wire                                                    ALU_c_out,

    input   wire                                                    cancel,
    output  reg                                                     IO_ready,

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

// -----------------------------------------------------------

    wire    [INSTR_WIDTH-1:0]   I_read_data_in_delayed;

    delay_line 
    #(
        .DEPTH  (CONTROL_INPUT_PIPELINE_DEPTH), // XXX COME BACK AND REMOVE THIS
        .WIDTH  (INSTR_WIDTH)
    ) 
    I_read_data_pipeline
    (
        .clock  (clock),
        .in     (I_read_data_in),
        .out    (I_read_data_in_delayed)
    );

// -----------------------------------------------------------

    wire    [INSTR_WIDTH-1:0]   I_read_data_translated_delayed;

    delay_line 
    #(
        .DEPTH  (CONTROL_INPUT_PIPELINE_DEPTH), // XXX COME BACK AND REMOVE THIS
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
        .DEPTH  (CONTROL_INPUT_PIPELINE_DEPTH), // XXX COME BACK AND REMOVE THIS
        .WIDTH  (1)
    ) 
    cancel_pipeline
    (
        .clock  (clock),
        .in     (cancel),
        .out    (cancel_delayed)
    );

// ----------------------------------------------------------

    wire    [OPCODE_WIDTH-1:0]     OP_in;
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
    I_in
    (
        .instr              (I_read_data_in_delayed),
        .op                 (OP_in),
        .D                  (D_write_addr_in),
        .A                  (A_read_addr_in),
        .B                  (B_read_addr_in)
    );

// -----------------------------------------------------------

    wire    [OPCODE_WIDTH-1:0]     OP_AB;
    wire    [A_OPERAND_WIDTH-1:0]  A_read_addr_AB;
    wire    [B_OPERAND_WIDTH-1:0]  B_read_addr_AB;
    wire    [D_OPERAND_WIDTH-1:0]  D_write_addr_AB;

    Instr_Decoder
    #(
        .OPCODE_WIDTH       (OPCODE_WIDTH),
        .INSTR_WIDTH        (INSTR_WIDTH),
        .D_OPERAND_WIDTH    (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH    (A_OPERAND_WIDTH), 
        .B_OPERAND_WIDTH    (B_OPERAND_WIDTH)
    )
    I_translated
    (
        .instr              (I_read_data_translated_delayed),
        .op                 (OP_AB),
        .D                  (D_write_addr_AB),
        .A                  (A_read_addr_AB),
        .B                  (B_read_addr_AB)
    );

// ----------------------------------------------------------

    reg     [INSTR_WIDTH-1:0]   I_read_data_AB;

    always @(*) begin
        I_read_data_AB <= {OP_AB, D_write_addr_AB, A_read_addr_AB, B_read_addr_AB};
    end

// ----------------------------------------------------------

    wire                A_wren_ALU_raw;

    Address_Decoder 
    #(
        .ADDR_COUNT     (A_DEPTH),
        .ADDR_BASE      (A_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)

    )
    A_wren
    (
        .clock          (clock),
        .addr           (ALU_D_out),
        .hit            (A_wren_ALU_raw)
    );

// -----------------------------------------------------------

    reg     A_wren_ALU;

    always @(*) begin
        A_wren_ALU <= A_wren_ALU_raw & A_wren_other;
    end

// -----------------------------------------------------------

    wire    [A_ADDR_WIDTH-1:0]     A_write_addr_translated;

    Address_Translator
    #(
        .ADDR_COUNT         (A_DEPTH),
        .ADDR_BASE          (A_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH         (A_ADDR_WIDTH),
        .REGISTERED         (`FALSE)
    )
    A_write_addr_translator
    (
        .clock              (clock),
        .raw_address        (ALU_D_out),
        .translated_address (A_write_addr_translated)
    );

// -----------------------------------------------------------

    wire    [A_WORD_WIDTH-1:0]      A_read_data;
    wire                            A_io_in_EF_masked;
    wire                            A_io_out_EF_masked;

    Memory 
    #(
        .ALU_PIPELINE_DEPTH         (4),             // XXX PARAMETERIZE!!!
        .WORD_WIDTH                 (A_WORD_WIDTH),
        .ADDR_WIDTH                 (D_OPERAND_WIDTH),
        .RAM_ADDR_WIDTH             (A_ADDR_WIDTH),
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
    A_Memory
    (
        .clock                      (clock),

        .wren                       (A_wren_ALU),
        .write_addr_raw             (D_write_addr_in),
        .write_addr_translated      (A_write_addr_translated),
        .write_data                 (ALU_result_out),

        .rden                       (`HIGH),
        .read_addr_raw              (A_read_addr_in),
        .read_addr_translated       (A_read_addr_AB),
        .read_data                  (A_read_data),

        .IO_ready                   (IO_ready),

        .read_EF_in                 (A_io_in_EF),
        .read_EF_out                (A_io_in_EF_masked),
        .io_rden                    (A_io_rden),
        .io_in                      (A_io_in),

        .write_EF_in                (A_io_out_EF),
        .write_EF_out               (A_io_out_EF_masked),
        .io_wren                    (A_io_wren),
        .io_out                     (A_io_out)
    );

// -----------------------------------------------------------

    wire                B_wren_ALU_raw;

    Address_Decoder 
    #(
        .ADDR_COUNT     (B_DEPTH),
        .ADDR_BASE      (B_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    B_wren
    (
        .clock          (clock),
        .addr           (ALU_D_out),
        .hit            (B_wren_ALU_raw)
    );

// -----------------------------------------------------------

    reg     B_wren_ALU;

    always @(*) begin
        B_wren_ALU <= B_wren_ALU_raw & B_wren_other;
    end

// -----------------------------------------------------------

    wire    [B_ADDR_WIDTH-1:0]     B_write_addr_translated;

    Address_Translator
    #(
        .ADDR_COUNT         (B_DEPTH),
        .ADDR_BASE          (B_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH         (B_ADDR_WIDTH),
        .REGISTERED         (`FALSE)
    )
    B_write_addr_translator
    (
        .clock              (clock),
        .raw_address        (ALU_D_out),
        .translated_address (B_write_addr_translated)
    );

// -----------------------------------------------------------

    wire    [B_WORD_WIDTH-1:0]      B_read_data;
    wire                            B_io_in_EF_masked;
    wire                            B_io_out_EF_masked;

    Memory 
    #(
        .ALU_PIPELINE_DEPTH         (4),             // XXX PARAMETERIZE!!!
        .WORD_WIDTH                 (B_WORD_WIDTH),
        .ADDR_WIDTH                 (D_OPERAND_WIDTH),
        .RAM_ADDR_WIDTH             (B_ADDR_WIDTH),
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
    B_Memory
    (
        .clock                      (clock),

        .wren                       (B_wren_ALU),
        .write_addr_raw             (D_write_addr_in),
        .write_addr_translated      (B_write_addr_translated),
        .write_data                 (ALU_result_out),

        .rden                       (`HIGH),
        .read_addr_raw              (B_read_addr_in),
        .read_addr_translated       (B_read_addr_AB),
        .read_data                  (B_read_data),

        .IO_ready                   (IO_ready),

        .read_EF_in                 (B_io_in_EF),
        .read_EF_out                (B_io_in_EF_masked),
        .io_rden                    (B_io_rden),
        .io_in                      (B_io_in),

        .write_EF_in                (B_io_out_EF),
        .write_EF_out               (B_io_out_EF_masked),
        .io_wren                    (B_io_wren),
        .io_out                     (B_io_out)
    );

// -----------------------------------------------------------

    wire    IO_ready_raw;

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
        .ready              (IO_ready_raw)
    );

// -----------------------------------------------------------

    // If we cancel the instruction, annull it.
    // Avoid any I/O side-effects.
    // The ControlPath will force IO_ready high internally to prevent re-issue.

    always @(*) begin
        IO_ready <= IO_ready_raw & ~cancel_delayed;
    end

// -----------------------------------------------------------

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

// -----------------------------------------------------------

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

// -----------------------------------------------------------

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

// -----------------------------------------------------------

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
        .op_out                 (), // ECL XXX Unused for now
        .c_out                  (ALU_c_out),
        .D_out                  (ALU_D_out)
    );
endmodule
