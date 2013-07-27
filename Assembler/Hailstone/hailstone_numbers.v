// Outputs hailstone numbers on each port, expects 1 port per mem

`define THREAD_0_START 1
`define THREAD_1_START 20
`define THREAD_2_START 40
`define THREAD_3_START 60
`define THREAD_4_START 80
`define THREAD_5_START 100
`define THREAD_6_START 120
`define THREAD_7_START 140

`define PC_FILE    "hailstone_numbers.pc"
`define MEM_FILE   "hailstone_numbers.mem"
`define SIMD_MEM_FILE   "SIMD_hailstone_numbers.mem"
`define SIMD_WORD_WIDTH 36
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

`define A_IO_WRITE_PORT_BASE_ADDR 1022
`define A_IO_READ_PORT_BASE_ADDR  1022

`define B_IO_WRITE_PORT_BASE_ADDR 1023
`define B_IO_READ_PORT_BASE_ADDR  1023

`define HAILSTONE_BODY                          \
    // Is n odd?                                \
    `I(`AND, t, n, one)         `N(hailstone)   \
    `I(`JNZ, 0, t, 0)           `N(odd)         \
    // Even: n = n / 2                          \
    `I(`MHU, n, n, shift_right_by_one)          \
    `I(`JMP, 0, 0, 0)           `N(out)         \
    // Odd: n = 3n + 1                          \
    `I(`MLS, n, n, three)       `RD(odd)        \
    `I(`ADD, n, n, one)                         


`define HAILSTONE_A                             \
    `HAILSTONE_BODY                             \
    // Output n                                 \
    `I(`ADD, `A_IO_WRITE_PORT_BASE_ADDR, n, 0)   `RD(out)   \
    `I(`JMP, hailstone, 0, 0)                   

`define HAILSTONE_B                             \
    `HAILSTONE_BODY                             \
    // Output n                                 \
    `I(`ADD, `B_IO_WRITE_PORT_BASE_ADDR, n, 0)   `RD(out)   \
    `I(`JMP, hailstone, 0, 0)                   

`define READ_PORT_TEST                                                                      \
    `I(`ADD, `A_IO_WRITE_PORT_BASE_ADDR, `A_IO_READ_PORT_BASE_ADDR, 0)  `N(read_port_test)  \
    `I(`ADD, `B_IO_WRITE_PORT_BASE_ADDR, 0, `B_IO_READ_PORT_BASE_ADDR)                      \
    `I(`JMP, read_port_test, 0, 0)                   


module test
    `include "./Assembler/Assembler_begin.v"

    // Thread entry points
    `DEF(nothing)
    `DEF(one)
    `DEF(three)
    `DEF(deadbeef)
    `DEF(shift_right_by_one)
    `DEF(n)
    `DEF(t)
    `DEF(hailstone)
    `DEF(odd)
    `DEF(out)
    `DEF(marker_deadbeef)
    `DEF(read_port_test)

    `include "./Assembler/Assembler_mem_init.v"

    // Test the read ports by passing input to matching write port.
    `ALIGN(`THREAD_0_START)
    `READ_PORT_TEST
    //`I(`JMP, 0, 0, 0)           `N(nothing)         `RD(nothing)
    // Constants for all
    `L(1)                       `N(one)
    `L(3)                       `N(three)
    `L('hdeadbeef)              `N(deadbeef)
    `L(2**(WORD_WIDTH-1))       `N(shift_right_by_one)

// 82  41  124  62  31  94  47  142  71  214  107  322  161  484  242  121  364  182  91  274  137  412  206  103  310  155  466  233  700  350  175  526  263  790  395  1186  593  1780  890  445  1336  668  334  167  502  251  754  377  1132  566  283  850  425  1276  638  319  958  479  1438  719  2158  1079  3238  1619  4858  2429  7288  3644  1822  911  2734  1367  4102  2051  6154  3077  9232  4616  2308  1154  577  1732  866  433  1300  650  325  976  488  244  122  61  184  92  46  23  70  35  106  53  160  80  40  20  10  5  16  8  4  2  1 
    `L(27)                      `N(n)
    `L(0)                       `N(t)
    `ALIGN(`THREAD_1_START)
    `HAILSTONE_A

// 142  71  214  107  322  161  484  242  121  364  182  91  274  137  412  206  103  310  155  466  233  700  350  175  526  263  790  395  1186  593  1780  890  445  1336  668  334  167  502  251  754  377  1132  566  283  850  425  1276  638  319  958  479  1438  719  2158  1079  3238  1619  4858  2429  7288  3644  1822  911  2734  1367  4102  2051  6154  3077  9232  4616  2308  1154  577  1732  866  433  1300  650  325  976  488  244  122  61  184  92  46  23  70  35  106  53  160  80  40  20  10  5  16  8  4  2  1 
    `L(47)                      `N(n)
    `L(0)                       `N(t)
    `ALIGN(`THREAD_2_START)
    `HAILSTONE_B

// 202  101  304  152  76  38  19  58  29  88  44  22  11  34  17  52  26  13  40  20  10  5  16  8  4  2  1 
    `L(67)                      `N(n)
    `L(0)                       `N(t)
    `ALIGN(`THREAD_3_START)
    `HAILSTONE_A

// 262  131  394  197  592  296  148  74  37  112  56  28  14  7  22  11  34  17  52  26  13  40  20  10  5  16  8  4  2  1 
    `L(87)                      `N(n)
    `L(0)                       `N(t)
    `ALIGN(`THREAD_4_START)
    `HAILSTONE_B

// 322  161  484  242  121  364  182  91  274  137  412  206  103  310  155  466  233  700  350  175  526  263  790  395  1186  593  1780  890  445  1336  668  334  167  502  251  754  377  1132  566  283  850  425  1276  638  319  958  479  1438  719  2158  1079  3238  1619  4858  2429  7288  3644  1822  911  2734  1367  4102  2051  6154  3077  9232  4616  2308  1154  577  1732  866  433  1300  650  325  976  488  244  122  61  184  92  46  23  70  35  106  53  160  80  40  20  10  5  16  8  4  2  1 
    `L(107)                     `N(n)
    `L(0)                       `N(t)
    `ALIGN(`THREAD_5_START)
    `HAILSTONE_A

// 382  191  574  287  862  431  1294  647  1942  971  2914  1457  4372  2186  1093  3280  1640  820  410  205  616  308  154  77  232  116  58  29  88  44  22  11  34  17  52  26  13  40  20  10  5  16  8  4  2  1 
    `L(127)                     `N(n)
    `L(0)                       `N(t)
    `ALIGN(`THREAD_6_START)
    `HAILSTONE_B

    // output a marker value: 3,735,928,559 in decimal
    `ALIGN(`THREAD_7_START)
    `I(`ADD, `B_IO_WRITE_PORT_BASE_ADDR, deadbeef, 0)    `N(marker_deadbeef)
    `I(`JMP, marker_deadbeef, 0, 0)

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
