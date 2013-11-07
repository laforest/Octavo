#! /usr/bin/python

from Assembler import *

bench_name = "hailstone"

def assemble_PC():
    PC = PC_Memory(bench_name + ".PC", depth = 8, width = 20, word_width = 10)
    # Some examples.
    PC.L(PC.pack2(1,1)),     PC.N("THREAD0_START")
    PC.L(PC.pack2(16,16)),   PC.N("THREAD1_START")
    PC.L(PC.pack2(32,32)),   PC.N("THREAD2_START")
    PC.L(PC.pack2(48,48)),   PC.N("THREAD3_START")
    PC.L(PC.pack2(64,64)),   PC.N("THREAD4_START")
    PC.L(PC.pack2(80,80)),   PC.N("THREAD5_START")
    PC.L(PC.pack2(96,96)),   PC.N("THREAD6_START")
    PC.L(PC.pack2(112,112)), PC.N("THREAD7_START")
    return PC

def assemble_A():
    A = Data_Memory(bench_name + ".A")
    A.add_port_pair("READ_PORT", "WRITE_PORT", 1023)
    A.L(0),                 A.N("zero")
    A.L(1),                 A.N("one")
    A.L(3),                 A.N("three")
    A.L(2**(A.width-1)),    A.N("right_shift_1")
    A.L(0),                 A.N("temp_0")
    A.L(0),                 A.N("temp_1")
    A.L(0),                 A.N("temp_2")
    A.L(0),                 A.N("temp_3")
    A.L(0),                 A.N("temp_4")
    A.L(0),                 A.N("temp_5")
    A.L(0),                 A.N("temp_6")
    A.L(0),                 A.N("temp_7")
    return A

def assemble_B():
    B = Data_Memory(bench_name + ".B", write_offset = 1024)
    B.add_port_pair("READ_PORT", "WRITE_PORT", 1023)
    B.L(0),      B.N("zero")
    B.L(27),     B.N("seed_0")
    B.L(47),     B.N("seed_1")
    B.L(67),     B.N("seed_2")
    B.L(87),     B.N("seed_3")
    B.L(107),     B.N("seed_4")
    B.L(127),     B.N("seed_5")
    B.L(234),     B.N("seed_6")
    B.L(335),     B.N("seed_7")
    return B

def assemble_I(PC, A, B):
    I = Instruction_Memory(bench_name + ".I", write_offset = 2048)
    I.NOP()

    for i in range(0,8):
        temp = "temp_{0}".format(i)
        seed = "seed_{0}".format(i)
        I.ALIGN(PC.get_pc("THREAD{0}_START".format(i)))
        # Is the seed odd?
        I.I(AND, (A,temp), (A,"one"),           (B,seed)),  I.N("hailstone")
        I.I(JNZ, 0, (A,temp), 0),                               I.N("odd")
        # Even: seed = seed / 2
        I.I(MHU, (B,seed), (A,"right_shift_1"), (B,seed))
        I.I(JMP, 0, 0, 0),                                          I.N("output")
        # Odd: seed = (3 * seed) + 1
        I.I(MLS, (B,seed), (A,"three"),         (B,seed)),  I.RD("odd")
        I.I(ADD, (B,seed), (A,"one"),           (B,seed))
        I.I(ADD, (A,"WRITE_PORT"), 0, (B,seed)),                I.RD("output")
        I.I(ADD, (B,"WRITE_PORT"), 0, (B,seed))
        I.I(JMP, "hailstone", 0, 0)

    # for i in range(1,8):
    #     I.ALIGN(PC.get_pc("THREAD{0}_START".format(i)))
    #     I.I(JMP, 0, 0, 0), I.N("do_nothing"), I.RD("do_nothing")

    return I


def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I(PC, A, B)

    PC.file_dump()

    A.file_dump()
    A.file_name = "SIMD_" + A.file_name
    A.file_dump()

    B.file_dump()
    B.file_name = "SIMD_" + B.file_name
    B.file_dump()

    I.file_dump()

if __name__ == "__main__":
    assemble_all()

