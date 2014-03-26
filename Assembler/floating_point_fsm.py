#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Floating_Point_FSM"
bench_file = "floating_point_fsm"
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
    # Literal numbers
    A.L(0)
    A.L(1),                 A.N("one")
    A.L(-1),                A.N("minus_one")
    A.L(10),                A.N("ten")
    # FSM input alphabet
    A.C(' '),               A.N("space")
    A.C('-'),               A.N("minus")
    A.C('+'),               A.N("plus")
    A.C('.'),               A.N("dot")
    A.L(-ord('0')),         A.N("zero_char_neg")
    # Placeholders for branch table entries
    A.L(0),                 A.N("br00")
    A.L(0),                 A.N("br01")
    A.L(0),                 A.N("br02")
    A.L(0),                 A.N("br03")
    A.L(0),                 A.N("br04")
    A.L(0),                 A.N("br05")
    A.L(0),                 A.N("br06")
    A.L(0),                 A.N("br07")
    A.L(0),                 A.N("br08")
    A.L(0),                 A.N("br09")
    A.L(0),                 A.N("br10")
    A.L(0),                 A.N("br11")
    A.L(0),                 A.N("br12")
    A.L(0),                 A.N("br13")
    A.L(0),                 A.N("br14")
    A.L(0),                 A.N("br15")
    A.L(0),                 A.N("br16")
    A.L(0),                 A.N("br17")
    A.L(0),                 A.N("br18")
    A.L(0),                 A.N("br19")
    A.L(0),                 A.N("br20")
    A.L(0),                 A.N("br21")
    A.L(0),                 A.N("br22")
    A.L(0),                 A.N("br23")
    A.L(0),                 A.N("br24")
    A.L(0),                 A.N("br25")
    A.L(0),                 A.N("br26")
    A.L(0),                 A.N("br27")
    A.L(0),                 A.N("br28")
    A.L(0),                 A.N("br29")
    A.L(0),                 A.N("br30")
    A.L(0),                 A.N("br31")
    A.L(0),                 A.N("br32")
    A.L(0),                 A.N("br33")
    return A

def assemble_B():
    B = empty["B"]
    B.file_name = bench_name
    B.P("B_IO", mem_map["B"]["IO_base"])
    B.P("array_top_pointer",      mem_map["B"]["PO_INC_base"],   write_addr = mem_map["H"]["PO_INC_base"])
    B.A(0)
    B.L(0)
    B.L(0),     B.N("temp")
    B.L(0),     B.N("temp2")
    B.L(-2)     # Guard value for debugging
    B.C(' '),   B.N("array_top") # 103 elements, including final guard (-1)
    B.C('-')
    B.C('.')
    B.C('9')
    B.C(' ') # Accept 1 2 3 
    B.C('+')
    B.C('8')
    B.C('.')
    B.C('6')
    B.C(' ') # Accept 1 4 5 3
    B.C('-')
    B.C('5')
    B.C('.')
    B.C(' ') # Accept 1 4 5 
    B.C('.')
    B.C('7')
    B.C(' ') # Accept 2 3
    B.C('4')
    B.C('.')
    B.C(' ') # Accept 4 5
    B.C('5') 
    B.C('.')
    B.C('2')
    B.C(' ') # Accept 4 5 3
    B.C('-')
    B.C('.')
    B.C('9')
    B.C(' ') # Accept 1 2 3 
    B.C('+')
    B.C('8')
    B.C('.')
    B.C('6')
    B.C(' ') # Accept 1 4 5 3
    B.C('-')
    B.C('5')
    B.C('.')
    B.C(' ') # Accept 1 4 5 
    B.C('.')
    B.C('7')
    B.C(' ') # Accept 2 3
    B.C('4')
    B.C('.')
    B.C(' ') # Accept 4 5
    B.C('5') 
    B.C('.')
    B.C('2')
    B.C(' ') # Accept 4 5 3
    B.C('-')
    B.C('.')
    B.C('9')
    B.C(' ') # Accept 1 2 3 
    B.C('+')
    B.C('8')
    B.C('.')
    B.C('6')
    B.C(' ') # Accept 1 4 5 3
    B.C('-')
    B.C('5')
    B.C('.')
    B.C(' ') # Accept 1 4 5 
    B.C('.')
    B.C('7')
    B.C(' ') # Accept 2 3
    B.C('4')
    B.C('.')
    B.C(' ') # Accept 4 5
    B.C('5') 
    B.C('.')
    B.C('2')
    B.C(' ') # Accept 4 5 3
    B.C('-')
    B.C('.')
    B.C('9')
    B.C(' ') # Accept 1 2 3 
    B.C('+')
    B.C('8')
    B.C('.')
    B.C('6')
    B.C(' ') # Accept 1 4 5 3
    B.C('-')
    B.C('5')
    B.C('.')
    B.C(' ') # Accept 1 4 5 
    B.C('.')
    B.C('7')
    B.C(' ') # Accept 2 3
    B.C('4')
    B.C('.')
    B.C(' ') # Accept 4 5
    B.C('5') 
    B.C('.')
    B.C('2')
    B.C(' ') # Accept 4 5 3
    B.C('-')
    B.C('.')
    B.C('9')
    B.C(' ') # Accept 1 2 3 
    B.C('-')
    B.C('.')
    B.C('9')
    B.C('A') # Reject 1 2 3
    B.C(' '),   B.N("array_bottom")
    B.L(-1)     # Guard value for debugging and outer loop
    # Placeholders for programmed offset
    B.L(0),     B.N("array_top_pointer_init")
    return B

