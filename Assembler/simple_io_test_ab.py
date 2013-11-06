#! /usr/bin/python

from Assembler import *

bench_name = "simple_io_test_ab"

def assemble_PC():
    PC = PC_Memory(bench_name + ".PC", depth = 8, word_width = 10, mem_width = 20)
    PC.set_pc(1,   "THREAD0_START")
    PC.set_pc(16,  "THREAD1_START")
    PC.set_pc(32,  "THREAD2_START")
    PC.set_pc(48,  "THREAD3_START")
    PC.set_pc(64,  "THREAD4_START")
    PC.set_pc(80,  "THREAD5_START")
    PC.set_pc(96,  "THREAD6_START")
    PC.set_pc(112, "THREAD7_START")
    PC.file_dump()
    return PC

def assemble_A():
    A = Memory(bench_name + ".A")
    A.add_port_pair("READ_PORT", "WRITE_PORT", 1023)
    A.file_dump()
    A.file_name = "SIMD_" + A.file_name
    A.file_dump()
    return A

def assemble_B():
    B = Memory(bench_name + ".B", write_offset = 1024)
    B.add_port_pair("READ_PORT", "WRITE_PORT", 1023)
    B.file_dump()
    B.file_name = "SIMD_" + B.file_name
    B.file_dump()
    return B

def assemble_I(PC, A, B):
    I = Memory(bench_name + ".I", write_offset = 2048)

    I.ALIGN(PC.get_pc("THREAD0_START"))
    I.I(ADD, A.names["WRITE_PORT"], A.names["READ_PORT"], 0), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    I.ALIGN(PC.get_pc("THREAD1_START"))
    I.I(ADD, A.names["WRITE_PORT"], A.names["READ_PORT"], 0), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    I.ALIGN(PC.get_pc("THREAD2_START"))
    I.I(ADD, A.names["WRITE_PORT"], A.names["READ_PORT"], 0), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    I.ALIGN(PC.get_pc("THREAD3_START"))
    I.I(ADD, A.names["WRITE_PORT"], A.names["READ_PORT"], 0), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    I.ALIGN(PC.get_pc("THREAD4_START"))
    I.I(ADD, B.names["WRITE_PORT"], 0, B.names["READ_PORT"]), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    I.ALIGN(PC.get_pc("THREAD5_START"))
    I.I(ADD, B.names["WRITE_PORT"], 0, B.names["READ_PORT"]), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    I.ALIGN(PC.get_pc("THREAD6_START"))
    I.I(ADD, B.names["WRITE_PORT"], 0, B.names["READ_PORT"]), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    I.ALIGN(PC.get_pc("THREAD7_START"))
    I.I(ADD, B.names["WRITE_PORT"], 0, B.names["READ_PORT"]), I.N("loop")
    I.I(JMP, "loop", 0 ,0)

    I.file_dump()
    return I


def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I(PC, A, B)

if __name__ == "__main__":
    assemble_all()

