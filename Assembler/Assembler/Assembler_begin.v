
// "module <name>" precedes.

#(
    parameter INIT_FILE         = "",
    parameter START_ADDR        = 0,
    parameter END_ADDR          = 0,
    parameter ADDR_WIDTH        = log2(END_ADDR - START_ADDR + 1),
    parameter WORD_WIDTH        = 36,
    parameter INSTR_WIDTH       = 36,
    parameter OPCODE_WIDTH      = 4,
    parameter D_OPERAND_WIDTH   = 12,
    parameter A_OPERAND_WIDTH   = 10,
    parameter B_OPERAND_WIDTH   = 10
)
(
    // no inputs/outputs
);
    `include "../../Octavo/Misc/log2.v"

    // Counter to clear memory
    integer i;
    // current assembled instruction
    reg [INSTR_WIDTH-1:0]   instr;
    // current assembly location
    reg [ADDR_WIDTH-1:0]    here    = START_ADDR;
    // The memory image
    reg [WORD_WIDTH-1:0]    mem     [(END_ADDR - START_ADDR):0];

    // Makes sure of proper bit widths for each instruction field
    function [INSTR_WIDTH-1:0] pack;
        input [OPCODE_WIDTH-1:0]    OP;
        input [D_OPERAND_WIDTH-1:0] D;
        input [A_OPERAND_WIDTH-1:0] A;
        input [B_OPERAND_WIDTH-1:0] B;
        pack = {OP, D, A, B};
    endfunction

    // Continue assembling at new address, depends on pre-incrementing 'here'.
    `define ALIGN(addr) here = addr - 1;
    // Name current location, place after contents (L or I) on same line
    `define N(name) name = here;
    // Assemble a literal number
    `define L(number) here = here + 1;  mem[here] = number; 
    // Assemble an instruction
    `define I(OP, D, A, B)  instr = pack(OP, D, A, B); `L(instr)
    // Resolve Literal (set named location to address of current location)
    `define RL(name) mem[name] = here;
    // Set *empty* field at named address with address of current location
    // Resolve D 
    `define RD(name) mem[name] = mem[name] | (here << (A_OPERAND_WIDTH + B_OPERAND_WIDTH));
    // Resolve A 
    `define RA(name) mem[name] = mem[name] | (here << (B_OPERAND_WIDTH));
    // Resolve B 
    `define RB(name) mem[name] = mem[name] | here;
    // Define your names right after here. (Can't do so in initial block)
    `define DEF(name) reg [ADDR_WIDTH-1:0] name;

    //Conveniently encodes to all zeroes. 
    // The hardware depends on this for initial startup.
    // The software depends on this to (re)set mem[0] to 0 to act as a MIPS r0.
    `define NOP `I(`XOR, 0, 0, 0)

// Name definitions follow.

