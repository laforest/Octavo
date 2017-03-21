
// The Instruction Memory takes in a Program Counter (PC) value and produces
// the current thread instruction, and the decoded control signals for the
// opcode of the instruction.

module Instruction_Memory
#(
    // Instruction format
    parameter       INSTRUCTION_WIDTH               = 0,
    parameter       OPCODE_WIDTH                    = 0,
    parameter       D_OPERAND_WIDTH                 = 0,
    parameter       A_OPERAND_WIDTH                 = 0,
    parameter       B_OPERAND_WIDTH                 = 0,
    // Instruction Mem
    parameter       IMEM_WORD_WIDTH                 = 0,
    parameter       IMEM_ADDR_WIDTH                 = 0,
    parameter       IMEM_READ_NEW                   = 0,
    parameter       IMEM_DEPTH                      = 0,
    parameter       IMEM_RAMSTYLE                   = "",
    parameter       IMEM_INIT_FILE                  = "",
    // Control Mem 
    parameter       CMEM_USE_COMPOSITE              = 0,
    parameter       CMEM_INIT_FILE                  = "",
    parameter       CMEM_RAMSTYLE                   = "",
    parameter       CMEM_READ_NEW_DATA              = 0,
    parameter       CMEM_SUB_INIT_FILE              = "",
    parameter       CMEM_SUB_ADDR_WIDTH             = 0,
    parameter       CMEM_SUB_DEPTH                  = 0,
    parameter       CMEM_WORD_WIDTH                 = 0,
    // Multithreading
    parameter       THREAD_COUNT                    = 0,
    parameter       THREAD_COUNT_WIDTH              = 0
)
(
    input   wire                                    clock,
    input   wire                                    imem_wren,
    input   wire    [IMEM_ADDR_WIDTH-1:0]           imem_write_addr,
    input   wire    [IMEM_WORD_WIDTH-1:0]           imem_write_data,
    input   wire                                    imem_rden,
    input   wire    [IMEM_ADDR_WIDTH-1:0]           imem_read_addr,
    output  wire    [IMEM_WORD_WIDTH-1:0]           imem_read_data,
    output  reg     [IMEM_WORD_WIDTH-1:0]           imem_read_data_reg,
    input   wire                                    cmem_wren,
    input   wire    [OPCODE_WIDTH-1:0]              cmem_write_addr,
    input   wire    [CMEM_WORD_WIDTH-1:0]           cmem_write_data,
    output  wire    [CMEM_WORD_WIDTH-1:0]           cmem_read_data,
    output  reg     [CMEM_WORD_WIDTH-1:0]           cmem_read_data_reg
);

// --------------------------------------------------------------------

    initial begin
        imem_read_data_reg = 0;
        cmem_read_data_reg  = 0;
    end

// --------------------------------------------------------------------
// Stage 0

    RAM_SDP 
    #(
        .WORD_WIDTH     (IMEM_WORD_WIDTH),
        .ADDR_WIDTH     (IMEM_ADDR_WIDTH),
        .DEPTH          (IMEM_DEPTH),
        .RAMSTYLE       (IMEM_RAMSTYLE),
        .READ_NEW_DATA  (IMEM_READ_NEW),
        // Must use init file, else all instructions are NOPs
        .USE_INIT_FILE  (1),
        .INIT_FILE      (IMEM_INIT_FILE)
    )
    IMEM
    (
        .clock          (clock),
        .wren           (imem_wren),
        .write_addr     (imem_write_addr),
        .write_data     (imem_write_data),
        .rden           (imem_rden),
        .read_addr      (imem_read_addr),
        .read_data      (imem_read_data)
    );

// --------------------------------------------------------------------
// Stage 1

    reg cmem_rden = 0;

    always @(posedge clock) begin
        imem_read_data_reg <= imem_read_data;
        cmem_rden           <= imem_rden;
    end 

// --------------------------------------------------------------------

    wire [OPCODE_WIDTH-1:0] cmem_read_addr;

    Instruction_Field_Extractor 
    #(
        .INSTRUCTION_WIDTH   (INSTRUCTION_WIDTH),
        .OPCODE_WIDTH        (OPCODE_WIDTH),
        .D_OPERAND_WIDTH     (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH     (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH     (B_OPERAND_WIDTH)
    )
    CMEM_READ_ADDR
    (
        .instruction        (imem_read_data_reg),
        .opcode             (cmem_read_addr),
        .D_operand          (),
        .D_split_lower      (),
        .D_split_upper      (),
        .A_operand          (),
        .B_operand          ()
    );

// --------------------------------------------------------------------
// Stage 2

    Control_Memory
    #(
        // Use composite or monolithic inferred RAM?
        .USE_COMPOSITE      (CMEM_USE_COMPOSITE),
        .INIT_FILE          (CMEM_INIT_FILE),
        // Individual sub-RAMs (composite)
        .SUB_INIT_FILE      (CMEM_SUB_INIT_FILE),
        .SUB_ADDR_WIDTH     (CMEM_SUB_ADDR_WIDTH),
        .SUB_DEPTH          (CMEM_SUB_DEPTH),
        // Common parameters
        .RAMSTYLE           (CMEM_RAMSTYLE),
        .READ_NEW_DATA      (CMEM_READ_NEW_DATA),
        // Interface (per thread)
        .OPCODE_WIDTH       (OPCODE_WIDTH),
        .CONTROL_WIDTH      (CMEM_WORD_WIDTH),
        // Multithreading
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    CMEM
    (
        .clock              (clock),
        .wren               (cmem_wren),
        .write_addr         (cmem_write_addr),
        .write_data         (cmem_write_data),
        .rden               (cmem_rden),
        .read_addr          (cmem_read_addr),
        .read_data          (cmem_read_data)
    );


// --------------------------------------------------------------------
// Stage 3

    always @(posedge clock) begin
        cmem_read_data_reg <= cmem_read_data;
    end 

endmodule

