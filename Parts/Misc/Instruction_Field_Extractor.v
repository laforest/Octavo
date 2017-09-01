
// Extracts each field out of an instruction,
// with any unused bits in the MSB before the opcode.

// Documents the overall intruction format.
// See Address_Splitter for the split D address format.

module Instruction_Field_Extractor 
#(
    parameter       WORD_WIDTH              = 0,
    parameter       OPCODE_WIDTH            = 0,
    parameter       D_OPERAND_WIDTH         = 0,
    parameter       A_OPERAND_WIDTH         = 0,
    parameter       B_OPERAND_WIDTH         = 0
)
(
    input   wire    [WORD_WIDTH-1:0]        instruction,
    output  reg     [OPCODE_WIDTH-1:0]      opcode,
    output  reg     [D_OPERAND_WIDTH-1:0]   D_operand,      // Destination 
    output  reg     [A_OPERAND_WIDTH-1:0]   A_operand,      // Source
    output  reg     [B_OPERAND_WIDTH-1:0]   B_operand       // Source
);

    initial begin
        opcode          = 0;
        D_operand       = 0;
        A_operand       = 0;
        B_operand       = 0;
    end

    localparam USED_BIT_WIDTH = OPCODE_WIDTH + D_OPERAND_WIDTH + A_OPERAND_WIDTH + B_OPERAND_WIDTH;

    always @(*) begin
        {opcode,D_operand,A_operand,B_operand}  = instruction [USED_BIT_WIDTH-1:0];
    end

endmodule

