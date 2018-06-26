#! /usr/bin/python3

"""Assembles a hailstone benchmark/test using Assembler.py"""

from Assembler  import *
from pprint     import pprint

# Only for object initialization.
thread_count            = 8
memory_depth_words      = 1024
memory_width_bits       = 36
memory_shared_count     = 32
# Must fit in shared, and match hardware
memoru_indirect_base    = 24
memory_indirect_count   = 4
memory_io_base          = 28
memory_io_count         = 4

T = Threads(thread_count)

DO = Default_Offset("DO.mem", memory_depth_words, memory_shared_count, T)

MM = Memory_Map(memory_depth_words, memory_width_bits, memory_shared_count, memory_indirect_base, memory_indirect_count, memory_io_base, memory_io_count, DO)

A = Data_Memory(memory_depth_words, memory_width_bits, "A.mem", MEMMAP.a, T)
B = Data_Memory(memory_depth_words, memory_width_bits, "B.mem", MEMMAP.b, T)

OD = Opcode_Decoder("OD.mem", T)

I = Instruction_Memory(memory_depth_words, memory_width_bits, "I.mem", MEMMAP.i, A, B, OD, T)

BD = Branch_Detector(A, B, I, T)

PC      = Program_Counter("PC.mem", T)
PC_prev = Program_Counter("PC_prev.mem", T)

PO_A  = Programmed_Offset("PO_A.mem",  A, Programmed_Offset.po_offset_bits_A,  T)
PO_B  = Programmed_Offset("PO_B.mem",  B, Programmed_Offset.po_offset_bits_B,  T)
PO_DA = Programmed_Offset("PO_DA.mem", A, Programmed_Offset.po_offset_bits_DA, T)
PO_DB = Programmed_Offset("PO_DB.mem", B, Programmed_Offset.po_offset_bits_DB, T)

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# Quick test

initializable_memories = [A,B,I,OD,DO,PO_A,PO_B,PO_DA,PO_DB,PC,PC_prev]

def dump_all(mem_obj_list):
    for mem in mem_obj_list:
        mem.file_dump()

