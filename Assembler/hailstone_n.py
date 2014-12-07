#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Hailstone_N"
bench_file = "hailstone_n"
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
    # Literals
    A.L(0)
    A.L(-1),                A.N("minus_one")
    A.L(1),                 A.N("one")
    A.L(3),                 A.N("three")
    A.L(2**(A.width-1)),    A.N("right_shift_1")
    # Results
    A.L(0),                 A.N("even_val")
    A.L(0),                 A.N("temp2")
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
    B.L(128),    B.N("length")
    B.L(0),      B.N("count")
    # Results
    B.L(0),      B.N("temp")
    B.L(0),      B.N("odd_val")
    # Literals
    B.L(1),      B.N("one")
    B.L(2**(B.width-1)),    B.N("right_shift_1")
    B.L(333),    B.N("seeds") # 128 elements
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
# 28 more
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

    # Thread 0 has implicit first NOP from pipeline, so starts at 1
    # All threads start at 1, to avoid triggering branching unit at 0.
    I.A(1)

    base_addr = mem_map["BO"]["Origin"]
    depth     = mem_map["BO"]["Depth"]
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
    I.I(ADD, base_addr, 0, "seed_pointer_init")
    I.I(ADD, "count", 0, "length") 

    # Branch-free version. Thanks go to Aaron Severance. I got schooled.

    I.I(ADD, "count", "minus_one", "count"),            I.N("hailstone")
    I.I(ADD, "temp", 0, "seed_pointer"),                I.JZE("end", False, "jmp0")
    I.I(MLS, "temp2", "three", "temp")
    I.I(ADD, "temp2", "temp2", "one")
    I.I(MHU, "odd_val", "temp2", "right_shift_1")
    I.I(MHU, "even_val", "right_shift_1", "temp")

    # Compute mask from even/odd bit
    I.I(AND, "temp", "one", "temp")
    I.I(ADD, "temp", "minus_one", "temp")

    # Compute (A & ~M) + (B & M), where A is odd_val
    #I.I(XOR, "temp2", "minus_one", "temp")
    #I.I(AND, "even_val", "even_val", "temp")
    #I.I(AND, "odd_val", "temp2", "odd_val")
    #I.I(OR, "seed_pointer", "even_val", "odd_val"),  I.JMP("hailstone", "jmp2")

    # Compute A ^ (M & (A ^ B)), where A is odd_val 
    # (one cycle shorter since no ~M, thanks to Henry Wong)
    I.I(XOR, "temp2", "even_val", "odd_val")
    I.I(AND, "temp2", "temp2", "temp")
    I.I(XOR, "seed_pointer", "temp2", "odd_val"),  I.JMP("hailstone", "jmp2")

    # and we're done
    I.NOP(), I.N("end"), I.JMP("end", "jmp3")

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

