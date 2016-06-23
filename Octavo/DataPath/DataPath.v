module DataPath
#(
    parameter       ALU_WORD_WIDTH                                  = 0,

    parameter       INSTR_WIDTH                                     = 0,
    parameter       OPCODE_WIDTH                                    = 0,
    parameter       CONTROL_WIDTH                                   = 0,
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

    parameter       TAP_AB_PIPELINE_DEPTH                           = 0,
    parameter       AB_READ_PIPELINE_DEPTH                          = 0,
    parameter       AB_ALU_PIPELINE_DEPTH                           = 0,

    parameter       LOGIC_OPCODE_WIDTH                              = 0,
    parameter       INSTR_DECODER_INIT_FILE                         = ""
)
(
    input   wire                                                    clock,

    input   wire    [INSTR_WIDTH-1:0]                               I_read_data_in,         // stage 1
    input   wire    [INSTR_WIDTH-1:0]                               I_read_data_translated, // stage 3

    output  wire    [ALU_WORD_WIDTH-1:0]                            ALU_result_out,
    output  wire    [D_OPERAND_WIDTH-1:0]                           ALU_D_out,

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
        .instr              (I_read_data_in),
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
        .instr              (I_read_data_translated),
        .op                 (OP_AB),
        .D                  (D_write_addr_AB),
        .A                  (A_read_addr_AB),
        .B                  (B_read_addr_AB)
    );

// ----------------------------------------------------------

    wire    control_wren;
    
    Address_Decoder 
    #(
        .ADDR_COUNT     (16 * 8),                   // XXX ECL HARDCODED
        .ADDR_BASE      (3100),                     // XXX ECL HARDCODED (and random)
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)

    )
    Control_Write
    (
        .clock          (clock),
        .addr           (ALU_D_out),
        .hit            (control_wren)
    );

// ----------------------------------------------------------

    wire    [CONTROL_WIDTH-1:0]     control;

    InstructionDecoder
    #(
        .OPCODE_COUNT       (16),                   // XXX ECL HARDCODED
        .OPCODE_WIDTH       (OPCODE_WIDTH),
        .CONTROL_WIDTH      (CONTROL_WIDTH),
        .THREAD_COUNT       (8),                    // XXX ECL HARDCODED
        .THREAD_ADDR_WIDTH  (3),
        .INITIAL_THREAD     (4),                    // XXX ECL HARDCODED
        .RAMSTYLE           ("MLAB,no_rw_check"),   // XXX ECL HARDCODED 
        .INIT_FILE          (INSTR_DECODER_INIT_FILE)    // XXX ECL HARDCODED
    )
    Control_Generator
    (
        .clock              (clock),
        .wren               (control_wren),
        .write_addr         (ALU_D_out),
        .write_data         (ALU_result_out),
        .rden               (`HIGH),
        .opcode             (OP_AB),
        .control            (control)
    );

// ----------------------------------------------------------

    wire                A_wren_ALU;

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
        .hit            (A_wren_ALU)
    );

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

    wire                B_wren_ALU;

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
        .hit            (B_wren_ALU)
    );

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
        IO_ready <= IO_ready_raw & ~cancel;
    end

// -----------------------------------------------------------

    wire    [D_OPERAND_WIDTH-1:0]   D_write_addr_AB_masked;

    Instruction_Annuller
    #(
        .INSTR_WIDTH    (D_OPERAND_WIDTH)
    )
    DataPath_Annuller
    (
        .instr_in       (D_write_addr_AB),
        .annul          (~IO_ready),
        .instr_out      (D_write_addr_AB_masked)
    ); 

// -----------------------------------------------------------

    wire    [D_OPERAND_WIDTH-1:0]   ALU_D_in;

    delay_line 
    #(
        .DEPTH  (AB_READ_PIPELINE_DEPTH),
        .WIDTH  (D_OPERAND_WIDTH)
    ) 
    AB_read_pipeline
    (
        .clock  (clock),
        .in     (D_write_addr_AB_masked),
        .out    (ALU_D_in)
    );

// -----------------------------------------------------------

    ALU 
    #(
        .CONTROL_WIDTH          (CONTROL_WIDTH),
        .WORD_WIDTH             (ALU_WORD_WIDTH),
        .D_OPERAND_WIDTH        (D_OPERAND_WIDTH),
        .LOGIC_OPCODE_WIDTH     (LOGIC_OPCODE_WIDTH)
    )
    ALU 
    (
        .clock                  (clock),
        .control                (control),
        .D_in                   (ALU_D_in),
        .A                      (A_read_data),
        .B                      (B_read_data),
        .R                      (ALU_result_out),
        .D_out                  (ALU_D_out)
    );
endmodule
