
`define HIGH  1'b1
`define LOW   1'b0

`define TRUE  1
`define FALSE 0

`define FULL  `HIGH
`define EMPTY `LOW

// There should never be need to increase or reduce this.
`define OPCODE_WIDTH    4

// Opcodes
// Logic (first 3 bits, MSB === 0) This affects Bitwise code in the ALU.
`define XOR     `OPCODE_WIDTH'h0
`define AND     `OPCODE_WIDTH'h1
`define OR      `OPCODE_WIDTH'h2
`define SUB     `OPCODE_WIDTH'h3 // opcode[2] === 0 Use bit as addsub select
`define ADD     `OPCODE_WIDTH'h4 // opcode[2] === 1
`define UND1    `OPCODE_WIDTH'h5 
`define UND2    `OPCODE_WIDTH'h6
`define UND3    `OPCODE_WIDTH'h7 

// Multiplication (MSB === 1, LO/HI selected by opcode[0] inverse, signed/unsigned selected by opcode[1] inverse) 
`define MHS     `OPCODE_WIDTH'h8 // opcode[1:0] === {0,0} signed, high
`define MLS     `OPCODE_WIDTH'h9 // opcode[1:0] === {0,1} signed, low
`define MHU     `OPCODE_WIDTH'hA // opcode[1:0] === {1,0} unsigned, high

// Flow Control (MSB === 1, remaining 5 opcodes, wren to mem === 0)
`define JMP     `OPCODE_WIDTH'hB
`define JZE     `OPCODE_WIDTH'hC
`define JNZ     `OPCODE_WIDTH'hD
`define JPO     `OPCODE_WIDTH'hE
`define JNE     `OPCODE_WIDTH'hF

// ********** For Simulation **********
// This matches the Altera libraries
// alter # values in testbench to match
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

`define CLOCK_PERIOD_NS 10
`define CLOCK_HALF_PERIOD_NS 5

`define NS2PS(ns) (1000*ns)

`define DELAY_CLOCK_PERIOD #`NS2PS(`CLOCK_PERIOD_NS)
`define DELAY_CLOCK_HALF_PERIOD #`NS2PS(`CLOCK_HALF_PERIOD_NS)

`define DELAY_CLOCK_CYCLES(count) #(count*`NS2PS(`CLOCK_PERIOD_NS))
// ***********************************


