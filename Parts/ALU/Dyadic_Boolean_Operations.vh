
`ifndef DYADIC_OPERATIONS
`define DYADIC_OPERATIONS

    // These assume A op B, where A is the MSB into the dyadic operator.
    // See Dyadic_Boolean_Operator.v

    `define DYADIC_ALWAYS_ZERO 4'b0000
    `define DYADIC_A_AND_B     4'b1000
    `define DYADIC_A_AND_NOT_B 4'b0100
    `define DYADIC_A           4'b1100
    `define DYADIC_NOT_A_AND_B 4'b0010
    `define DYADIC_B           4'b1010
    `define DYADIC_A_XOR_B     4'b0110
    `define DYADIC_A_OR_B      4'b1110
    `define DYADIC_A_NOR_B     4'b0001
    `define DYADIC_A_XNOR_B    4'b1001
    `define DYADIC_NOT_B       4'b0101
    `define DYADIC_A_OR_NOT_B  4'b1101
    `define DYADIC_NOT_A       4'b0011
    `define DYADIC_NOT_A_OR_B  4'b1011
    `define DYADIC_A_NAND_B    4'b0111
    `define DYADIC_ALWAYS_ONE  4'b1111

`endif

