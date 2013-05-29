`define THREAD_0_START 1
`define THREAD_1_START 20
`define THREAD_2_START 40
`define THREAD_3_START 60
`define THREAD_4_START 80
`define THREAD_5_START 100
`define THREAD_6_START 120
`define THREAD_7_START 140

`define PC_FILE    "mesh_test.pc"
`define MEM_FILE   "mesh_test.mem"
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

`define A_IO_WRITE_PORT_BASE_ADDR 1020
`define A_IO_READ_PORT_BASE_ADDR  1020

`define B_IO_WRITE_PORT_BASE_ADDR 1022
`define B_IO_READ_PORT_BASE_ADDR  1022

`define MESH_TEST_A0                                                                  \
    `I(`ADD, `A_IO_WRITE_PORT_BASE_ADDR, `A_IO_READ_PORT_BASE_ADDR, 0)     `N(loop)   \
    `I(`JMP, loop, 0, 0)                   

`define MESH_TEST_A1                                                                  \
    `I(`ADD, `A_IO_WRITE_PORT_BASE_ADDR+1, `A_IO_READ_PORT_BASE_ADDR+1, 0) `N(loop)   \
    `I(`JMP, loop, 0, 0)                   
 
`define MESH_TEST_B0                                                                  \
    `I(`ADD, `B_IO_WRITE_PORT_BASE_ADDR, 0, `B_IO_READ_PORT_BASE_ADDR)     `N(loop)   \
    `I(`JMP, loop, 0, 0)                   

`define MESH_TEST_B1                                                                  \
    `I(`ADD, `B_IO_WRITE_PORT_BASE_ADDR+1, 0, `B_IO_READ_PORT_BASE_ADDR+1) `N(loop)   \
    `I(`JMP, loop, 0, 0)                   

`define DO_NOTHING  `I(`JMP, 0, 0, 0)   `N(loop)    `RD(loop)                   

module test
    `include "./Assembler/Assembler_begin.v"

    // Names
    `DEF(loop)

    `include "./Assembler/Assembler_mem_init.v"

    `ALIGN(`THREAD_0_START)
    `DO_NOTHING 

    `ALIGN(`THREAD_1_START)
    `DO_NOTHING

    `ALIGN(`THREAD_2_START)
    `DO_NOTHING

    `ALIGN(`THREAD_3_START)
    `DO_NOTHING

    `ALIGN(`THREAD_4_START)
    `MESH_TEST_A0

    `ALIGN(`THREAD_5_START)
    `MESH_TEST_A1

    `ALIGN(`THREAD_6_START)
    `MESH_TEST_B0

    `ALIGN(`THREAD_7_START)
    `MESH_TEST_B1

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
