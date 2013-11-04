module ControlPath
#(
    parameter       ALU_WORD_WIDTH          = 0,

    parameter       A_WORD_WIDTH            = 0,
    parameter       A_ADDR_WIDTH            = 0,
    parameter       B_ADDR_WIDTH            = 0,

    parameter       INSTR_WIDTH             = 0,
    parameter       OPCODE_WIDTH            = 0,
    parameter       D_OPERAND_WIDTH         = 0,
    parameter       A_OPERAND_WIDTH         = 0,
    parameter       B_OPERAND_WIDTH         = 0,

    parameter       I_WRITE_ADDR_OFFSET     = 0,
    parameter       I_WORD_WIDTH            = 0,
    parameter       I_ADDR_WIDTH            = 0,
    parameter       I_DEPTH                 = 0,
    parameter       I_RAMSTYLE              = "",
    parameter       I_INIT_FILE             = "",

    parameter       PC_RAMSTYLE             = "",
    parameter       PC_INIT_FILE            = "",
    parameter       THREAD_COUNT            = 0, 
    parameter       THREAD_ADDR_WIDTH       = 0, 

    parameter       PC_PIPELINE_DEPTH       = 0,
    parameter       I_TAP_PIPELINE_DEPTH    = 0,
    parameter       TAP_AB_PIPELINE_DEPTH   = 0,
    parameter       AB_READ_PIPELINE_DEPTH  = 0
)
(
    input   wire                            clock,

    input   wire                            I_wren_other,
    input   wire    [OPCODE_WIDTH-1:0]      I_write_op,
    input   wire    [D_OPERAND_WIDTH-1:0]   I_write_addr,
    input   wire    [ALU_WORD_WIDTH-1:0]    I_write_data,
    input   wire    [I_ADDR_WIDTH-1:0]      I_read_addr,

    input   wire    [A_WORD_WIDTH-1:0]      A_read_data, 

    input   wire                            IO_ready,

    output  reg     [INSTR_WIDTH-1:0]       I_read_data,
    output  wire    [I_ADDR_WIDTH-1:0]      pc
);

    wire    I_wren;

    Write_Enable 
    #(
        .OPCODE_WIDTH   (OPCODE_WIDTH),
        .ADDR_COUNT     (I_DEPTH),
        .ADDR_BASE      (I_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH)
    )
    I_mem_wren
    (
        .op             (I_write_op),
        .addr           (I_write_addr),
        .wren_other     (I_wren_other),
        .wren           (I_wren)
    );

    wire    [INSTR_WIDTH-1:0]       I_read_data_bram;

    RAM_SDP
    #(
        .WORD_WIDTH     (I_WORD_WIDTH),
        .ADDR_WIDTH     (I_ADDR_WIDTH),
        .DEPTH          (I_DEPTH),
        .RAMSTYLE       (I_RAMSTYLE),
        .INIT_FILE      (I_INIT_FILE)
    )
    I_mem
    (
        .clock          (clock),
        .wren           (I_wren),
        .write_addr     (I_write_addr[I_ADDR_WIDTH-1:0]),
        .write_data     (I_write_data[I_WORD_WIDTH-1:0]),
        .read_addr      (I_read_addr),
        .read_data      (I_read_data_bram)
    );

    wire    [INSTR_WIDTH-1:0]       I_read_data_tap;
 
    // This stage should get retimed into the BRAM for higher Fmax.
    delay_line 
    #(
        .DEPTH  (I_TAP_PIPELINE_DEPTH),
        .WIDTH  (INSTR_WIDTH)
    ) 
    I_TAP_pipeline
    (
        .clock  (clock),
        .in     (I_read_data_bram),
        .out    (I_read_data_tap)
    );

    always @(*) begin
        I_read_data <= I_read_data_tap;
    end

    wire    [INSTR_WIDTH-1:0]   I_read_data_AB;

    delay_line 
    #(
        .DEPTH  (TAP_AB_PIPELINE_DEPTH),
        .WIDTH  (INSTR_WIDTH)
    ) 
    TAP_AB_pipeline
    (
        .clock  (clock),
        .in     (I_read_data_tap),
        .out    (I_read_data_AB)
    );

    wire    [INSTR_WIDTH-1:0]   I_read_data_AB_masked;

    Instruction_Annuller
    #(
        .INSTR_WIDTH    (INSTR_WIDTH)
    )
    ControlPath_Annuller
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

    wire    IO_ready_ctrl;

    delay_line 
    #(
        .DEPTH  (AB_READ_PIPELINE_DEPTH),
        .WIDTH  (1)
    ) 
    AB_IO_ready_pipeline
    (
        .clock  (clock),
        .in     (IO_ready),
        .out    (IO_ready_ctrl)
    );

    wire    [OPCODE_WIDTH-1:0]      AB_op;
    wire    [D_OPERAND_WIDTH-1:0]   AB_D;

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
        .op                 (AB_op),
        .D                  (AB_D),
        .A                  (),
        .B                  ()
    );

    wire    [I_ADDR_WIDTH-1:0]      Ctrl_pc;

    Controller
    #(
        .OPCODE_WIDTH       (OPCODE_WIDTH),
        .A_WORD_WIDTH       (A_WORD_WIDTH),
        .PC_WIDTH           (I_ADDR_WIDTH), 
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH),
        .THREAD_COUNT       (THREAD_COUNT),
        .RAMSTYLE           (PC_RAMSTYLE), 
        .INIT_FILE          (PC_INIT_FILE)
    )
    Controller
    (
        .clock              (clock),
        .A                  (A_read_data),
        .op                 (AB_op),
        .D                  (AB_D[I_ADDR_WIDTH-1:0]),
        .IO_ready           (IO_ready_ctrl),
        .pc                 (Ctrl_pc) 
    );

    delay_line 
    #(
        .DEPTH  (PC_PIPELINE_DEPTH),
        .WIDTH  (I_ADDR_WIDTH)
    ) 
    pc_pipeline
    (
        .clock  (clock),
        .in     (Ctrl_pc),
        .out    (pc)
    );

endmodule

