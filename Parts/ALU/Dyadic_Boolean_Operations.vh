
`ifndef DYADIC_OPERATIONS
`define DYADIC_OPERATIONS

    // These assume A op B, where A is the MSB into the dyadic operator.
    // See Dyadic_Boolean_Operator.v

    `define ALWAYS_ZERO 4'b0000
    `define A_AND_B     4'b1000
    `define A_AND_NOT_B 4'b0100
    `define A           4'b1100
    `define NOT_A_AND_B 4'b0010
    `define B           4'b1010
    `define A_XOR_B     4'b0110
    `define A_OR_B      4'b1110
    `define A_NOR_B     4'b0001
    `define A_XNOR_B    4'b1001
    `define NOT_B       4'b0101
    `define A_OR_NOT_B  4'b1101
    `define NOT_A       4'b0011
    `define NOT_A_OR_B  4'b1011
    `define A_NAND_B    4'b0111
    `define ALWAYS_ONE  4'b1111

`endif

