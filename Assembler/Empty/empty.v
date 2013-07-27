`define THREAD_0_START 1
`define THREAD_1_START 20
`define THREAD_2_START 40
`define THREAD_3_START 60
`define THREAD_4_START 80
`define THREAD_5_START 100
`define THREAD_6_START 120
`define THREAD_7_START 140

`define PC_FILE    "empty.pc"
`define MEM_FILE   "empty.mem"
`define THREADS    8
`define ADDR_WIDTH 10
`define MEM_DEPTH  2**10

module thread_pc
    `include "./Assembler/Assembler_begin.v"
    `include "./Assembler/Assembler_mem_init.v"

    `L(`THREAD_0_START)
    `L(`THREAD_1_START)
    `L(`THREAD_2_START)
    `L(`THREAD_3_START)
    `L(`THREAD_4_START)
    `L(`THREAD_5_START)
    `L(`THREAD_6_START)
    `L(`THREAD_7_START)

    `include "./Assembler/Assembler_end.v"
endmodule

module do_thread_pc ();
    thread_pc
    #(
        .INIT_FILE      (`PC_FILE),
        .START_ADDR     (0),
        .END_ADDR       (`THREADS - 1),
        .WORD_WIDTH     (`ADDR_WIDTH)
    )
    thread_pc ();
endmodule

module test
    `include "./Assembler/Assembler_begin.v"

    // Thread entry points

    `include "./Assembler/Assembler_mem_init.v"

    // Code

    `include "./Assembler/Assembler_end.v"
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
