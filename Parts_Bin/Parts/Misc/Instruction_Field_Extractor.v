
// Pulls out each field out of an instruction.
// Format: OP:D:A:B, with any spare bits before B in the LSB positions.

module Instruction_Field_Extractor 
#(
    parameter       INSTRUCTION_WIDTH       = 0,
    parameter       OPCODE_WIDTH            = 0,
    parameter       D_OPERAND_WIDTH         = 0,
    parameter       A_OPERAND_WIDTH         = 0,
    parameter       B_OPERAND_WIDTH         = 0
)
(
    input   wire    [INSTRUCTION_WIDTH-1:0] instruction,
    output  reg     [OPCODE_WIDTH-1:0]      opcode,
    output  reg     [D_OPERAND_WIDTH-1:0]   D_operand,   // Destination 
    output  reg     [A_OPERAND_WIDTH-1:0]   A_operand,   // Source
    output  reg     [B_OPERAND_WIDTH-1:0]   B_operand    // Source
);
    always @(*) begin
        opcode      <= instr[(INSTR_WIDTH-1)                                                        : (D_OPERAND_WIDTH + A_OPERAND_WIDTH + B_OPERAND_WIDTH)];
        D_operand   <= instr[(INSTR_WIDTH - OPCODE_WIDTH - 1)                                       : (A_OPERAND_WIDTH + B_OPERAND_WIDTH)];
        A_operand   <= instr[(INSTR_WIDTH - OPCODE_WIDTH - D_OPERAND_WIDTH - 1)                     : B_OPERAND_WIDTH];
        B_operand   <= instr[(INSTR_WIDTH - OPCODE_WIDTH - D_OPERAND_WIDTH - A_OPERAND_WIDTH - 1)   : 0];
    end
endmodule