# "ideal" MIPS-like
# init:   
#         ADD  array_top,    0, array_top_init

# state0: 
#         LW   temp, array_top
#         BLTZ init, temp
#         ADD  array_top, 1, array_top
#         XOR  temp2,  temp,  space
#         BEQZ state0, temp2
#         XOR  temp2,  temp,  plus
#         BEQZ state1, temp2
#         XOR  temp2,  temp,  minus
#         BEQZ state1, temp2
#         XOR  temp2,  temp,  dot
#         BEQZ state2, temp2
#         SUB  temp2,  temp,  zero_char
#         BLTZ state7, temp2
#         SUB  temp2,  10,    temp2
#         BGEZ state4, temp2
#         JMP  state7

# state1: 
#         LW   temp, array_top
#         BLTZ init, temp
#         ADD  array_top, 1, array_top
#         XOR  temp2,  temp,  dot
#         BEQZ state2, temp2
#         SUB  temp2,  temp,  zero_char
#         BLTZ state7, temp2
#         SUB  temp2,  10,    temp2
#         BGEZ state4, temp2
#         JMP  state7

# state2:
#         LW   temp, array_top
#         BLTZ init, temp
#         ADD  array_top, 1, array_top
#         SUB  temp2,  temp,  zero_char
#         BLTZ state7, temp2
#         SUB  temp2,  10,    temp2
#         BGEZ state3, temp2
#         JMP  state7

# state3:
#         LW   temp, array_top
#         BLTZ init, temp
#         ADD  array_top, 1, array_top
#         XOR  temp2,  temp,  space
#         BEQZ state6, temp2
#         SUB  temp2,  temp,  zero_char
#         BLTZ state7, temp2
#         SUB  temp2,  10,    temp2
#         BGEZ state3, temp2
#         JMP  state7

# state4:
#         LW   temp, array_top
#         BLTZ init, temp
#         ADD  array_top, 1, array_top
#         XOR  temp2,  temp,  dot
#         BEQZ state5, temp2
#         SUB  temp2,  temp,  zero_char
#         BLTZ state7, temp2
#         SUB  temp2,  10,    temp2
#         BGEZ state4, temp2
#         JMP  state7

# state5:
#         LW   temp, array_top
#         BLTZ init, temp
#         ADD  array_top, 1, array_top
#         XOR  temp2,  temp,  space
#         BEQZ state6, temp2
#         SUB  temp2,  temp,  zero_char
#         BLTZ state7, temp2
#         SUB  temp2,  10,    temp2
#         BGEZ state3, temp2
#         JMP  state7

# state6:
#         SW   1, OUTPUT_PORT_ACCEPT
#         JMP  state0

# state7: 
#         SW   1, OUTPUT_PORT_REJECT
#         JMP  state0

###
# 34 branches, but only 11 unique ones
# one per state, plus branch to init, and fall-through jumps to start (0) and reject (7)
# Well, not really, since they all have different origin points
# Question is: how many are live at any one time? What's the re-use distance?
###

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name

    # Thread 0 has implicit first NOP from pipeline, so starts at 1
    # All threads start at 1, to avoid triggering branching unit at 0.
    I.A(1)

    # Instructions to fill branch table
    base_addr = mem_map["BO"]["Origin"]
    depth     = mem_map["BO"]["Depth"]
    I.P("BTT0", None, write_addr = base_addr)
    I.P("BTT1", None, write_addr = base_addr + 1)
    I.P("BTT2", None, write_addr = base_addr + 2)
    I.P("BTT3", None, write_addr = base_addr + 3)
    # First few branches in state0
    I.I(ADD, "BTT0", "br00", 0) # Used throughout
    I.I(ADD, "BTT1", "br33", 0) # Saves a cycle in state7!!!
    I.I(ADD, "BTT2", "br32", 0) # Needed to save a cycle to keep equivalency
    I.I(ADD, "BTT3", "br03", 0) # unused

