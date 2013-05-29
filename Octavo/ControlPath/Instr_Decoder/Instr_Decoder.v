module Instr_Decoder 
#(
    parameter       INSTR_WIDTH             = 0,
    parameter       OPCODE_WIDTH            = 0,
    parameter       D_OPERAND_WIDTH         = 0,
    parameter       A_OPERAND_WIDTH         = 0,
    parameter       B_OPERAND_WIDTH         = 0
)
(
    input   wire    [INSTR_WIDTH-1:0]       instr,
    output  reg     [OPCODE_WIDTH-1:0]      op,
    output  reg     [D_OPERAND_WIDTH-1:0]   D,    
    output  reg     [A_OPERAND_WIDTH-1:0]   A,    
    output  reg     [B_OPERAND_WIDTH-1:0]   B    
);
    always @(*) begin
        op  <= instr[(INSTR_WIDTH-1)                                                        : (D_OPERAND_WIDTH + A_OPERAND_WIDTH + B_OPERAND_WIDTH)];
        D   <= instr[(INSTR_WIDTH - OPCODE_WIDTH - 1)                                       : (A_OPERAND_WIDTH + B_OPERAND_WIDTH)];
        A   <= instr[(INSTR_WIDTH - OPCODE_WIDTH - D_OPERAND_WIDTH - 1)                     : B_OPERAND_WIDTH];
        B   <= instr[(INSTR_WIDTH - OPCODE_WIDTH - D_OPERAND_WIDTH - A_OPERAND_WIDTH - 1)   : 0];
    end
endmodule


