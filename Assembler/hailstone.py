#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Hailstone"
bench_file = "hailstone"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

# literal pool not supported yet. Must use 0-based addressing in the code.
#def partition_data_memory(memory_depth = 1024, literal_pool_depth = 0, thread_count = 8):
#    thread_data_memory_depth = memory_depth - literal_pool_depth;
#    offsets = [(thread * (thread_data_memory_depth / 8)) + literal_pool_depth for thread in range(0,thread_count)]
#    return offsets

#offsets = partition_data_memory()

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
    A.L(0),                 A.N("temp")
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
    B.P("INDIRECT_SEED", mem_map["B"]["PO_INC_base"], write_addr = mem_map["H"]["PO_INC_base"])
    B.A(0)
    B.L(0)
    B.L(27),     B.N("seed")
    # Placeholders for programmed offset
    B.L(0),      B.N("seed_PO")
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name

# Original code for reference
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

    # Thread 0 has implicit first NOP from pipeline, so starts at 1
    # All threads start at 1, to avoid triggering branching unit at 0.
    I.A(1)

    # Instruction to set indirect access
    # Like all control memory writes: has a RAW latency on 1 thread cycle.
    base_addr = mem_map["BPO"]["Origin"] 
    I.I(ADD, base_addr, 0, "seed_PO")

    # Instructions to fill branch table
    base_addr = mem_map["BO"]["Origin"]
    depth     = mem_map["BO"]["Depth"]
    I.I(ADD, base_addr,               "jmp0", 0)
    I.I(ADD, base_addr +  depth,      "jmp1", 0)
    I.I(ADD, base_addr + (depth * 2), "jmp2", 0)
    I.I(ADD, base_addr + (depth * 3), "jmp3", 0)
    I.NOP()

    # Is the seed odd?
    I.I(AND, "temp", "one", "INDIRECT_SEED"),                       I.N("hailstone")
    # Hoisted from destination, Predict Taken
    I.I(MLS, "INDIRECT_SEED", "three", "INDIRECT_SEED"),            I.JNZ("odd", True, "jmp0")
    # Even: seed = seed / 2
    I.I(MHU, "INDIRECT_SEED", "right_shift_1", "INDIRECT_SEED"),    I.JMP("output", "jmp1")
    # Odd: seed = (3 * seed) + 1
    I.I(ADD, "INDIRECT_SEED", "one", "INDIRECT_SEED"),              I.N("odd")
    # Output
    I.I(ADD, "A_IO", 0, "INDIRECT_SEED"),                           I.N("output")
    I.I(ADD, "B_IO", 0, "INDIRECT_SEED"),                           I.JMP("hailstone", "jmp2")

    I.resolve_forward_jumps()

    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.R("seed")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] + B.W("seed")) & 0xFFF
    PO = (write_PO << 20) | read_PO
    B.A(B.R("seed_PO"))
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