# "ideal" MIPS-like equivalent 
    # Instruction to set indirect access
    base_addr = mem_map["BPO"]["Origin"] 
    I.I(ADD, base_addr,   0, "array_top_pointer_init"),     I.N("init")


    I.I(ADD, "BTT0", "br00", 0),                            I.N("state0")                             
    I.I(ADD, "temp", 0, "array_top_pointer")
    I.I(ADD, "BTT0", "br01", 0),                            I.JNE("init",   False, "br00")
    #I.NOP()                                                 # pointer incr
    I.I(XOR, "temp2", "space", "temp")
    I.I(ADD, "BTT0", "br02", 0),                            I.JZE("state0", False, "br01")
    I.I(XOR, "temp2", "plus", "temp")
    I.I(ADD, "BTT0", "br03", 0),                            I.JZE("state1", False, "br02")
    I.I(XOR, "temp2", "minus", "temp")
    I.I(ADD, "BTT0", "br04", 0),                            I.JZE("state1", False, "br03")
    I.I(XOR, "temp2", "dot", "temp")
    I.I(ADD, "BTT0", "br05", 0),                            I.JZE("state2", False, "br04")
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "BTT0", "br06", 0),                            I.JNE("state7", False, "br05")
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "BTT0", "br07", 0),                            I.JPO("state4", False, "br06")
    I.I(ADD, "BTT0", "br07", 0)
    I.I(ADD, "B_IO", "one", 0)                              # State 7 folded
    I.NOP(),                                                I.JMP("state0",        "br07")


    I.I(ADD, "BTT0", "br08", 0),                            I.N("state1")
    I.I(ADD, "temp", 0, "array_top_pointer")
    I.I(ADD, "BTT0", "br09", 0),                            I.JNE("init",   False, "br08")
    #I.NOP()                                                 # pointer incr
    I.I(XOR, "temp2", "dot", "temp")
    I.I(ADD, "BTT0", "br10", 0),                            I.JZE("state2", False, "br09")
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "BTT0", "br11", 0),                            I.JNE("state7", False, "br10")
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "BTT0", "br12", 0),                            I.JPO("state4", False, "br11")
    I.I(ADD, "BTT0", "br12", 0)
    I.I(ADD, "B_IO", "one", 0)                              # State 7 folded
    I.NOP(),                                                I.JMP("state0",        "br12")


    I.I(ADD, "BTT0", "br13", 0),                            I.N("state2")
    I.I(ADD, "temp", 0, "array_top_pointer")
    I.I(ADD, "BTT0", "br14", 0),                            I.JNE("init",   False, "br13")
    #I.NOP()                                                 # pointer incr
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "BTT0", "br15", 0),                            I.JNE("state7", False, "br14")
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "BTT0", "br16", 0),                            I.JPO("state3", False, "br15")
    I.I(ADD, "BTT0", "br16", 0)
    I.I(ADD, "B_IO", "one", 0)                              # State 7 folded
    I.NOP(),                                                I.JMP("state0",        "br16")


    I.I(ADD, "BTT0", "br17", 0),                            I.N("state3")
    I.I(ADD, "temp", 0, "array_top_pointer")
    I.I(ADD, "BTT0", "br18", 0),                            I.JNE("init",   False, "br17")
    #I.NOP()                                                 # pointer incr
    I.I(XOR, "temp2", "space", "temp")
    I.I(ADD, "BTT0", "br19", 0),                            I.JZE("state6", False, "br18")
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "BTT0", "br20", 0),                            I.JNE("state7", False, "br19")
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "BTT0", "br21", 0),                            I.JPO("state3", False, "br20")
    I.I(ADD, "BTT0", "br21", 0)
    I.I(ADD, "B_IO", "one", 0)                              # State 7 folded
    I.NOP(),                                                I.JMP("state0",        "br21")


    I.I(ADD, "BTT0", "br22", 0),                            I.N("state4")
    I.I(ADD, "temp", 0, "array_top_pointer")
    I.I(ADD, "BTT0", "br23", 0),                            I.JNE("init",   False, "br22")
    #I.NOP()                                                 # pointer incr
    I.I(XOR, "temp2", "dot", "temp")
    I.I(ADD, "BTT0", "br24", 0),                            I.JZE("state5", False, "br23")
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "BTT0", "br25", 0),                            I.JNE("state7", False, "br24")
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "BTT0", "br26", 0),                            I.JPO("state4", False, "br25")
    I.I(ADD, "BTT0", "br26", 0)
    I.I(ADD, "B_IO", "one", 0)                              # State 7 folded
    I.NOP(),                                                I.JMP("state0",        "br26")


    I.I(ADD, "BTT0", "br27", 0),                            I.N("state5")
    I.I(ADD, "temp", 0, "array_top_pointer")
    I.I(ADD, "BTT0", "br28", 0),                            I.JNE("init",   False, "br27")
    #I.NOP()                                                 # pointer incr
    I.I(XOR, "temp2", "space", "temp")
    I.I(ADD, "BTT0", "br29", 0),                            I.JZE("state6", False,  "br28")
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "BTT0", "br30", 0),                            I.JNE("state7", False, "br29")
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "BTT0", "br31", 0),                            I.JPO("state3", False, "br30")
    I.I(ADD, "BTT0", "br31", 0)
    I.I(ADD, "B_IO", "one", 0)                              # State 7 folded
    I.NOP(),                                                I.JMP("state0",        "br31")


    I.I(ADD, "A_IO", "one", 0),                             I.N("state6") # ACCEPT
    I.NOP(),                                                I.JMP("state0",        "br32")


    # +1 over "ideal" MIPS-like, so stored in BTT1!
    #I.I(ADD, "BTT0", "br33", 0),                            I.N("state7")
    I.I(ADD, "B_IO", "one", 0),                             I.N("state7")
    I.NOP(),                                                I.JMP("state0",        "br33")

