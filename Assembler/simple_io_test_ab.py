#! /usr/bin/python

from Assembler import *

bench_name = "simple_io_test_ab"

def assemble_PC():
    PC = PC_Memory(bench_name + ".PC", depth = 8, width = 20, word_width = 10)
    PC.set_pc(1,   "THREAD0_START")
    PC.set_pc(16,  "THREAD1_START")
    PC.set_pc(32,  "THREAD2_START")
    PC.set_pc(48,  "THREAD3_START")
    PC.set_pc(64,  "THREAD4_START")
    PC.set_pc(80,  "THREAD5_START")
    PC.set_pc(96,  "THREAD6_START")
    PC.set_pc(112, "THREAD7_START")
    return PC

def assemble_A():
    A = Data_Memory(bench_name + ".A")
    A.add_port_pair("READ_PORT", "WRITE_PORT", 1023)
    return A

def assemble_B():
    B = Data_Memory(bench_name + ".B", write_offset = 1024)
    B.add_port_pair("READ_PORT", "WRITE_PORT", 1023)
    return B

def assemble_I(PC, A, B):
    I = Instruction_Memory(bench_name + ".I", write_offset = 2048)

    # Implicit NOP here, align other threads to match
    I.ALIGN(PC.get_pc("THREAD0_START"))
    I.I(ADD, (A,"WRITE_PORT"), (A,"READ_PORT"), 0), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    for i in range(1,4):
        I.NOP()
        I.ALIGN(PC.get_pc("THREAD{0}_START".format(i)))
        I.I(ADD, (A,"WRITE_PORT"), (A,"READ_PORT"), 0), I.N("loop")
        I.I(JMP, "loop", 0 ,0)

    for i in range(4,8):
        I.NOP()
        I.ALIGN(PC.get_pc("THREAD{0}_START".format(i)))
        I.I(ADD, (B,"WRITE_PORT"), 0, (B,"READ_PORT")), I.N("loop")
        I.I(JMP, "loop", 0 ,0)

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

