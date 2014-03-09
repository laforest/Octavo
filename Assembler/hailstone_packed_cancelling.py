#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "Hailstone_Packed_Cancelling"
bench_file = "hailstone_packed_cancelling"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

def partition_data_memory(memory_depth = 1024, literal_pool_depth = 32, thread_count = 8):
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
    # Shared read-only literal pool
    A.ALIGN(0)
    A.L(0),                 A.N("zero")
    A.L(1),                 A.N("one")
    A.L(3),                 A.N("three")
    A.L(2**(A.width-1)),    A.N("right_shift_1")
    # Thread Private Data
    for thread in range(0,8):
        A.ALIGN(offsets[thread])
        A.L(0), A.N("temp_{}".format(thread))
        # Placeholders for branch table entries
        A.L(0), A.N("jmp_odd_{}".format(thread))
        A.L(0), A.N("jmp_out_{}".format(thread))
        A.L(0), A.N("jmp_hai_{}".format(thread))
    return A

def assemble_B():
    B = empty["B"]
    B.file_name = bench_name
    B.add_port_pair("READ_PORT", "WRITE_PORT", mem_map["B"]["IO_base"])
    seeds = [27, 47, 67, 87, 107, 127, 234, 335]
    for thread in range(0,8):
        B.ALIGN(offsets[thread])
        B.L(seeds[thread]),  B.N("seed_{}".format(thread))
    return B

def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name
    # Align threads 1-7 with thread 0
    #I.NOP()

#    for thread in range(0,8):
#        I.ALIGN(PC.get_pc("THREAD{}_START".format(thread)))
#        # Is the seed odd?
#        I.I(AND, (A,"temp_{}".format(thread)), (A,"one"), (B,"seed_{}".format(thread))),    I.N("hailstone_{}".format(thread))
#        I.I(JNZ, 0, (A,"temp_{}".format(thread)), 0),                                       I.N("odd_{}".format(thread))
#        # Even: seed = seed / 2
#        I.I(MHU, (B,"seed_{}".format(thread)), (A,"right_shift_1"), (B,"seed_{}".format(thread)))
#        I.I(JMP, 0, 0, 0),                                                                  I.N("output_{}".format(thread))
#        # Odd: seed = (3 * seed) + 1
#        I.I(MLS, (B,"seed_{}".format(thread)), (A,"three"), (B,"seed_{}".format(thread))),  I.RD("odd_{}".format(thread))
#        I.I(ADD, (B,"seed_{}".format(thread)), (A,"one"), (B,"seed_{}".format(thread)))
#        I.I(ADD, (A,"WRITE_PORT"), 0, (B,"seed_{}".format(thread))),                        I.RD("output_{}".format(thread))
#        I.I(ADD, (B,"WRITE_PORT"), 0, (B,"seed_{}".format(thread)))
#        I.I(JMP, "hailstone", 0, 0)

    for thread in range(0,8):
        I.ALIGN(PC.get_pc("THREAD{}_START".format(thread)))

        # Delay threads 1-7 to align with thread 0, so thread 0 ends up first in the cycle.
        # At least, until an I/O stall scrambles the thread phase.:
        if (thread != 0):
            I.NOP()

        # Instructions to fill branch table
        base_addr = mem_map["BO"]["Origin"] + thread
        I.I(ADD, base_addr     , (A,"jmp_odd_{}".format(thread)), 0)
        I.I(ADD, base_addr + 8 , (A,"jmp_out_{}".format(thread)), 0)
        I.I(ADD, base_addr + 16, (A,"jmp_hai_{}".format(thread)), 0)

        # Is the seed odd?
        I.I(AND, (A,"temp_{}".format(thread)), (A,"one"), (B,"seed_{}".format(thread))),            I.N("hai_dest_{}".format(thread))
        # I.NOP(),                                                                                    I.N("odd_orig_{}".format(thread))
        # Hoisted from destination, Predict Taken
        I.I(MLS, (B,"seed_{}".format(thread)), (A,"three"), (B,"seed_{}".format(thread))),          I.N("odd_orig_{}".format(thread))
        

        # Even: seed = seed / 2
        I.I(MHU, (B,"seed_{}".format(thread)), (A,"right_shift_1"), (B,"seed_{}".format(thread))),  I.N("out_orig_{}".format(thread))

        # Odd: seed = (3 * seed) + 1
        # I.I(MLS, (B,"seed_{}".format(thread)), (A,"three"), (B,"seed_{}".format(thread))),          I.N("odd_dest_{}".format(thread))
        # I.I(ADD, (B,"seed_{}".format(thread)), (A,"one"), (B,"seed_{}".format(thread)))
        # Hoisted to branch origin
        I.I(ADD, (B,"seed_{}".format(thread)), (A,"one"), (B,"seed_{}".format(thread))),            I.N("odd_dest_{}".format(thread))

        I.I(ADD, (A,"WRITE_PORT"), 0, (B,"seed_{}".format(thread))),                                I.N("out_dest_{}".format(thread))
        I.I(ADD, (B,"WRITE_PORT"), 0, (B,"seed_{}".format(thread))),                                I.N("hai_orig_{}".format(thread))

        # Now lets fill those branch table values
        origin      = I.names["odd_orig_{}".format(thread)]
        destination = I.names["odd_dest_{}".format(thread)] << 10
        condition   = JNZ                                   << 20
        prediction  = 1                                     << 23 # Predict Taken
        prediction_enable = 1                               << 24
        A.ALIGN(A.names["jmp_odd_{}".format(thread)])
        A.L(prediction_enable | prediction | condition | destination | origin)

        origin      = I.names["out_orig_{}".format(thread)]
        destination = I.names["out_dest_{}".format(thread)] << 10
        condition   = JMP                                   << 20
        prediction  = 0                                     << 23
        prediction_enable = 0                               << 24
        A.ALIGN(A.names["jmp_out_{}".format(thread)])
        A.L(prediction_enable | prediction | condition | destination | origin)

        origin      = I.names["hai_orig_{}".format(thread)]
        destination = I.names["hai_dest_{}".format(thread)] << 10
        condition   = JMP                                   << 20
        prediction  = 0                                     << 23
        prediction_enable = 0                               << 24
        A.ALIGN(A.names["jmp_hai_{}".format(thread)])
        A.L(prediction_enable | prediction | condition | destination | origin)

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