def init_ISA():
    OD.define("NOP",     ALU.split_no, ALU.shift_none,           Dyadic.always_zero, ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define("ADD",     ALU.split_no, ALU.shift_none,           Dyadic.b,           ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define("SUB",     ALU.split_no, ALU.shift_none,           Dyadic.b,           ALU.addsub_a_minus_b,   ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define("PSR",     ALU.split_no, ALU.shift_none,           Dyadic.a,           ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_one,  Dyadic.always_zero, ALU.select_r)
    OD.define("ADD*2",   ALU.split_no, ALU.shift_left,           Dyadic.b,           ALU.addsub_a_minus_b,   ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define("ADD/2",   ALU.split_no, ALU.shift_right_signed,   Dyadic.b,           ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define("ADD/2U",  ALU.split_no, ALU.shift_right,          Dyadic.b,           ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    for thread in T.all:
        T.set(thread)
        OD.load("NOP",    0)
        OD.load("ADD",    1)
        OD.load("SUB",    2)
        OD.load("ADD*2",  3)
        OD.load("ADD/2",  4)
        OD.load("ADD/2U", 5)
        OD.load("PSR",    6)

def init_BD():
    # Jump always
    BD.condition("JMP", Branch.A_flag_negative, Branch.B_flag_lessthan, Dyadic.always_one)
    # Jump on Branch Sentinel A match
    BD.condition("BSA", Branch.A_flag_sentinel, Branch.B_flag_lessthan, Dyadic.a)
    # Jump on Counter reaching Zero (not running)
    BD.condition("CTZ", Branch.A_flag_negative, Branch.B_flag_counter, Dyadic.not_b)

def init_A():
    for thread in T.all:
        T.set(thread)
        A.align(0)
        A.lit(0), A.loc("zeroA")

        A.align(MEMMAP.pool[0])
        A.lit(1), A.loc("oneA")

        A.align(MEMMAP.indirect[0])
        A.lit(0), A.loc("seed_ptrA")

        A.align(MEMMAP.normal)
        A.lit(0), A.loc("seedA")
        A.data([11]*6, "seeds")

def init_B():
    for thread in T.all:
        T.set(thread)
        B.align(0)
        B.lit(0), B.loc("zeroB")

        B.align(MEMMAP.pool[0])
        B.lit(1),           B.loc("oneB")
        B.lit(6),           B.loc("sixB")
        B.lit(0xFFFFFFFFE), B.loc("all_but_LSB_mask")
        B.lit(0),           B.loc("restart_test")
        B.lit(0),           B.loc("next_test")
        B.lit(0),           B.loc("even_test")
        B.lit(0),           B.loc("output_test")

        B.align(MEMMAP.normal)
        B.lit(0),                                B.loc("nextseedB")
        B.lit(PO_A.gen_read_po(0, "seeds", 1)),  B.loc("seed_ptrA_init_read")
        B.lit(PO_DA.gen_read_po(0, "seeds", 1)), B.loc("seed_ptrA_init_write")

def init_PC():
    for thread in T.all:
        T.set(thread)
        PC.set(0)
        PC_prev.set(0)

def init_I():
    T.set(0)
    I.align(PC.start[0])

    I.simple("ADD", MEMMAP.bd[0],           "zeroA",        "restart_test"), BD.bt("restart")
    I.simple("ADD", MEMMAP.bc[0],           "zeroA",        "sixB")
    I.simple("ADD", MEMMAP.bd[2],           "zeroA",        "even_test"),
    I.simple("ADD", MEMMAP.bs1_sentinel[2], "zeroA",        "zeroB"),
    I.simple("ADD", MEMMAP.bs1_mask[2],     "zeroA",        "all_but_LSB_mask"),
    I.simple("ADD", MEMMAP.bd[3],           "zeroA",        "output_test"),
    I.simple("ADD", MEMMAP.a_po[0],         "zeroA",        "seed_ptrA_init_read")
    I.simple("ADD", MEMMAP.da_po[0],        "zeroA",        "seed_ptrA_init_write"),
    I.simple("ADD", MEMMAP.bd[1],           "zeroA",        "next_test"),

    #I.simple(0, "NOP", "zeroA",                "zeroA",        "zeroB")

    # Load x
    I.simple("ADD",     "seedA",        "seed_ptrA",     "zeroB"),      BD.bt("next_seed")

    # Odd case y = (3x+1)/2
    I.simple("ADD*2",   "nextseedB",    "seedA",        "zeroB"),       BD.br("BSA", "even_case", False, "even_test")    # y = (x+0)*2
    I.simple("ADD",     "nextseedB",    "seedA",        "nextseedB"),                                                    # y = (x+y)
    I.simple("ADD/2U",  "nextseedB",    "oneA",         "nextseedB"),   BD.br("JMP", "output", True, "output_test")      # y = (1+y)/2

    # Even case y = x/2
    I.simple("ADD/2U",  "nextseedB",    "seedA",        "zeroB"),       BD.bt("even_case")                               # y = (x+0)/2
    I.simple("NOP",     "zeroA",        "zeroA",        "zeroB")
    I.simple("NOP",     "zeroA",        "zeroA",        "zeroB")

    # Store y (replace x)
    I.simple("ADD",     "seed_ptrA",    "zeroA",        "nextseedB"),   BD.bt("output")
    I.simple("ADD",     MEMMAP.io[0],   "zeroA",        "nextseedB"),   BD.br("CTZ", "restart", None, "restart_test"), BD.br("JMP", "next_seed", None, "next_test")

#    I.align(PC.start[1])
#
#    I.align(PC.start[2])
#
#    I.align(PC.start[3])
#
#    I.align(PC.start[4])
#
#    I.align(PC.start[5])
#
#    I.align(PC.start[6])
#
#    I.align(PC.start[7])

    BD.resolve_forward_branches()

# ---------------------------------------------------------------------

if __name__ == "__main__":
    init_ISA()
    init_BD()
    init_A()
    init_B()
    init_PC()
    init_I()
    dump_all(initializable_memories)

