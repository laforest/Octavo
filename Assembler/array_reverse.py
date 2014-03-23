#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Array_Reverse"
bench_file = "array_reverse"
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
    B.P("array_top_pointer",      mem_map["B"]["PO_INC_base"],   write_addr = mem_map["H"]["PO_INC_base"])
    B.P("array_bottom_pointer",   mem_map["B"]["PO_INC_base"] + 1,   write_addr = mem_map["H"]["PO_INC_base"] + 1)
    B.A(0)
    B.L(0)
    B.L(50),    B.N("array_half_length")
    B.L(0),     B.N("array_count")
    B.L(0),     B.N("temp_top")
    B.L(0),     B.N("temp_bottom")
    B.L(-2)
    B.L(1),     B.N("array_top") # 100 elements
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
    B.L(16)
    B.L(17)
    B.L(18)
    B.L(19)
    B.L(20)
    B.L(21)
    B.L(22)
    B.L(23)
    B.L(24)
    B.L(25)
    B.L(26)
    B.L(27)
    B.L(28)
    B.L(29)
    B.L(30)
    B.L(31)
    B.L(32)
    B.L(33)
    B.L(34)
    B.L(35)
    B.L(36)
    B.L(37)
    B.L(38)
    B.L(39)
    B.L(40)
    B.L(41)
    B.L(42)
    B.L(43)
    B.L(44)
    B.L(45)
    B.L(46)
    B.L(47)
    B.L(48)
    B.L(49)
    B.L(50)
    B.L(51)
    B.L(52)
    B.L(53)
    B.L(54)
    B.L(55)
    B.L(56)
    B.L(57)
    B.L(58)
    B.L(59)
    B.L(60)
    B.L(61)
    B.L(62)
    B.L(63)
    B.L(64)
    B.L(65)
    B.L(66)
    B.L(67)
    B.L(68)
    B.L(69)
    B.L(70)
    B.L(71)
    B.L(72)
    B.L(73)
    B.L(74)
    B.L(75)
    B.L(76)
    B.L(77)
    B.L(78)
    B.L(79)
    B.L(80)
    B.L(81)
    B.L(82)
    B.L(83)
    B.L(84)
    B.L(85)
    B.L(86)
    B.L(87)
    B.L(88)
    B.L(89)
    B.L(90)
    B.L(91)
    B.L(92)
    B.L(93)
    B.L(94)
    B.L(95)
    B.L(96)
    B.L(97)
    B.L(98)
    B.L(99)
    B.L(100),    B.N("array_bottom")
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


# "ideal" MIPS-like
# init: ADD  array_top,    0, array_top_init
#       ADD  array_bottom, 0, array_bottom_init
#       ADD  array_count,  0, array_half_length
# next: LW   temp_top,    array_top
#       LW   temp_bottom, array_bottom
#       SW   temp_bottom, array_top
#       SW   temp_top,    array_bottom
#       ADD  array_top,     1, array_top
#       ADD  array_bottom, -1, array_bottom
#       ADD  array_count,  -1, array_count
#       BGTZ next, array_count
#       JMP  init

# MIPS-equivalent (best-effort)
#    # Instruction to set indirect access
#    base_addr = mem_map["BPO"]["Origin"] 
#    I.I(ADD, base_addr,   0, "array_top_pointer_init"),    I.N("init")
#    I.I(ADD, base_addr+1, 0, "array_bottom_pointer_init")
#    I.I(ADD, "array_bottom_pointer_temp", 0, "array_bottom_pointer_init")
#    # Like all control memory writes: has a RAW latency on 1 thread cycle.
#    #I.NOP()
#    I.I(ADD, "array_count", 0, "array_half_length")
#    I.I(ADD, "temp_top",    0, "array_top_pointer"),        I.N("next")
#    I.I(ADD, "temp_bottom", 0, "array_bottom_pointer")
#    I.I(ADD, "array_bottom_pointer", 0, "temp_top")
#    I.I(ADD, "array_top_pointer",    0, "temp_bottom")
#    #I.NOP()
#    I.I(ADD, "array_bottom_pointer_temp", "array_bottom_pointer_decr", "array_bottom_pointer_temp")
#    I.I(ADD, base_addr+1, 0, "array_bottom_pointer_temp")
#    I.I(ADD, "array_count", "minus_one", "array_count")
#    I.NOP(),                                                I.JNZ("next", None, "jmp0")
#    I.NOP(),                                                I.JMP("init",       "jmp1")

# Experiment:
# 61 array reversals, 100 element array, over 200,000 simulation cycles
# Cycles: 197680 - 40 = 197640
# Useful cycles: 197640 / 8 = 24705
# Cycles per reversal: 24705 / 61 = 405
# Cycles per array element: 405 / 100 = 4.05

# PC Tally
#      1 1   # setup
#      1 2   # setup
#      1 3   # setup
#      1 4   # setup
#     62 5   # N
#     62 6   # N
#     62 7   # N
#     62 8   # N
#   3086 9   # U
#   3086 10  # U
#   3086 11  # U
#   3086 12  # U
#   3086 13  # N
#   3086 14  # N
#   3085 15  # N
#   3085 16  # N
#     61 17  # N

