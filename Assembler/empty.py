#! /usr/bin/python

import Assembler
from memory_map import mem_map

bench_dir = "Empty"
bench_file = "empty"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

def assemble_PC():
    PC = Assembler.PC_Memory(bench_name)
    # Thread 0 must start its code at 1, as first PC is always 0 (register set at config)
    # All threads must start at 1 anyway, else the branch folding unit will trigger on its empty entries.
    # This is useful: start threads at 4095, so by the time they wrap-around to zero, they will hang there by their empty branch table entries.
    PC.set_pc(1, "THREAD0_START")
    PC.set_pc(4095, "THREAD1_START")
    PC.set_pc(4095, "THREAD2_START")
    PC.set_pc(4095, "THREAD3_START")
    PC.set_pc(4095, "THREAD4_START")
    PC.set_pc(4095, "THREAD5_START")
    PC.set_pc(4095, "THREAD6_START")
    PC.set_pc(4095, "THREAD7_START")
    return PC

def assemble_A():
    A = Assembler.Memory(bench_name, file_ext = ".A", write_offset = mem_map["A"]["Origin"])
    return A

def assemble_B():
    B = Assembler.Memory(bench_name, file_ext = ".B", write_offset = mem_map["B"]["Origin"])
    return B

def assemble_I(A, B):
    I = Assembler.Instruction_Memory(bench_name, A, B, write_offset = mem_map["I"]["Origin"])
    return I

def assemble_XDO():
    ADO = Assembler.Default_Offset_Memory(bench_name, file_ext = ".ADO", write_offset = mem_map["ADO"]["Origin"])
    BDO = Assembler.Default_Offset_Memory(bench_name, file_ext = ".BDO", write_offset = mem_map["BDO"]["Origin"])
    DDO = Assembler.Default_Offset_Memory(bench_name, file_ext = ".DDO", write_offset = mem_map["DDO"]["Origin"], width = 12)
    return ADO, BDO, DDO

def assemble_XPO():
    APO = Assembler.Programmed_Offset_Memory(bench_name, file_ext = ".APO", write_offset = mem_map["APO"]["Origin"])
    BPO = Assembler.Programmed_Offset_Memory(bench_name, file_ext = ".BPO", write_offset = mem_map["BPO"]["Origin"])
    DPO = Assembler.Programmed_Offset_Memory(bench_name, file_ext = ".DPO", write_offset = mem_map["DPO"]["Origin"], width = 12)
    return APO, BPO, DPO

def assemble_XIN():
    AIN = Assembler.Increments_Memory(bench_name, file_ext = ".AIN", write_offset = mem_map["AIN"]["Origin"])
    BIN = Assembler.Increments_Memory(bench_name, file_ext = ".BIN", write_offset = mem_map["BIN"]["Origin"])
    DIN = Assembler.Increments_Memory(bench_name, file_ext = ".DIN", write_offset = mem_map["DIN"]["Origin"])
    return AIN, BIN, DIN

def assemble_branches():
    BO = Assembler.Branch_Origin_Memory(bench_name, write_offset = mem_map["BO"]["Origin"])
    BD = Assembler.Branch_Destination_Memory(bench_name, write_offset = mem_map["BD"]["Origin"])
    BC = Assembler.Branch_Condition_Memory(bench_name, write_offset = mem_map["BC"]["Origin"])
    BP = Assembler.Branch_Prediction_Memory(bench_name, write_offset = mem_map["BP"]["Origin"])
    BPE = Assembler.Branch_Prediction_Enable_Memory(bench_name, write_offset = mem_map["BPE"]["Origin"])
    return BO, BD, BC, BP, BPE

def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I(A, B)
    ADO, BDO, DDO = assemble_XDO()
    APO, BPO, DPO = assemble_XPO()
    AIN, BIN, DIN = assemble_XIN()
    BO, BD, BC, BP, BPE = assemble_branches()
    empty = {"PC":PC, "A":A, "B":B, "I":I, 
             "ADO":ADO, "BDO":BDO, "DDO":DDO,
             "APO":APO, "BPO":BPO, "DPO":DPO,
             "AIN":AIN, "BIN":BIN, "DIN":DIN,
             "BO":BO,   "BD":BD,   "BC":BC,   "BP":BP, "BPE":BPE}
    return empty

def dump_all(empty):
    for memory in empty.values():
        memory.file_dump()

if __name__ == "__main__":
    empty = assemble_all()
    dump_all(empty)