# Experiment (MIPS-equiv)
# 30 runs over 103 input symbols, including outer loop guard
# Cycles: 193720 - 40 = 193680
# Useful cycles: 193680 / 8 = 24210
# Cycles per run (25 Accepts, 1 Reject): 24210 / 30 = 807
# Cycles per Accept/Reject: 807 / 26 = 31.038
# Cycles per input symbol: 807 / 103 = 7.835
# Input symbols per Accept/Reject: 103 / 26 = 3.9615
# Input symbols per Accept/Reject:  31.038 / 7.835 = 3.9615 (accuracy cross-check)

# PC Tally:
#
#  To generate matching numbered instruction list:
#  cat floating_point_fsm.py | egrep " I\.[NI]" | nl | gview -
#
#      1 1   # setup
#      1 2   # setup
#      1 3   # setup
#      1 4   # setup
#     31 5   # N
#    897 6   # N
#    897 7   # U
#    897 8   # U
#    867 9   # U
#    867 10  # U
#    806 11  # U
#    806 12  # U
#    682 13  # U
#    682 14  # U
#    372 15  # U
#    372 16  # U
#    248 17  # U 
#    248 18  # U
#    248 19  # U
#    248 20  # U
#    434 24  # N
#    434 25  # U
#    434 26  # U
#    434 27  # U
#    434 28  # U
#    248 29  # U
#    248 30  # U
#    248 31  # U
#    248 32  # U
#    310 36  # N
#    310 37  # U
#    310 38  # U
#    310 39  # U
#    310 40  # U
#    309 41  # U
#    309 42  # U
#    557 46  # N
#    557 47  # U
#    557 48  # U
#    557 49  # U
#    557 50  # U
#     30 51  # U
#     30 52  # U
#     30 53  # U
#     30 54  # U
#     30 55  # N
#     30 56  # U
#     30 57  # U
#    496 58  # N
#    496 59  # U
#    496 60  # U
#    496 61  # U
#    496 62  # U
#    496 70  # N
#    496 71  # U
#    496 72  # U
#    496 73  # U
#    496 74  # U
#    248 75  # U
#    248 76  # U
#    248 77  # U
#    248 78  # U
#    775 82  # U
#    775 83  # U
#
# (sums done externally: cat foo | sed -E -e's/\s+/ /g' | grep "# U" | cut -d' ' -f 2 | awk '{ sum+=$1} END {print sum}'
# Useful:     21744
# Not Useful:  3251
# Total:      24995
# ALU Efficiency:  21744 / 24995 = 0.86993


    I.resolve_forward_jumps()

    # Set programmed offsets
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.R("array_top")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] + B.W("array_top")) & 0xFFF
    PO = (1 << 34) | (1 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("array_top_pointer_init"))
    B.L(PO)

    # Set programmed offsets
    #read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] - 1 + B.R("array_bottom")) & 0x3FF
    #write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] - 1 + B.W("array_bottom")) & 0xFFF
    #PO = (0 << 34) | (0 << 32) | (write_PO << 20) | read_PO
    #B.A(B.R("array_bottom_pointer_init"))
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

