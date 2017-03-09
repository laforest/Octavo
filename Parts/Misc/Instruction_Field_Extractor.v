
// Extracts each field out of an instruction,
// with any unused bits in the MSB before the opcode.

module Instruction_Field_Extractor 
#(
    parameter       INSTRUCTION_WIDTH       = 0,
    parameter       OPCODE_WIDTH            = 0,
    parameter       D_OPERAND_WIDTH         = 0,
    parameter       A_OPERAND_WIDTH         = 0,
    parameter       B_OPERAND_WIDTH         = 0,
    // Don't set at instantiation
    // Assumes D_OPERAND_WIDTH is even, else MSB dropped
    parameter       D_SPLIT_WIDTH           = D_OPERAND_WIDTH / 2
)
(
    input   wire    [INSTRUCTION_WIDTH-1:0] instruction,
    output  reg     [OPCODE_WIDTH-1:0]      opcode,
    output  reg     [D_OPERAND_WIDTH-1:0]   D_operand,      // Destination 
    output  reg     [D_SPLIT_WIDTH-1:0]     D_split_lower,  // Split addressing mode
    output  reg     [D_SPLIT_WIDTH-1:0]     D_split_upper,
    output  reg     [A_OPERAND_WIDTH-1:0]   A_operand,      // Source
    output  reg     [B_OPERAND_WIDTH-1:0]   B_operand       // Source
);

    initial begin
        opcode          = 0;
        D_operand       = 0;
        D_split_lower   = 0;
        D_split_upper   = 0;
        A_operand       = 0;
        B_operand       = 0;
    end

    localparam USED_BIT_WIDTH = OPCODE_WIDTH + D_OPERAND_WIDTH + A_OPERAND_WIDTH + B_OPERAND_WIDTH;

    always @(*) begin
        {opcode,D_operand,A_operand,B_operand}  = instruction [USED_BIT_WIDTH-1:0];
        {D_split_upper,D_split_lower}           = D_operand   [(D_SPLIT_WIDTH*2)-1:0];
    end

endmodule

