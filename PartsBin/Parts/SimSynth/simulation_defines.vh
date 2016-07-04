
// Simulation parameters and helper functions

// This timescale matches the Altera libraries
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

// Let's assume "100 MHz", in nanoseconds
`define CLOCK_HALF_PERIOD_NS        5
`define CLOCK_PERIOD_NS             (`CLOCK_HALF_PERIOD_NS * 2)

`define NS_TO_PS(ns)                (1000*ns)

`define DELAY_CLOCK_HALF_PERIOD     #`NS_TO_PS(`CLOCK_HALF_PERIOD_NS)
`define DELAY_CLOCK_PERIOD          #`NS_TO_PS(`CLOCK_PERIOD_NS)

`define DELAY_CLOCK_CYCLES(count)   #(count * `NS2_TO_PS(`CLOCK_PERIOD_NS))

