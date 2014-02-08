#! /usr/bin/python

import Assembler

bench_dir = "Empty"
bench_file = "empty"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

def assemble_PC():
    PC = Assembler.PC_Memory(bench_name)
    # Thread 0 must start its code at 1, as first PC is always 0 (register set at config)
    # Place a NOP at 0 for threads 1-7, and they will all be in sync, as well as flush out the pipeline of any initial zeroes.
    PC.L(PC.pack2(1,1)), PC.N("THREAD0_START")
    PC.L(PC.pack2(0,0)), PC.N("THREAD1_START")
    PC.L(PC.pack2(0,0)), PC.N("THREAD2_START")
    PC.L(PC.pack2(0,0)), PC.N("THREAD3_START")
    PC.L(PC.pack2(0,0)), PC.N("THREAD4_START")
    PC.L(PC.pack2(0,0)), PC.N("THREAD5_START")
    PC.L(PC.pack2(0,0)), PC.N("THREAD6_START")
    PC.L(PC.pack2(0,0)), PC.N("THREAD7_START")
    return PC

def assemble_A():
    A = Assembler.Data_Memory(bench_name, file_ext = ".A", write_offset = 0)
    return A

def assemble_B():
    B = Assembler.Data_Memory(bench_name, file_ext = ".B", write_offset = 1024)
    return B

def assemble_I():
    I = Assembler.Instruction_Memory(bench_name, write_offset = 2048)
    return I

def assemble_XDO():
    ADO = Assembler.Default_Offset_Memory(bench_name, file_ext = ".ADO", write_offset = 3072)
    BDO = Assembler.Default_Offset_Memory(bench_name, file_ext = ".BDO", write_offset = ADO.write_offset + ADO.depth)
    DDO = Assembler.Default_Offset_Memory(bench_name, file_ext = ".DDO", write_offset = BDO.write_offset + BDO.depth)
    return ADO, BDO, DDO

def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I()
    ADO, BDO, DDO = assemble_XDO()
    empty = {"PC":PC, "A":A, "B":B, "I":I, "ADO":ADO, "BDO":BDO, "DDO":DDO}
    return empty

def dump_all(empty):
    for memory in empty.values():
        memory.file_dump()

if __name__ == "__main__":
    empty = assemble_all()
    dump_all(empty)

