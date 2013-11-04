// Simple test of I/O predication, expects 1 port per mem
// Outputs an incrementing accumulator, should hang if I/O not ready
// Test by making input EMPTY and output FULL

`define PC_FILE         "accumulators.pc"
`define MEM_FILE        "accumulators.mem"
`define SIMD_MEM_FILE   "SIMD_accumulators.mem"
`define SIMD_WORD_WIDTH 36
`define THREADS         8
`define ADDR_WIDTH      10
`define MEM_DEPTH       2**10

// Make addresses multiples of a power of 2: easy to track in the hex instruction word
`define THREAD_0_START `ADDR_WIDTH'd4
`define THREAD_1_START `ADDR_WIDTH'd16
`define THREAD_2_START `ADDR_WIDTH'd32
`define THREAD_3_START `ADDR_WIDTH'd48
`define THREAD_4_START `ADDR_WIDTH'd64
`define THREAD_5_START `ADDR_WIDTH'd80
`define THREAD_6_START `ADDR_WIDTH'd96
`define THREAD_7_START `ADDR_WIDTH'd112

module thread_pc
    `include "../Assembler/Assembler_begin.v"
    `include "../Assembler/Assembler_mem_init.v"
`define PC_FILE         "accumulators.pc"
`define MEM_FILE        "accumulators.mem"
`define SIMD_MEM_FILE   "SIMD_accumulators.mem"
`define SIMD_WORD_WIDTH 36
`define THREADS         8
`define ADDR_WIDTH      10
`define MEM_DEPTH       2**10


    // Duplicate initial PC for I/O instruction predication

    `L({`THREAD_0_START, `THREAD_0_START})
    `L({`THREAD_1_START, `THREAD_1_START})
    `L({`THREAD_2_START, `THREAD_2_START})
    `L({`THREAD_3_START, `THREAD_3_START})
    `L({`THREAD_4_START, `THREAD_4_START})
    `L({`THREAD_5_START, `THREAD_5_START})
    `L({`THREAD_6_START, `THREAD_6_START})
    `L({`THREAD_7_START, `THREAD_7_START})

    `include "../Assembler/Assembler_end.v"
endmodule

module do_thread_pc ();
    thread_pc
    #(
        .INIT_FILE      (`PC_FILE),
        .START_ADDR     (0),
        .END_ADDR       (`THREADS - 1),
        .WORD_WIDTH     (`ADDR_WIDTH * 2)
    )
    thread_pc ();
endmodule

`define A_IO_READ_PORT_BASE_ADDR  1022
`define A_IO_WRITE_PORT_BASE_ADDR 1022

`define B_IO_READ_PORT_BASE_ADDR  1023
`define B_IO_WRITE_PORT_BASE_ADDR 2047

`define ACCUMULATOR \
    `I(`ADD, accumulator, accumulator, one) `N(loop) \
    `I(`ADD, `A_IO_WRITE_PORT_BASE_ADDR, accumulator, 0) \
    `I(`JMP, loop, 0, 0)

`define DO_NOTHING                             \
    `I(`JMP, do_nothing, 0, 0) `N(do_nothing) `RD(do_nothing)

 // output a marker value: 3,735,928,559 in decimal
`define DEADBEEF                                                          \
    `I(`ADD, `B_IO_WRITE_PORT_BASE_ADDR, deadbeef, 0) `N(marker_deadbeef) \
    `I(`JMP, marker_deadbeef, 0, 0)

module test
    `include "../Assembler/Assembler_begin.v"

    // Named values
    `DEF(accumulator)    
    `DEF(one)    
    `DEF(deadbeef)    
    `DEF(marker_deadbeef)
    `DEF(loop)
    `DEF(do_nothing)

    `include "../Assembler/Assembler_mem_init.v"

    // Threads 1-7 get a NOP to align their execution with Thread 0
    // Thread 0 necessarily starts with a NOP (initial I mem output register after reset)
    // ECL Little bug here: Thread 0 must start at 1, so these literals get executed...oops.
    `ALIGN(1)
    `L('hdeadbeef)  `N(deadbeef)
    `L('h1)         `N(one)
    `L('h0)         `N(accumulator)
    `ALIGN(`THREAD_0_START)
    `ACCUMULATOR

    `L('h0)         `N(accumulator)
    `ALIGN(`THREAD_1_START)
    `NOP
    `ACCUMULATOR

    `L('h0)         `N(accumulator)
    `ALIGN(`THREAD_2_START)
    `NOP
    `ACCUMULATOR

    `L('h0)         `N(accumulator)
    `ALIGN(`THREAD_3_START)
    `NOP
    `ACCUMULATOR

    `L('h0)         `N(accumulator)
    `ALIGN(`THREAD_4_START)
    `NOP
    `ACCUMULATOR

    `L('h0)         `N(accumulator)
    `ALIGN(`THREAD_5_START)
    `NOP
    `ACCUMULATOR

    `L('h0)         `N(accumulator)
    `ALIGN(`THREAD_6_START)
    `NOP
    `ACCUMULATOR

    `L('h0)         `N(accumulator)
    `ALIGN(`THREAD_7_START)
    `NOP
    `ACCUMULATOR

    `include "../Assembler/Assembler_end.v"
endmodule


module do_test ();
    test
    #(
        .INIT_FILE      (`MEM_FILE),
        .START_ADDR     (0),
        .END_ADDR       (`MEM_DEPTH - 1)
    )
    test ();
endmodule

module SIMD_do_test ();
    test
    #(
        .WORD_WIDTH     (`SIMD_WORD_WIDTH),
        .INIT_FILE      (`SIMD_MEM_FILE),
        .START_ADDR     (0),
        .END_ADDR       (`MEM_DEPTH - 1)
    )
    test ();
endmodule
