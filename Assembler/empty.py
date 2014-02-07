#! /usr/bin/python

from Assembler import *

bench_dir = "Empty"
bench_file = "empty"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

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
    return A

def assemble_B():
    B = Data_Memory(bench_name + ".B")
    return B

def assemble_I(PC, A, B):
    I = Instruction_Memory(bench_name + ".I")
    return I

def assemble_DOFF():
    DOFF = Memory(bench_name + ".DOFF", depth = 8, width = 10)
    return DOFF

def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I(PC, A, B)
    DOFF = assemble_DOFF()

    PC.file_dump()

    A.file_dump()
    A.file_name = SIMD_bench_name + ".A"
    A.file_dump()

    B.file_dump()
    B.file_name = SIMD_bench_name + ".B"
    B.file_dump()

    I.file_dump()

    DOFF.file_dump()

if __name__ == "__main__":
    assemble_all()

