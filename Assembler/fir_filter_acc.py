#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "FIR_Filter_Acc"
bench_file = "fir_filter_acc"
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
    A.P("Acc", mem_map["A"]["IO_base"]) # We'll hang the Accumulator off A Mem
    A.A(0)
    # Literal numbers
    A.L(0)
    A.L(1),                 A.N("one")
    A.L(-1),                A.N("minus_one")
    # FIR coefficients, 8-tap, moving average filter
    A.L(1),           A.N("coefficient0")
    A.L(1),           A.N("coefficient1")
    A.L(1),           A.N("coefficient2")
    A.L(1),           A.N("coefficient3")
    A.L(1),           A.N("coefficient4")
    A.L(1),           A.N("coefficient5")
    A.L(1),           A.N("coefficient6")
    A.L(1),           A.N("coefficient7")
    # Output data
    A.L(-2)     # Guard value for debugging
    A.L(0),     A.N("output_array_top") # 100 elements, NOT including final guard (-1)
    for i in range(0,98):
        A.L(0)
    A.L(0),     A.N("output_array_bottom")
    A.L(-1)     # Guard value for debugging 
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
    B.P("array_pointers", mem_map["B"]["PO_INC_base"], write_addr = mem_map["H"]["PO_INC_base"])
    B.A(0)
    B.L(0)
    # temporaries
    B.L(0),     B.N("array_cnt")
    # Input data (128 units - 8 as trailing halo, since pointer is at tail of sliding window)
    B.L(120),   B.N("array_len")
    B.L(-2)     # Guard value for debugging
    B.L(0),     B.N("input_array_top") # 100 elements, NOT including final guard (-1)
    for i in range(0,34):
        B.L(0)
    B.L(1023)
    for i in range(0,29):
        B.L(0)
    B.L(1024)
    B.L(512 )
    B.L(256 )
    B.L(128 )
    B.L(64  )
    B.L(32  )
    B.L(16  )
    B.L(8   )
    B.L(4   )
    B.L(2   )
    B.L(1   )
    for i in range(0,24):
        B.L(0)
    # add up to 128 elements, show a slope at end
    for i in range(0,28):
        B.L(1)
    B.L(-1)     # Guard value for debugging 
    # Placeholders for programmed offset
    B.L(0),     B.N("pointer_init")
    B.L(0),     B.N("pointer_temp")
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name

    # Thread 0 has implicit first NOP from pipeline, so starts at 1
    # All threads start at 1, to avoid triggering branching unit at 0.
    I.A(1)

    # Instructions to fill branch table
    base_addr = mem_map["BO"]["Origin"]
    I.P("BTM0", None, write_addr = base_addr)
    I.P("BTM1", None, write_addr = base_addr + 1)
    I.P("BTM2", None, write_addr = base_addr + 2)
    I.P("BTM3", None, write_addr = base_addr + 3)

    # Instruction to set indirect access
    base_addr = mem_map["BPO"]["Origin"] 
    I.P("AOM0", None, write_addr = base_addr)
    I.P("AOM1", None, write_addr = base_addr + 1)

# Optimized, Accumulator only, software sliding window
    # set branch entries
    I.I(ADD, "BTM0", "jmp0", 0)
    I.I(ADD, "BTM1", "jmp1", 0)
    I.I(ADD, "BTM2", "jmp2", 0)
    I.I(ADD, "BTM3", "jmp3", 0)

    # Instruction to set indirect access
    I.I(ADD, "AOM0", 0, "pointer_init"),                I.N("init")
    I.I(ADD, "pointer_temp", 0, "pointer_init")
    I.I(ADD, "array_cnt", 0, "array_len")

    # Do convolution
    I.I(MLS, "Acc", "coefficient7", "array_pointers"),  I.N("loop")
    I.I(MLS, "Acc", "coefficient6", "array_pointers")
    I.I(MLS, "Acc", "coefficient5", "array_pointers")
    I.I(MLS, "Acc", "coefficient4", "array_pointers")
    I.I(MLS, "Acc", "coefficient3", "array_pointers")
    I.I(MLS, "Acc", "coefficient2", "array_pointers")
    I.I(MLS, "Acc", "coefficient1", "array_pointers")
    I.I(MLS, "Acc", "coefficient0", "array_pointers")

    # Reset pointer, +1 to slide window
    I.I(ADD, "pointer_temp", "one", "pointer_temp")
    I.I(ADD, "AOM0", 0, "pointer_temp")
    I.I(ADD, "array_cnt", "minus_one", "array_cnt")

    # Read out Accumulator
    I.I(ADD, "array_pointers", "Acc", 0),               I.JNZ("loop", None, "jmp0")

    # and we're done
    I.NOP(), I.N("end"), I.JMP("end", "jmp3")

    I.resolve_forward_jumps()

    # Set programmed offsets
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.R("input_array_top")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] + A.W("output_array_top")) & 0xFFF
    PO = (1 << 34) | (1 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("pointer_init"))
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

def dump_all(program):
    for memory in program.values():
        memory.file_dump()

if __name__ == "__main__":
    program = assemble_all()
    dump_all(program)

