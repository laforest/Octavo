#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Hailstone_Packed_Cancelling"
bench_file = "hailstone_packed_cancelling"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

# literal pool not supported yet. Must use 0-based addressing in the code.
def partition_data_memory(memory_depth = 1024, literal_pool_depth = 0, thread_count = 8):
    thread_data_memory_depth = memory_depth - literal_pool_depth;
    offsets = [(thread * (thread_data_memory_depth / 8)) + literal_pool_depth for thread in range(0,thread_count)]
    return offsets

offsets = partition_data_memory()

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
    A.add_port_pair("READ_PORT", "WRITE_PORT", mem_map["A"]["IO_base"])
    # Peel out first loop for naming
    A.ALIGN(offsets[0])
    A.L(0),                 A.N("zero")
    A.L(1),                 A.N("one")
    A.L(3),                 A.N("three")
    A.L(2**(A.width-1)),    A.N("right_shift_1")
    A.L(0),                 A.N("temp")
    # Placeholders for branch table entries
    A.L(0),                 A.N("jmp_odd")
    A.L(0),                 A.N("jmp_out")
    A.L(0),                 A.N("jmp_hai")
    for thread in range(1,8):
        A.ALIGN(offsets[thread])
        A.L(0)
        A.L(1)
        A.L(3)
        A.L(2**(A.width-1))
        A.L(0)
        # Placeholders for branch table entries
        A.L(0)
        A.L(0)
        A.L(0)
    return A

def assemble_B():
    B = empty["B"]
    B.file_name = bench_name
    B.add_port_pair("READ_PORT", "WRITE_PORT", mem_map["B"]["IO_base"])
    B.add_port("INDIRECT_SEED_READ", mem_map["B"]["PO_INC_base"])
    B.add_port("INDIRECT_SEED_WRITE", mem_map["H"]["PO_INC_base"] - mem_map["B"]["Origin"]) # ECL workaround assembler write offset calculation
    seeds = [27, 47, 67, 87, 107, 127, 234, 335]
    B.ALIGN(offsets[0])
    B.L(0),            B.N("zero")
    B.L(seeds[0]),     B.N("seed")
    # Placeholders for programmed branch offsets (no increments)
    B.L(0),            B.N("seed_PO")
    for thread in range(1,8):
        B.ALIGN(offsets[thread])
        B.L(0)
        B.L(seeds[thread])
        # Placeholders for programmed branch offsets (no increments)
        B.L(0)
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name
    # Align threads 1-7 with thread 0
    #I.NOP()

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
    I.ALIGN(1)
    # All other threads start at 0 and will execute this NOP, so they should all be in step
    #I.NOP()

    # Instruction to set indirect access
    # Like all control memory writes: has a RAW latency on 1 thread cycle.
    base_addr = mem_map["BPO"]["Origin"] # ECL All same for now
    I.I(ADD, base_addr,                 0, (B,"seed_PO"))

    # Instructions to fill branch table
    base_addr = mem_map["BO"]["Origin"]
    depth     = mem_map["BO"]["Depth"]
    I.I(ADD, base_addr,                 (A,"jmp_odd"), 0)
    I.I(ADD, base_addr + depth,         (A,"jmp_out"), 0)
    I.I(ADD, base_addr + (depth * 2),   (A,"jmp_hai"), 0)

    # Is the seed odd?
    I.I(AND, (A,"temp"), (A,"one"), (B,"INDIRECT_SEED_READ")),            I.N("hai_dest")
    # I.NOP(),                                              I.N("odd_orig")
    # Hoisted from destination, Predict Taken
    I.I(MLS, (B,"INDIRECT_SEED_WRITE"), (A,"three"), (B,"INDIRECT_SEED_READ")),          I.N("odd_orig")

    # Even: seed = seed / 2
    I.I(MHU, (B,"INDIRECT_SEED_WRITE"), (A,"right_shift_1"), (B,"INDIRECT_SEED_READ")),  I.N("out_orig")

    # Odd: seed = (3 * seed) + 1
    # I.I(MLS, (B,"seed"), (A,"three"), (B,"seed")),          I.N("odd_dest")
    # I.I(ADD, (B,"seed"), (A,"one"), (B,"seed"))
    # Hoisted to branch origin
    I.I(ADD, (B,"INDIRECT_SEED_WRITE"), (A,"one"), (B,"INDIRECT_SEED_READ")),            I.N("odd_dest")

    I.I(ADD, (A,"WRITE_PORT"), 0, (B,"INDIRECT_SEED_READ")),              I.N("out_dest")
    I.I(ADD, (B,"WRITE_PORT"), 0, (B,"INDIRECT_SEED_READ")),              I.N("hai_orig")

    # Now lets fill those branch table values
    for offset in offsets:
        origin      = I.names["odd_orig"]
        destination = I.names["odd_dest"] << 10
        condition   = JNZ                 << 20
        prediction  = 1                   << 23 # Predict Taken
        prediction_enable = 1             << 24
        A.ALIGN(A.names["jmp_odd"] + offset)
        A.L(prediction_enable | prediction | condition | destination | origin)

        origin      = I.names["out_orig"]
        destination = I.names["out_dest"] << 10
        condition   = JMP                 << 20
        prediction  = 0                   << 23
        prediction_enable = 0             << 24
        A.ALIGN(A.names["jmp_out"] + offset)
        A.L(prediction_enable | prediction | condition | destination | origin)

        origin      = I.names["hai_orig"]
        destination = I.names["hai_dest"] << 10
        condition   = JMP                 << 20
        prediction  = 0                   << 23
        prediction_enable = 0             << 24
        A.ALIGN(A.names["jmp_hai"] + offset)
        A.L(prediction_enable | prediction | condition | destination | origin)

    for offset in offsets:
        read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.names["seed"] + offset) & 0x3FF
        write_PO = (4096 - mem_map["H"]["PO_INC_base"] + B.names["seed"] + offset + mem_map["B"]["Origin"]) & 0xFFF
        PO = (write_PO << 20) | read_PO
        B.ALIGN(B.names["seed_PO"] + offset)
        B.L(PO)

    return I

def assemble_XDO():
    ADO, BDO, DDO = empty["ADO"], empty["BDO"], empty["DDO"]
    ADO.file_name = bench_name
    BDO.file_name = bench_name
    DDO.file_name = bench_name
    for mem in ADO, BDO, DDO:
        for offset in offsets:
            mem.L(offset)
    return ADO, BDO, DDO

def assemble_XPO():
    APO, BPO, DPO = empty["APO"], empty["BPO"], empty["DPO"]
    APO.file_name = bench_name
    BPO.file_name = bench_name
    DPO.file_name = bench_name
    for mem in APO, BPO, DPO:
        for count in range(0,8):
            mem.L(0)
    return APO, BPO, DPO

def assemble_XIN():
    AIN, BIN, DIN = empty["AIN"], empty["BIN"], empty["DIN"]
    AIN.file_name = bench_name
    BIN.file_name = bench_name
    DIN.file_name = bench_name
    for mem in AIN, BIN, DIN:
        for count in range(0,8):
            mem.L(0)
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

