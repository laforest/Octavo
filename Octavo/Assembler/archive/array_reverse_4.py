#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Array_Reverse_4"
bench_file = "array_reverse_4"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

# Get empty instances with default parameters
empty = empty.assemble_all()

def assemble_PC():
    # Nothing to do here.
    PC = empty["PC"]
    PC.file_name = bench_name
    return PC

def assemble_A():
    A = empty["A"]
    A.file_name = bench_name
    A.P("A_IO", mem_map["A"]["IO_base"])
    A.A(0)
    A.L(0)
    A.L(-1),                A.N("minus_one")
    # Apply this to array_bottom_temp, since we don't have it in hardware
    A.L((-1 & 0xFFF) << 20 | (-1 & 0x3FF)),     A.N("array_bottom_pointer_decr")
    # Placeholders for branch table entries
    A.L(0),                 A.N("jmp0")
    A.L(0),                 A.N("jmp1")
    A.L(0),                 A.N("jmp2")
    A.L(0),                 A.N("jmp3")
    return A

def assemble_B():
    B = empty["B"]
    B.file_name = bench_name
    B.P("B_IO", mem_map["B"]["IO_base"])
    B.P("array_top_pointer",      mem_map["B"]["PO_INC_base"],       write_addr = mem_map["H"]["PO_INC_base"])
    B.P("array_bottom_pointer",   mem_map["B"]["PO_INC_base"] + 1,   write_addr = mem_map["H"]["PO_INC_base"] + 1)
    B.A(0)
    B.L(0)
    B.L(64),    B.N("array_half_length")
    B.L(0),     B.N("array_count")
    B.L(-2)
    B.L(1),     B.N("array_top") # 100 elements
    for i in range(2,128):
        B.L(i)
    B.L(128),    B.N("array_bottom")
    B.L(-1)
    # Placeholders for programmed offset
    B.L(0),     B.N("array_top_pointer_init")
    B.L(0),     B.N("array_bottom_pointer_init")
    B.L(0),     B.N("array_bottom_pointer_temp")
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name

    # Thread 0 has implicit first NOP from pipeline, so starts at 1
    # All threads start at 1, to avoid triggering branching unit at 0.
    I.A(1)

    # Instructions to fill branch table
    base_addr = mem_map["BO"]["Origin"]
    depth     = mem_map["BO"]["Depth"]
    I.I(ADD, base_addr,               "jmp0", 0)
    I.I(ADD, base_addr +  depth,      "jmp1", 0)
    I.I(ADD, base_addr + (depth * 2), "jmp2", 0)
    I.I(ADD, base_addr + (depth * 3), "jmp3", 0)

    # Instruction to set indirect access
    base_addr = mem_map["BPO"]["Origin"] 
    I.I(ADD, "array_bottom_pointer_temp", 0, "array_bottom_pointer_init")
    I.I(ADD, base_addr,   0, "array_top_pointer_init")
    I.I(ADD, base_addr+1, 0, "array_bottom_pointer_init")
    I.I(ADD, "array_count", 0, "array_half_length")

    # Do the 4-swap via I/O
    I.I(ADD, "B_IO", 0, "array_top_pointer"),               I.N("next")
    I.I(ADD, "B_IO", 0, "array_bottom_pointer")
    I.I(ADD, "array_bottom_pointer", 0, "B_IO")
    I.I(ADD, "array_top_pointer",    0, "B_IO")

    # manually decrement bottom pointer
    I.I(ADD, "array_bottom_pointer_temp", "array_bottom_pointer_decr", "array_bottom_pointer_temp")
    I.I(ADD, "array_count", "minus_one", "array_count")
    I.I(ADD, base_addr+1, 0, "array_bottom_pointer_temp"),  I.JNZ("next", None, "jmp0")
    
    # and we're done
    I.NOP(), I.N("end"), I.JMP("end", "jmp3")

    I.resolve_forward_jumps()

    # Set programmed offsets
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.R("array_top")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] + B.W("array_top")) & 0xFFF
    PO = (1 << 34) | (1 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("array_top_pointer_init"))
    B.L(PO)

    # Set programmed offsets
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] - 1 + B.R("array_bottom")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] - 1 + B.W("array_bottom")) & 0xFFF
    PO = (0 << 34) | (0 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("array_bottom_pointer_init"))
    B.L(PO)

    return I

# Leave these all zero for now: only zero-based thread will do something, all
# others will hang at 0 due to empty branch tables.

def assemble_XDO():
    ADO, BDO, DDO = empty["ADO"], empty["BDO"], empty["DDO"]
    ADO.file_name = bench_name
    BDO.file_name = bench_name
    DDO.file_name = bench_name
    return ADO, BDO, DDO

def assemble_XPO():
    APO, BPO, DPO = empty["APO"], empty["BPO"], empty["DPO"]
    APO.file_name = bench_name
    BPO.file_name = bench_name
    DPO.file_name = bench_name
    return APO, BPO, DPO

def assemble_XIN():
    AIN, BIN, DIN = empty["AIN"], empty["BIN"], empty["DIN"]
    AIN.file_name = bench_name
    BIN.file_name = bench_name
    DIN.file_name = bench_name
    return AIN, BIN, DIN

def assemble_branches():
    BO, BD, BC, BP, BPE = empty["BO"], empty["BD"], empty["BC"], empty["BP"], empty["BPE"]
    BO.file_name = bench_name    
    BD.file_name = bench_name    
    BC.file_name = bench_name    
    BP.file_name = bench_name    
    BPE.file_name = bench_name    
    return BO, BD, BC, BP, BPE

def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I(PC, A, B)
    ADO, BDO, DDO = assemble_XDO()
    APO, BPO, DPO = assemble_XPO()
    AIN, BIN, DIN = assemble_XIN()
    BO, BD, BC, BP, BPE = assemble_branches()
    hailstone = {"PC":PC, "A":A, "B":B, "I":I, 
                 "ADO":ADO, "BDO":BDO, "DDO":DDO,
                 "APO":APO, "BPO":BPO, "DPO":DPO,
                 "AIN":AIN, "BIN":BIN, "DIN":DIN,
                 "BO":BO, "BD":BD, "BC":BC, "BP":BP, "BPE":BPE}
    return hailstone

def dump_all(hailstone):
    for memory in hailstone.values():
        memory.file_dump()

if __name__ == "__main__":
    hailstone = assemble_all()
    dump_all(hailstone)

