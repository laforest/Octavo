// XXX Adjust to newer Assembler routines (pre-inc 'here' instead of post-inc)

`define THREAD_0_START 1
`define THREAD_1_START 10
`define THREAD_2_START 20
`define THREAD_3_START 30
`define THREAD_4_START 40
`define THREAD_5_START 50
`define THREAD_6_START 60
`define THREAD_7_START 70

module instr_test_pc
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

module do_instr_test_pc ();
    instr_test_pc
    #(
        .INIT_FILE      ("instr_test.pc"),
        .START_ADDR     (0),
        .END_ADDR       (`THREAD_COUNT - 1),
        .WORD_WIDTH     (`D_OPERAND_WIDTH)
    )
    instr_test_pc ();
endmodule

module instr_test
    `include "./Assembler/Assembler_begin.v"

    // Thread entry points
    `DEF(xor_test)
    `DEF(and_test)
    `DEF(or_test)
    `DEF(srl_test)
    `DEF(sra_test)
    `DEF(add_test)
    `DEF(sub_test)
    `DEF(mlo_test)
    `DEF(mhi_test)

    `include "./Assembler/Assembler_mem_init.v"

    `ALIGN(`THREAD_0_START)
    `I(`XOR, 0, 0, 0)           `N(xor_test)
    `I(`JMP, xor_test, 0, 0) 
    `L(0)                       `RD(xor_test)
    `L('h55555555)              `RA(xor_test)
    `L(-1)                      `RB(xor_test)

    `ALIGN(`THREAD_1_START)
    `I(`AND, 0, 0, 0)           `N(and_test)
    `I(`JMP, and_test, 0, 0) 
    `L(0)                       `RD(and_test)
    `L('h55555555)              `RA(and_test)
    `L('hAAAAAAA9)              `RB(and_test)

    `ALIGN(`THREAD_2_START)
    `I(`OR, 0, 0, 0)            `N(or_test)
    `I(`JMP, or_test, 0, 0) 
    `L(0)                       `RD(or_test)
    `L('h55555554)              `RA(or_test)
    `L('hAAAAAAA9)              `RB(or_test)

    `ALIGN(`THREAD_3_START)
    `I(`SRL, 0, 0, 0)           `N(srl_test)
    `I(`JMP, srl_test, 0, 0) 
    `L(0)                       `RD(srl_test)
    `L({1'b1,{`ALU_WORD_WIDTH-1{1'b0}}})              `RA(srl_test)
    `L('h55555555)              `RB(srl_test)

    `ALIGN(`THREAD_4_START)
    `I(`SRA, 0, 0, 0)           `N(sra_test)
    `I(`JMP, sra_test, 0, 0) 
    `L(0)                       `RD(sra_test)
    `L({1'b1,{`ALU_WORD_WIDTH-1{1'b0}}})              `RA(sra_test)
    `L('h55555555)              `RB(sra_test)

    `ALIGN(`THREAD_5_START)
    `I(`ADD, 0, 0, 0)           `N(add_test)
    `I(`JMP, add_test, 0, 0) 
    `L(0)                       `RD(add_test)
    `L('hFFFFFFFF)              `RA(add_test)
    `L(1)                       `RB(add_test)

    `ALIGN(`THREAD_6_START)
    `I(`SUB, 0, 0, 0)           `N(sub_test)
    `I(`JMP, sub_test, 0, 0) 
    `L(0)                       `RD(sub_test)
    `L(0)                       `RA(sub_test)
    `L(1)                       `RB(sub_test)

    `ALIGN(`THREAD_7_START)
    `I(`MLO, 0, 0, 0)           `N(mlo_test)
    `I(`MHI, 0, 0, 0)           `N(mhi_test)
    `I(`JMP, mlo_test, 0, 0) 
    `L(0)                       `RD(mlo_test) `RD(mhi_test)
    `L('hFFFFF)                 `RA(mlo_test) `RA(mhi_test)
    `L('hFFFFF)                 `RB(mlo_test) `RB(mhi_test)

    `include "./Assembler/Assembler_end.v"
endmodule


module do_instr_test ();
    instr_test
    #(
        .INIT_FILE      ("instr_test.mem"),
        .START_ADDR     (0),
        .END_ADDR       (`MEM_DEPTH - 1)
    )
    instr_test ();
endmodule