# Useful:         3086 + 3086 + 3086 + 3086                          = 12344
# Not Useful:     62 + 62 + 62 + 62 + 3086 + 3086 + 3085 + 3085 + 61 = 12651
# Total:                                                               24995
# ALU Efficiency: 12344 / 24995                                      = 0.49386



# MIPS-equivalent (exact)
#    # Instruction to set indirect access
#    base_addr = mem_map["BPO"]["Origin"] 
#    I.I(ADD, "array_bottom_pointer_temp", 0, "array_bottom_pointer_init")
#    I.I(ADD, base_addr,   0, "array_top_pointer_init"),    I.N("init")
#    I.I(ADD, base_addr+1, 0, "array_bottom_pointer_init")
#    # Like all control memory writes: has a RAW latency on 1 thread cycle.
#    #I.NOP()
#    I.I(ADD, "array_count", 0, "array_half_length")
#    I.I(ADD, "temp_top",    0, "array_top_pointer"),        I.N("next")
#    I.I(ADD, "temp_bottom", 0, "array_bottom_pointer")
#    I.I(ADD, "array_bottom_pointer", 0, "temp_top")
#    I.I(ADD, "array_top_pointer",    0, "temp_bottom")
#    I.I(ADD, "array_bottom_pointer_temp", "array_bottom_pointer_decr", "array_bottom_pointer_temp")
#    I.I(ADD, base_addr+1, 0, "array_bottom_pointer_temp")
#    I.I(ADD, "array_count", "minus_one", "array_count")
#    I.NOP(),                                                I.JNZ("next", None, "jmp0")
#    I.I(ADD, "array_bottom_pointer_temp", 0, "array_bottom_pointer_init"), I.JMP("init",       "jmp1")

# Experiment:
# 61 array reversals, 100 element array, over 200,000 simulation cycles
# Cycles: 197200 - 48 = 197152
# Useful cycles: 197152 / 8 = 24644
# Cycles per reversal: 24644 / 61 = 404
# Cycles per array element: 404 / 100 = 4.04
# vs. best-effort: 404 / 405          = -0.25%

# PC Tally
#      1 1   # setup
#      1 2   # setup
#      1 3   # setup
#      1 4   # setup
#      1 5   # setup
#     62 6   # N
#     62 7   # N
#     62 8   # N
#   3094 9   # U
#   3094 10  # U
#   3094 11  # U
#   3093 12  # U
#   3093 13  # N
#   3093 14  # N
#   3093 15  # N
#   3093 16  # N
#     61 17  # N
#
# Useful:         3094 + 3094 + 3094 + 3093                     = 12375
# Not Useful:     62 + 62 + 62 + 3093 + 3093 + 3093 + 3093 + 61 = 12558
# Total:                                                          24994
# ALU Efficiency: 12375 / 24994                                 = 0.49512
# vs. best-effort:      0.49512 / 0.49386                             = 1.0025 (+0.25%)



# Optimized
    # Instruction to set indirect access
    base_addr = mem_map["BPO"]["Origin"] 
    I.I(ADD, "array_bottom_pointer_temp", 0, "array_bottom_pointer_init")
    I.I(ADD, base_addr,   0, "array_top_pointer_init"),    I.N("init")
    I.I(ADD, base_addr+1, 0, "array_bottom_pointer_init")
    # Like all control memory writes: has a RAW latency on 1 thread cycle.
    #I.NOP()
    I.I(ADD, "array_count", 0, "array_half_length")
    I.I(ADD, "temp_top",    0, "array_top_pointer"),        I.N("next")
    I.I(ADD, "temp_bottom", 0, "array_bottom_pointer")
    I.I(ADD, "array_bottom_pointer", 0, "temp_top")
    I.I(ADD, "array_top_pointer",    0, "temp_bottom")
    I.I(ADD, "array_bottom_pointer_temp", "array_bottom_pointer_decr", "array_bottom_pointer_temp")
    I.I(ADD, "array_count", "minus_one", "array_count")
    I.I(ADD, base_addr+1, 0, "array_bottom_pointer_temp"),                 I.JNZ("next", None, "jmp0")
    I.I(ADD, "array_bottom_pointer_temp", 0, "array_bottom_pointer_init"), I.JMP("init",       "jmp1")

# Experiment:
# 70 array reversals, 100 element array, over 200,000 simulation cycles
# Cycles: 198288 - 48 = 198240
# Useful cycles: 198240 / 8 = 24780
# Cycles per reversal: 24780 / 70 = 354
# Cycles per array element: 354 / 100 = 3.54
# vs. exact:  354 / 404               = 0.87623 (or -12.4%)

# PC Tally
#      1 1   # setup
#      1 2   # setup
#      1 3   # setup
#      1 4   # setup
#      1 5   # setup
#     71 6   # N
#     71 7   # N
#     71 8   # N
#   3531 9   # U
#   3530 10  # U
#   3530 11  # U
#   3530 12  # U
#   3530 13  # N
#   3530 14  # N
#   3530 15  # N
#     70 16  # N
#
# Useful:         3531 + 3530 + 3530 + 3530              = 14121
# Not Useful:     71 + 71 + 71 + 3530 + 3530 + 3530 + 70 = 10873
# Total:                                                   24994
# ALU Efficiency: 14121 / 24994                          = 0.56498
# vs. exact:      0.56498 / 0.49512                      = 1.1411 (+14.1%)


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

