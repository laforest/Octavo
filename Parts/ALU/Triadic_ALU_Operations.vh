
// See Triadic_ALU.v

`ifndef TRIADIC_ALU_OPERATIONS
`define TRIADIC_ALU_OPERATIONS

    // Number of bits in ALU control word, never changes.
    `define TRIADIC_CTRL_WIDTH      20

    // First, some primitives

    `include "Dyadic_Boolean_Operations.vh"

    `define TRIADIC_SINGLE          1'b0
    `define TRIADIC_DUAL            1'b1

    `define SELECT_R                2'd0
    `define SELECT_R_ZERO           2'd1
    `define SELECT_R_NEG            2'd2
    `define SELECT_S                2'd3

    `define SHIFT_NONE              2'd0
    `define SHIFT_LEFT              2'd1
    `define SHIFT_LEFT_SIGNED       2'd2
    `define SHIFT_RIGHT             2'd3

    `define SPLIT_YES               1'd0
    `define SPLIT_NO                1'd1

    `define ADDSUB_A_PLUS_B         2'b00
    `define ADDSUB_MINUS_A_PLUS_B   2'b01
    `define ADDSUB_A_MINUS_B        2'b10
    `define ADDSUB_MINUS_A_MINUS_B  2'b11

    // Second, some useful computations

    `define ALU_NOP         ({`SPLIT_NO,`SHIFT_NONE,`DYADIC_ALWAYS_ZERO,`ADDSUB_A_PLUS_B,`TRIADIC_SINGLE,`DYADIC_ALWAYS_ZERO,`DYADIC_ALWAYS_ZERO,`SELECT_R})
    `define ALU_A_PLUS_B    ({`SPLIT_NO,`SHIFT_NONE,`DYADIC_B,`ADDSUB_A_PLUS_B,`TRIADIC_SINGLE,`DYADIC_ALWAYS_ZERO,`DYADIC_ALWAYS_ZERO,`SELECT_R})
    `define ALU_DMOV        ({`SPLIT_YES,`SHIFT_NONE,`DYADIC_A,`ADDSUB_A_PLUS_B,`TRIADIC_DUAL,`DYADIC_B,`DYADIC_A,`SELECT_S})

`endif

