#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Hailstone_Stencil_Overhead"
bench_file = "hailstone_stencil_overhead"
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
    A.L(1),                 A.N("one")
    A.L(3),                 A.N("three")
    A.L(2**(A.width-1)),    A.N("right_shift_1")
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
    B.P("seed_pointer",   mem_map["B"]["PO_INC_base"],   write_addr = mem_map["H"]["PO_INC_base"])
    B.A(0)
    B.L(0)
    B.L(0),     B.N("temp")
    B.L(0),     B.N("temp2")
    B.L(333),    B.N("seeds") # 100 elements
    B.L(15093)
    B.L(53956)
    B.L(91327)
    B.L(26294)
    B.L(85971)
    B.L(25760)
    B.L(51582)
    B.L(30794)
    B.L(69334)
    B.L(62299)
    B.L(49438)
    B.L(84916)
    B.L(58898)
    B.L(64309)
    B.L(95439)
    B.L(76368)
    B.L(36062)
    B.L(92253)
    B.L(38435)
    B.L(14227)
    B.L(40480)
    B.L(87357)
    B.L(87055)
    B.L(56934)
    B.L(58240)
    B.L(44037)
    B.L(43602)
    B.L(46250)
    B.L(24175)
    B.L(14299)
    B.L(91354)
    B.L(31251)
    B.L(56785)
    B.L(55811)
    B.L(49030)
    B.L(17973)
    B.L(35340)
    B.L(45723)
    B.L(47437)
    B.L(30536)
    B.L(76451)
    B.L(68232)
    B.L(93312)
    B.L(36248)
    B.L(99951)
    B.L(92797)
    B.L(27659)
    B.L(59184)
    B.L(51654)
    B.L(87317)
    B.L(81803)
    B.L(69681)
    B.L(43028)
    B.L(14176)
    B.L(88215)
    B.L(42476)
    B.L(30393)
    B.L(93081)
    B.L(81433)
    B.L(12647)
    B.L(40314)
    B.L(59206)
    B.L(76654)
    B.L(2331)
    B.L(13004)
    B.L(69549)
    B.L(71920)
    B.L(36328)
    B.L(67928)
    B.L(25851)
    B.L(12980)
    B.L(72936)
    B.L(90323)
    B.L(94762)
    B.L(18764)
    B.L(435)
    B.L(86581)
    B.L(402)
    B.L(41511)
    B.L(36071)
    B.L(4237)
    B.L(16356)
    B.L(40304)
    B.L(6110)
    B.L(11919)
    B.L(18517)
    B.L(45699)
    B.L(34058)
    B.L(16748)
    B.L(49922)
    B.L(18452)
    B.L(34965)
    B.L(8700)
    B.L(81423)
    B.L(37177)
    B.L(6577)
    B.L(12411)
    B.L(58089)
    B.L(56872)
    B.L(-1)
    # Placeholders for programmed offset
    B.L(0),     B.N("seed_pointer_init")
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name

# Original Octavo code for reference
#    for thread in range(0,8):
#        I.ALIGN(PC.get_pc("THREAD{}_START"))
#        # Is the seed odd?
#        I.I(AND, (A,"temp"), (A,"one"), (B,"seed")),           I.N("hailstone")
#        I.I(JNZ, 0, (A,"temp"), 0),                            I.N("odd")
#        # Even: seed = seed / 2
#        I.I(MHU, (B,"seed"), (A,"right_shift_1"), (B,"seed"))
#        I.I(JMP, 0, 0, 0),                                     I.N("output")
#        # Odd: seed = (3 * seed) + 1
#        I.I(MLS, (B,"seed"), (A,"three"), (B,"seed")),         I.RD("odd")
#        I.I(ADD, (B,"seed"), (A,"one"), (B,"seed"))
#        I.I(ADD, (A,"WRITE_PORT"), 0, (B,"seed")),             I.RD("output")
#        I.I(ADD, (B,"WRITE_PORT"), 0, (B,"seed"))
#        I.I(JMP, "hailstone", 0, 0)

