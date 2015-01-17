#! /usr/bin/python

"""Increment a 16-element array +1, 16 times"""

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Increment"
bench_file = "increment"
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
    A.L(1),     A.N("one")
    A.L(-1),    A.N("minus_one")
    # Placeholders for branch table entries
    A.L(0),     A.N("jmp0")
    A.L(0),     A.N("jmp1")
    A.L(0),     A.N("jmp2")
    A.L(0),     A.N("jmp3")
    return A

def assemble_B():
    B = empty["B"]
    B.file_name = bench_name
    B.P("B_IO", mem_map["B"]["IO_base"])
    B.P("loop_pointer",     mem_map["B"]["PO_INC_base"],     write_addr = mem_map["H"]["PO_INC_base"])
    B.A(0)
    B.L(0)
    B.L(16),    B.N("loop_count_init")
    B.L(0),     B.N("loop_count_inner")
    B.L(0),     B.N("loop_count_outer")
    B.L(-2) # marker for debugging
    B.L(0),     B.N("array")
    B.L(1)
    B.L(2)
    B.L(3)
    B.L(4)
    B.L(5)
    B.L(6)
    B.L(7)
    B.L(8)
    B.L(9)
    B.L(10)
    B.L(11)
    B.L(12)
    B.L(13)
    B.L(14)
    B.L(15)
    B.L(-1) # marker for debugging
    B.L(-1) # marker for debugging
    # Placeholders for programmed offset
    B.L(0),     B.N("loop_pointer_init")
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name

    # Thread 0 has implicit first NOP from pipeline, so starts at 1
    # All threads start at 1, to avoid triggering branching unit at 0.
    I.A(1)

    # Instructions to fill branch table
    branch_base_addr = mem_map["BO"]["Origin"]
    branch_depth     = mem_map["BO"]["Depth"]
    I.I(ADD, branch_base_addr,                      "jmp0", 0)
    I.I(ADD, branch_base_addr +  branch_depth,      "jmp1", 0)
    I.I(ADD, branch_base_addr + (branch_depth * 2), "jmp2", 0)
    I.I(ADD, branch_base_addr + (branch_depth * 3), "jmp3", 0)

    PO_base_addr = mem_map["BPO"]["Origin"] 
    I.I(ADD, "loop_count_outer", 0, "loop_count_init")

    I.I(ADD, PO_base_addr, 0, "loop_pointer_init"), I.N("outer")
    I.I(ADD, "loop_count_outer", "minus_one", "loop_count_outer")
    I.I(ADD, "loop_count_inner", 0, "loop_count_init"), I.JNE("end", None, "jmp0")

    I.I(ADD, "loop_count_inner", "minus_one", "loop_count_inner"), I.N("inner")
    I.I(ADD, "loop_pointer", "one", "loop_pointer"), I.JPO("inner", True, "jmp1"), I.JNE("outer", False, "jmp2")

    I.NOP(), I.N("end"), I.JMP("end", "jmp3")

    # Resolve jumps
    I.resolve_forward_jumps()

    # Set programmed offsets
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.R("array")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] + B.W("array")) & 0xFFF
    PO = (1 << 34) | (1 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("loop_pointer_init"))
    B.L(PO)
    # Since the next indirect memory address is one further down
    #read_PO -= 1
    #write_PO -= 1
    #PO = (1 << 34) | (1 << 32) | (write_PO << 20) | read_PO
    #B.A(B.R("output_pointer_init"))
    #B.L(PO)

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

