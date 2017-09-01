
// The Instruction Fetch/Decode takes in a Program Counter (PC) value and produces
// the current thread instruction, and the decoded control signals for the
// opcode of the instruction.

module Instruction_Fetch_Decode
#(
    // Instruction format
    parameter       OPCODE_WIDTH            = 0,
    parameter       D_OPERAND_WIDTH         = 0,
    parameter       A_OPERAND_WIDTH         = 0,
    parameter       B_OPERAND_WIDTH         = 0,
    // Instruction Memory (shared)
    parameter       IM_WORD_WIDTH           = 0,
    parameter       IM_ADDR_WIDTH           = 0,
    parameter       IM_READ_NEW             = 0,
    parameter       IM_DEPTH                = 0,
    parameter       IM_RAMSTYLE             = "",
    parameter       IM_INIT_FILE            = "",
    // Opcode Decoder Memory (multithreaded)
    parameter       OD_WORD_WIDTH           = 0,
    parameter       OD_ADDR_WIDTH           = 0,
    parameter       OD_READ_NEW             = 0,
    parameter       OD_THREAD_DEPTH         = 0,
    parameter       OD_RAMSTYLE             = "",
    parameter       OD_INIT_FILE            = "",
    parameter       OD_INITIAL_THREAD_READ  = 0,
    parameter       OD_INITIAL_THREAD_WRITE = 0,
    // Memory-mapping (for split address mode)
    parameter       DB_BASE_ADDR            = 0,
    // Multithreading
    parameter       THREAD_COUNT            = 0,
    parameter       THREAD_COUNT_WIDTH      = 0
)
(
    input   wire                            clock,

    input   wire                            im_wren,
    input   wire    [IMEM_ADDR_WIDTH-1:0]   im_write_addr,
    input   wire    [IMEM_WORD_WIDTH-1:0]   im_write_data,
    input   wire                            im_rden,
    input   wire    [IMEM_ADDR_WIDTH-1:0]   im_read_addr,

    input   wire                            od_wren,
    input   wire    [OPCODE_WIDTH-1:0]      od_write_addr,
    input   wire    [CMEM_WORD_WIDTH-1:0]   od_write_data,

    output  reg     [CMEM_WORD_WIDTH-1:0]   ALU_control,
    output  wire    [D_OPERAND_WIDTH-1:0]   DA,
    output  wire    [D_OPERAND_WIDTH-1:0]   DB,
    output  reg     [A_OPERAND_WIDTH-1:0]   A,
    output  reg     [B_OPERAND_WIDTH-1:0]   B
);

// --------------------------------------------------------------------

    initial begin
        ALU_control = 0;
        A           = 0;
        B           = 0;
    end

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 0

    // Instruction Memory. Shared by all threads so they can share code.

    wire [IM_WORD_WIDTH-1:0] instruction;

    RAM_SDP 
    #(
        .WORD_WIDTH     (IM_WORD_WIDTH),
        .ADDR_WIDTH     (IM_ADDR_WIDTH),
        .DEPTH          (IM_DEPTH),
        .RAMSTYLE       (IM_RAMSTYLE),
        .READ_NEW_DATA  (IM_READ_NEW),
        // Must use init file, else all instructions are NOPs
        .USE_INIT_FILE  (1),
        .INIT_FILE      (IM_INIT_FILE)
    )
    IM
    (
        .clock          (clock),
        .wren           (im_wren),
        .write_addr     (im_write_addr),
        .write_data     (im_write_data),
        .rden           (im_rden),
        .read_addr      (im_read_addr),
        .read_data      (instruction)
    );

