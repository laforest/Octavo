#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Hailstone_A"
bench_file = "hailstone_a"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

# Get empty instances with default parameters
empty = empty.assemble_all()

lookahead = [0, 1, 2, 2, 1, 1, 1, 8, 2, 10, 2, 4, 2, 2, 5, 5, 1, 2, 20, 20, 1,
1, 8, 8, 1, 26, 1, 242, 10, 10, 10, 91, 2, 11, 4, 4, 13, 13, 13, 38, 2, 121, 2,
14, 5, 5, 5, 137, 2, 17, 17, 17, 2, 2, 161, 161, 20, 56, 20, 19, 20, 20, 182,
182, 1, 7, 22, 22, 8, 8, 8, 206, 26, 71, 26, 8, 26, 26, 76, 76, 1, 80, 242,
242, 1, 1, 28, 28, 10, 29, 10, 263, 10, 10, 91, 91, 4, 94, 11, 11, 11, 11, 11,
890, 4, 101, 4, 103, 107, 107, 107, 319, 13, 4, 37, 37, 13, 13, 38, 38, 40,
350, 40, 118, 121, 121, 364, 1093, 2, 125, 14, 14, 44, 44, 44, 43, 5, 395, 5,
134, 5, 5, 137, 137, 17, 47, 47, 47, 17, 17, 16, 16, 17, 49, 17, 445, 152, 152,
152, 1367, 2, 155, 53, 53, 161, 161, 161, 479, 2, 1457, 2, 164, 56, 56, 56,
167, 20, 19, 19, 19, 20, 20, 175, 175, 20, 59, 20, 179, 182, 182, 182, 1640, 8,
62, 188, 188, 7, 7, 7, 190, 22, 64, 22, 65, 22, 22, 593, 593, 8, 67, 202, 202,
8, 8, 206, 206, 71, 23, 71, 209, 71, 71, 638, 638, 26, 647, 8, 8, 74, 74, 74,
661, 26, 668, 26, 674, 76, 76, 76, 2051, 80, 26, 233, 233, 80, 80, 236, 236,
242, 238, 242, 719, 728, 728, 2186, 6560]