# How would MIPS do it? Ideal case: no load or branch delay slots, full result forwarding
#
# init:     ADD     seed_pointer, seed_pointer_init, 0
# begin:    LW      temp, seed_pointer
#           BLTZ    init, temp
#           AND     temp2, temp, 1
#           BEQ     even, temp2, 0
#           MULT    temp, temp, 3
#           ADDI    temp, temp, 1
#           JMP     output
# even:     SRA     temp, 1
# output:   SW      temp, seed_pointer
#           ADD     seed_pointer, seed_pointer, 1
#           SW      temp, IO_PORT
#           JMP     begin

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
    I.I(ADD, base_addr,     0, "seed_pointer_init"),    I.N("init")                 # init:     ADD     seed_pointer, seed_pointer_init, 0
    # Like all control memory writes: has a RAW latency on 1 thread cycle.
    I.NOP()                                                                         # !!!

# Overhead version
#    I.I(ADD, "temp", 0, "seed_pointer"),                I.N("hailstone")            # begin:    LW      temp, seed_pointer
#    I.NOP(),                                            I.JNE("init", None, "jmp1") #           BLTZ    init, temp
#    I.I(AND, "temp2", "one", "temp")                                                #           AND     temp2, temp, 1
#    I.NOP(),                                            I.JZE("even", None, "jmp0") #           BEQ     even, temp2, 0
#    I.I(MLS, "temp", "three", "temp")                                               #           MULT    temp, temp, 3
#    I.I(ADD, "temp", "one", "temp")                                                 #           ADDI    temp, temp, 1
#    I.NOP(),                                            I.JMP("output", "jmp2")     #           JMP     output
#    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even")                 # even:     SRA     temp, 1
#    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output")               # output:   SW      temp, seed_pointer
#    I.NOP()                                                                         #           ADD     seed_pointer, seed_pointer, 1
#    I.I(ADD, "A_IO", 0, "temp"),                                                    #           SW      temp, IO_PORT
#    I.NOP(),                                            I.JMP("hailstone", "jmp3")  #           JMP     begin

# Experiment:
# Code size: 14 instructions
# 25 passes over 100 elements inside 200,000 simulation cycles
# Cycles: 194072 - 40 = 194032
# Useful cycles: 194032 / 8 = 24254
# Cycles per pass: 24254 / 25 = 970.16
# Cycles per output: 970.16 / 100 = 9.7016

# Efficient version
    I.I(ADD, "temp", 0, "seed_pointer"),        I.N("hailstone")
    I.I(MLS, "temp", "three", "temp"),          I.JEV("even", False, "jmp0"), I.JNE("init", False, "jmp1")
    I.I(ADD, "temp", "one", "temp"),            I.JMP("output", "jmp2")
    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even")
    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output")
    I.I(ADD, "A_IO", 0, "temp"),                I.JMP("hailstone", "jmp3")

# Experiment:
# Code size: 8 instructions
# 49 passes over 100 elements inside 200,000 simulation cycles
# Cycles: 197608 - 40 = 197568
# Useful cycles: 197568 / 8 = 24696
# Cycles per pass: 24696 / 49 = 504.00
# Cycles per output: 504 / 100 = 5.04

# Speedup: 9.7016 / 5.04 = 1.92492 (or +48%)
# Code size ratio: 8 / 14 = 0.5714 (or -43%)
# But account for tables: 4 branch tables at 10+10+3+2 = 25 bits each = 100 bits, 1 PO table: 10+10+12+3 = 35 bits
# 135 bits / 36 bits per instruction = 3.75 instruction 
# 8 + 3.75 = 11.75, only 16% smaller at best. (table storage isn't perfectly efficient)
# or count storage words for initialization data: 8 + 4 + 1 = 13, so it basically breaks even.

    # Resolve jumps and set programmed offsets
    I.resolve_forward_jumps()
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.R("seeds")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] + B.W("seeds")) & 0xFFF
    PO = (1 << 34) | (1 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("seed_pointer_init"))
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

