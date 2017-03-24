
// Simulation parameters and helper functions

// This timescale matches the Altera libraries
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

// Drive the clock delay loop
// Let's assume "100 MHz", in nanoseconds
`define CLOCK_HALF_PERIOD_NS        5
`define NS_TO_PS(ns)                (1000*ns)
`define DELAY_CLOCK_HALF_PERIOD     #`NS_TO_PS(`CLOCK_HALF_PERIOD_NS)

// Wait n cycles
`define WAIT_CYCLES(n)              repeat (n) begin @(posedge clock); end

// Wait until posedge at cycle n
// (define clock and cycle in test bench)
`define UNTIL_DONE_CYCLE(n)         wait (cycle == n); @(posedge clock);  