odd_count_cubed = [1, 81, 81, 81, 27, 27, 27, 243, 27, 243, 27, 81, 27, 27, 81,
81, 9, 27, 243, 243, 9, 9, 81, 81, 9, 243, 9, 2187, 81, 81, 81, 729, 9, 81, 27,
27, 81, 81, 81, 243, 9, 729, 9, 81, 27, 27, 27, 729, 9, 81, 81, 81, 9, 9, 729,
729, 81, 243, 81, 81, 81, 81, 729, 729, 3, 27, 81, 81, 27, 27, 27, 729, 81,
243, 81, 27, 81, 81, 243, 243, 3, 243, 729, 729, 3, 3, 81, 81, 27, 81, 27, 729,
27, 27, 243, 243, 9, 243, 27, 27, 27, 27, 27, 2187, 9, 243, 9, 243, 243, 243,
243, 729, 27, 9, 81, 81, 27, 27, 81, 81, 81, 729, 81, 243, 243, 243, 729, 2187,
3, 243, 27, 27, 81, 81, 81, 81, 9, 729, 9, 243, 9, 9, 243, 243, 27, 81, 81, 81,
27, 27, 27, 27, 27, 81, 27, 729, 243, 243, 243, 2187, 3, 243, 81, 81, 243, 243,
243, 729, 3, 2187, 3, 243, 81, 81, 81, 243, 27, 27, 27, 27, 27, 27, 243, 243,
27, 81, 27, 243, 243, 243, 243, 2187, 9, 81, 243, 243, 9, 9, 9, 243, 27, 81,
27, 81, 27, 27, 729, 729, 9, 81, 243, 243, 9, 9, 243, 243, 81, 27, 81, 243, 81,
81, 729, 729, 27, 729, 9, 9, 81, 81, 81, 729, 27, 729, 27, 729, 81, 81, 81,
2187, 81, 27, 243, 243, 81, 81, 243, 243, 243, 243, 243, 729, 729, 729, 2187,
6561]


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
    A.L(77031),             A.N("seed")
    A.L(0),                 A.N("upper")
    A.L(0),                 A.N("lower")
    A.L(0),                 A.N("temp")
    ## Apply this to array_bottom_temp, since we don't have it in hardware
    #A.L((-1 & 0xFFF) << 20 | (-1 & 0x3FF)),     A.N("array_bottom_pointer_decr")
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
    B.P("lookahead_pointer",       mem_map["B"]["PO_INC_base"],       write_addr = mem_map["H"]["PO_INC_base"])
    B.P("odd_count_cubed_pointer", mem_map["B"]["PO_INC_base"] + 1,   write_addr = mem_map["H"]["PO_INC_base"] + 1)
    B.A(0)
    B.L(0)
    B.L(0xFF),              B.N("lower_mask")
    B.L(2**(B.width-8)),    B.N("right_shift_8")
    B.L(28),                B.N("steps")
    B.L(0),                 B.N("count")
    B.L(-3)
    B.L(lookahead[0]),      B.N("lookahead")
    for entry in lookahead[1:]:
        B.L(entry)
    B.L(-2)
    B.L(odd_count_cubed[0]), B.N("odd_count_cubed")
    for entry in odd_count_cubed[1:]:
        B.L(entry)
    B.L(-1)
    # Placeholders for programmed offset
    B.L(0),     B.N("lookahead_pointer_init")
    B.L(0),     B.N("odd_count_cubed_pointer_init")
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name

    # Thread 0 has implicit first NOP from pipeline, so starts at 1
    # All threads start at 1, to avoid triggering branching unit at 0.
    I.A(1)

    # Instructions to fill branch table
    base_addr = mem_map["BO"]["Origin"]
    #depth     = mem_map["BO"]["Depth"]

    # Name branch table entries
    I.P("BTM0", None, write_addr = base_addr)
    I.P("BTM1", None, write_addr = base_addr + 1)
    I.P("BTM2", None, write_addr = base_addr + 2)
    I.P("BTM3", None, write_addr = base_addr + 3)

    # Instructions to fill branch table
    I.I(ADD, "BTM0", "jmp0", 0)
    I.I(ADD, "BTM1", "jmp1", 0)
    I.I(ADD, "BTM2", "jmp2", 0)
    I.I(ADD, "BTM3", "jmp3", 0)

    # Instruction to set indirect access
    base_addr = mem_map["BPO"]["Origin"] 
    I.P("AOM0", None, write_addr = base_addr)
    I.P("AOM1", None, write_addr = base_addr + 1)

    # init
    I.I(ADD, "count", 0, "steps")

    # take a step
    I.I(ADD, "count", "minus_one", "count"),        I.N("loop")
    I.I(AND, "lower", "seed", "lower_mask"),        I.JZE("end", False, "jmp0")
    I.I(MHU, "upper", "seed", "right_shift_8")
    I.I(ADD, "AOM1", "lower", "odd_count_cubed_pointer_init")
    I.I(ADD, "AOM0", "lower", "lookahead_pointer_init")
    I.I(MLS, "temp", "upper", "odd_count_cubed_pointer")
    I.I(ADD, "seed", "temp",  "lookahead_pointer"), I.JMP("loop", "jmp1")

    # and we're done
    I.NOP(), I.N("end"), I.JMP("end", "jmp3")

    I.resolve_forward_jumps()

    # Set programmed offsets
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.R("lookahead")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] + B.W("lookahead")) & 0xFFF
    PO = (0 << 34) | (0 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("lookahead_pointer_init"))
    B.L(PO)

    # Set programmed offsets
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] - 1 + B.R("odd_count_cubed")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] - 1 + B.W("odd_count_cubed")) & 0xFFF
    PO = (0 << 34) | (0 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("odd_count_cubed_pointer_init"))
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

