#! /usr/bin/python

from Assembler import Memory

bench_name = "empty"

def assemble_PC():
    PC = Memory(bench_name + ".PC", depth = 8, word_width = 10, mem_width = 20)
    # PC.L(PC.pack2(1,1)),     PC.N("THREAD0_START")
    # PC.L(PC.pack2(16,16)),   PC.N("THREAD1_START")
    # PC.L(PC.pack2(32,32)),   PC.N("THREAD2_START")
    # PC.L(PC.pack2(48,48)),   PC.N("THREAD3_START")
    # PC.L(PC.pack2(64,64)),   PC.N("THREAD4_START")
    # PC.L(PC.pack2(80,80)),   PC.N("THREAD5_START")
    # PC.L(PC.pack2(96,96)),   PC.N("THREAD6_START")
    # PC.L(PC.pack2(112,112)), PC.N("THREAD7_START")
    PC.file_dump()
    return PC

def assemble_A():
    A = Memory(bench_name + ".A")
    A.file_dump()
    A.file_name = "SIMD_" + A.file_name
    A.file_dump()
    return A

def assemble_B():
    B = Memory(bench_name + ".B")
    B.file_dump()
    B.file_name = "SIMD_" + B.file_name
    B.file_dump()
    return B

def assemble_I(PC, A, B):
    I = Memory(bench_name + ".I")
    I.file_dump()
    return I


def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I(PC, A, B)

if __name__ == "__main__":
    assemble_all()