// --------------------------------------------------------------------

    // Extract instruction fields

    wire [OPCODE_WIDTH-1:0]     opcode;
    wire [D_OPERAND_WIDTH-1:0]  D_operand;
    wire [A_OPERAND_WIDTH-1:0]  A_operand;
    wire [B_OPERAND_WIDTH-1:0]  B_operand;

    Instruction_Field_Extractor 
    #(
        .WORD_WIDTH         (IM_WORD_WIDTH),
        .OPCODE_WIDTH       (OPCODE_WIDTH),
        .D_OPERAND_WIDTH    (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH    (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH    (B_OPERAND_WIDTH)
    )
    IFE_OD
    (
        .instruction        (instruction),
        .opcode             (opcode),
        .D_operand          (D_operand),
        .A_operand          (A_operand),
        .B_operand          (B_operand)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 1

    // Register everything.
    // Pass along instruction memory read enable to opcode decoder memory
    // (might lead to power optimization later on)

    reg  [OPCODE_WIDTH-1:0]     opcode_stage1       = 0;
    reg  [D_OPERAND_WIDTH-1:0]  D_operand_stage1    = 0;
    reg  [A_OPERAND_WIDTH-1:0]  A_operand_stage1    = 0;
    reg  [B_OPERAND_WIDTH-1:0]  B_operand_stage1    = 0;
    reg                         od_rden             = 0;

    always @(posedge clock) begin
        opcode_stage1       <= opcode;
        D_operand_stage1    <= D_operand;
        A_operand_stage1    <= A_operand;
        B_operand_stage1    <= B_operand;
        od_rden             <= im_rden;
    end 

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 2

    // Decode opcode into ALU control bits

    wire [OD_WORD_WIDTH-1:0] ALU_control_stage2;

    RAM_SDP_Multithreaded
    #(
        .WORD_WIDTH             (OD_WORD_WIDTH),
        .ADDR_WIDTH             (OD_ADDR_WIDTH),
        .THREAD_DEPTH           (OD_THREAD_DEPTH),
        .RAMSTYLE               (OD_RAMSTYLE),
        .READ_NEW_DATA          (OD_READ_NEW),
        // Must use init file, else all instructions are NOPs
        .USE_INIT_FILE          (1),
        .INIT_FILE              (OD_INIT_FILE),
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH),
        .INITIAL_THREAD_READ    (OD_INITIAL_THREAD_READ),
        .INITIAL_THREAD_WRITE   (OD_INITIAL_THREAD_WRITE)
    )
    OD
    (
        .clock                  (clock),
        .wren                   (od_wren),
        .write_addr             (od_write_addr),
        .write_data             (od_write_data),
        .rden                   (od_rden),
        .read_addr              (opcode_stage1), 
        .read_data              (ALU_control_stage2)
    );

// --------------------------------------------------------------------

    // Synchronize the rest of the signals

    reg  [D_OPERAND_WIDTH-1:0]  D_operand_stage2    = 0;
    reg  [A_OPERAND_WIDTH-1:0]  A_operand_stage2    = 0;
    reg  [B_OPERAND_WIDTH-1:0]  B_operand_stage2    = 0;

    always @(posedge clock) begin
        D_operand_stage2    <= D_operand_stage1;
        A_operand_stage2    <= A_operand_stage1;
        B_operand_stage2    <= B_operand_stage1;
    end 

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 3

    // Split the D operand into two addresses 
    // if the current opcode uses the split addressing mode
    // and send out.

    wire split;

    Split_Extractor
    #(
        .WORD_WIDTH (OD_WORD_WIDTH)
    )
    SE
    (
        .control    (ALU_control_stage2),
        .split      (split)
    );

// --------------------------------------------------------------------

    Address_Splitter
    #(
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .DB_BASE_ADDR   (DB_BASE_ADDR)
    )
    AS
    (
        .clock          (clock),
        .split          (split),
        .D              (D_operand_stage2),
        .DA             (DA),
        .DB             (DB)
    );

// --------------------------------------------------------------------

    // Sync everything else and send out

    always @(posedge clock) begin
        ALU_control <= ALU_control_stage2;
        A           <= A_operand_stage2;
        B           <= B_operand_stage2;
    end 
    
endmodule

