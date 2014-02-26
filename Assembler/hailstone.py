#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map

bench_dir  = "Hailstone"
bench_file = "hailstone"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

def partition_data_memory(memory_depth = 1024, literal_pool_depth = 32, thread_count = 8):
    thread_data_memory_depth = memory_depth - literal_pool_depth;
    offsets = [(thread * (thread_data_memory_depth / 8)) + literal_pool_depth for thread in range(0,thread_count)]
    return offsets

# We don't have programmed offsets, so we can't modify them to reach a
# literal pool, I/O or H mem. For now, the tesbench will have to run
# "blind", with private data, and we'll check it's internal state for
# correct operation.

offsets = partition_data_memory(literal_pool_depth = 0)

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
    # Peel out zeroth iteration for naming
    A.ALIGN(offsets[0])
    A.L(0),                 A.N("zero")
    A.L(1),                 A.N("one")
    A.L(3),                 A.N("three")
    A.L(2**(A.width-1)),    A.N("right_shift_1")
    A.L(0),                 A.N("temp")
    # All other iterations implicitly use the same names via offsets
    for thread in range(1,8):
        A.ALIGN(offsets[thread])
        A.L(0)             
        A.L(1)             
        A.L(3)             
        A.L(2**(A.width-1))
        A.L(0)             
    return A

def assemble_B():
    B = empty["B"]
    B.file_name = bench_name
    B.add_port_pair("READ_PORT", "WRITE_PORT", mem_map["B"]["IO_base"])

    seeds = [27, 47, 67, 87, 107, 127, 234, 335]

    # Peel out zeroth iteration for naming
    B.ALIGN(offsets[0])
    B.L(0),         B.N("zero")
    B.L(seeds[0]),  B.N("seed")
    # All other iterations implicitly use the same names via offsets
    for thread,seed in zip(range(1,8),seeds[1:]):
        B.ALIGN(offsets[thread])
        B.L(0)
        B.L(seed)
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name
    # Align threads 1-7 with thread 0
    I.NOP()

    I.ALIGN(PC.get_pc("THREAD0_START"))
    # ECL XXX Flush pipeline of inital zeroes
    I.NOP()
    I.NOP()
    I.NOP()
    I.NOP()
    I.NOP()
    I.NOP()
    I.NOP()
    I.NOP()
    I.NOP()
    I.NOP()

    # Is the seed odd?
    I.I(AND, (A,"temp"), (A,"one"), (B,"seed")),   I.N("hailstone")
    I.I(JNZ, 0, (A,"temp"), 0),                    I.N("odd")
    # Even: seed = seed / 2
    I.I(MHU, (B,"seed"), (A,"right_shift_1"), (B,"seed"))
    I.I(JMP, 0, 0, 0),                             I.N("output")
    # Odd: seed = (3 * seed) + 1
    I.I(MLS, (B,"seed"), (A,"three"), (B,"seed")), I.RD("odd")
    I.I(ADD, (B,"seed"), (A,"one"), (B,"seed"))
    # placeholder, as we are running "blind"
    I.NOP(),                                     I.RD("output")
    # I.I(ADD, (A,"WRITE_PORT"), 0, (B,seed)),   I.RD("output")
    #I.I(ADD, (B,"WRITE_PORT"), 0, (B,seed))
    I.I(JMP, "hailstone", 0, 0)
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

def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I(PC, A, B)
    ADO, BDO, DDO = assemble_XDO()
    APO, BPO, DPO = assemble_XPO()
    AIN, BIN, DIN = assemble_XIN()
    hailstone = {"PC":PC, "A":A, "B":B, "I":I, 
                 "ADO":ADO, "BDO":BDO, "DDO":DDO,
                 "APO":APO, "BPO":BPO, "DPO":DPO,
                 "AIN":AIN, "BIN":BIN, "DIN":DIN}
    return hailstone

def dump_all(hailstone):
    for memory in hailstone.values():
        memory.file_dump()

if __name__ == "__main__":
    hailstone = assemble_all()
    dump_all(hailstone)

