#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "FIR_Filter"
bench_file = "fir_filter"
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
    A.L(-25),               A.N("minus_25")
    A.L(10),                A.N("ten")
    # temporaries
    A.L(0),                 A.N("acc_temp")
    # FIR coefficients, 8-tap, moving average filter, 18.18 format
    A.L(1),           A.N("coefficient0")
    A.L(1),           A.N("coefficient1")
    A.L(1),           A.N("coefficient2")
    A.L(1),           A.N("coefficient3")
    A.L(1),           A.N("coefficient4")
    A.L(1),           A.N("coefficient5")
    A.L(1),           A.N("coefficient6")
    A.L(1),           A.N("coefficient7")
    # Output data
    A.L(-2)     # Guard value for debugging
    A.L(0),     A.N("output_array_top") # 100 elements, NOT including final guard (-1)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0)
    A.L(0),     A.N("output_array_bottom")
    A.L(-1)     # Guard value for debugging 
    # Placeholders for branch table entries
    A.L(0),                 A.N("br00")
    A.L(0),                 A.N("br01")
    A.L(0),                 A.N("br02")
    A.L(0),                 A.N("br03")
    return A

def assemble_B():
    B = empty["B"]
    B.file_name = bench_name
    B.P("B_IO", mem_map["B"]["IO_base"])
    B.P("array_top_pointer",      mem_map["B"]["PO_INC_base"],   write_addr = mem_map["H"]["PO_INC_base"])
    B.A(0)
    B.L(0)
    # Input buffer
    B.L(0),     B.N("buffer0")
    B.L(0),     B.N("buffer1")
    B.L(0),     B.N("buffer2")
    B.L(0),     B.N("buffer3")
    B.L(0),     B.N("buffer4")
    B.L(0),     B.N("buffer5")
    B.L(0),     B.N("buffer6")
    B.L(0),     B.N("buffer7")
    # temporaries
    B.L(0),     B.N("mul_temp")
    B.L(0),     B.N("array_cnt")
    # Input data
    B.L(100),   B.N("array_len")
    B.L(-2)     # Guard value for debugging
    B.L(0),     B.N("input_array_top") # 100 elements, NOT including final guard (-1)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(1023)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(1024)
    B.L(512 )
    B.L(256 )
    B.L(128 )
    B.L(64  )
    B.L(32  )
    B.L(16  )
    B.L(8   )
    B.L(4   )
    B.L(2   )
    B.L(1   )
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0)
    B.L(0),     B.N("input_array_bottom")
    B.L(-1)     # Guard value for debugging 
    # Placeholders for programmed offset
    B.L(0),     B.N("pointer_init")
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
    I.P("BTT0", None, write_addr = base_addr)
    I.P("BTT1", None, write_addr = base_addr + 1)
    I.P("BTT2", None, write_addr = base_addr + 2)
    I.P("BTT3", None, write_addr = base_addr + 3)

# "ideal" MIPS
# init:   ADD  INPUT,  INPUT_INIT,  0
#         ADD  OUTPUT, OUTPUT_INIT, 0
#         ADD  INPUT_CTR, INPUT_CTR_INIT, 0
# loop:   ADD  buffer7, buffer6, 0
#         ADD  buffer6, buffer5, 0
#         ADD  buffer5, buffer4, 0
#         ADD  buffer4, buffer3, 0
#         ADD  buffer3, buffer2, 0
#         ADD  buffer2, buffer1, 0
#         ADD  buffer1, buffer0, 0
#         LW   buffer0, INPUT
#         MUL  acc_temp, buffer7, coefficient7
#         MUL  mul_temp, buffer6, coefficient6
#         ADD  acc_temp, acc_temp, mul_temp
#         MUL  mul_temp, buffer5, coefficient5
#         ADD  acc_temp, acc_temp, mul_temp
#         MUL  mul_temp, buffer4, coefficient4
#         ADD  acc_temp, acc_temp, mul_temp
#         MUL  mul_temp, buffer3, coefficient3
#         ADD  acc_temp, acc_temp, mul_temp
#         MUL  mul_temp, buffer2, coefficient2
#         ADD  acc_temp, acc_temp, mul_temp
#         MUL  mul_temp, buffer1, coefficient1
#         ADD  acc_temp, acc_temp, mul_temp
#         MUL  mul_temp, buffer0, coefficient0
#         ADD  acc_temp, acc_temp, mul_temp
#         SW   acc_temp, OUTPUT
#         ADD  INPUT,  INPUT,  1
#         ADD  OUTPUT, OUTPUT, 1
#         ADD  INPUT_CTR, INPUT_CTR, -1
#         BEQZ init, INPUT_CTR
#         JMP  loop

# "ideal" MIPS-like equivalent 
#    # set branch entries
#    I.I(ADD, "BTT0", "br00", 0) #
#    I.I(ADD, "BTT1", "br01", 0) #
#    I.I(ADD, "BTT2", "br02", 0) #
#    I.I(ADD, "BTT3", "br03", 0) #
#    # Instruction to set indirect access
#    base_addr = mem_map["BPO"]["Origin"] 
#    I.I(ADD, base_addr,   0, "pointer_init"),               I.N("init")
#    I.NOP() # output pointer
#    I.I(ADD, "array_cnt", 0, "array_len")
#    I.I(ADD, "buffer7",   0, "buffer6"),                    I.N("loop")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
#    I.I(ADD, "array_cnt", "minus_one", "array_cnt")
#    I.NOP(),                                            I.JZE("init", None, "br00")
#    I.NOP(),                                            I.JMP("loop",       "br01")

# Experiment
# 8 runs over 100 input values, over 200,000 cycles
# Cycles: 185768 - 40 = 185728
# USeful Cycles: 185728 / 8 = 23216
# Cycles per run: 23216 / 8 = 2902
# Cycles per input: 2902 / 100 = 29.02

# PC Tally (REVISED)
#      1 1   # setup
#      1 2   # setup
#      1 3   # setup
#      1 4   # setup
#      9 5   # U
#      9 6   # U
#      9 7   # N
#    862 8   # U
#    862 9   # U
#    862 10  # U
#    862 11  # U
#    862 12  # U
#    862 13  # U
#    862 14  # U
#    861 15  # U
#    861 16  # U
#    861 17  # U
#    861 18  # U
#    861 19  # U
#    861 20  # U
#    861 21  # U
#    861 22  # U
#    861 23  # U
#    861 24  # U
#    861 25  # U
#    861 26  # U
#    861 27  # U
#    861 28  # U
#    861 29  # U
#    861 30  # U
#    861 31  # U
#    861 32  # U
#    861 33  # U
#    861 34  # N
#    861 35  # N
#    853 36  # N
#
# Useful:     22411
# Not Useful:  2584
# Total:      24995
# ALU Efficiency: 22411 / 24995 = 0.89661

# Optimized
#    # set branch entries
#    I.I(ADD, "BTT0", "br00", 0) #
#    I.I(ADD, "BTT1", "br01", 0) #
#    I.I(ADD, "BTT2", "br02", 0) #
#    I.I(ADD, "BTT3", "br03", 0) #
#    # Instruction to set indirect access
#    base_addr = mem_map["BPO"]["Origin"] 
#    I.I(ADD, base_addr,   0, "pointer_init"),               I.N("init")
#    I.I(ADD, "array_cnt", 0, "array_len")
#    I.I(ADD, "buffer7",   0, "buffer6"),                    I.N("loop")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_cnt", "minus_one", "array_cnt")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0), I.JZE("init", None, "br00"), I.JNZ("loop", None, "br01")

# Experiment
# 9 runs over 100 input values, 200,000 cycles
# Cycles: 180184 - 40 = 180144
# Useful Cycles = 180144 / 8 = 22518
# Cycles per run: 22518 / 9 = 2502
# Cycles per input: 2502 / 100 = 25.02

# Speedup vs. MIPS: 2902 / 2502 = 1.1599

# PC Tally:
#      1 1   # setup
#      1 2   # setup
#      1 3   # setup
#      1 4   # setup
#     10 5   # U
#     10 6   # N
#    999 7   # U
#    999 8   # U
#    999 9   # U
#    999 10  # U
#    999 11  # U
#    999 12  # U
#    999 13  # U 
#    999 14  # U
#    999 15  # U
#    999 16  # U
#    999 17  # U
#    999 18  # U
#    999 19  # U
#    999 20  # U
#    999 21  # U
#    999 22  # U
#    999 23  # U
#    999 24  # U
#    999 25  # U
#    999 26  # U
#    999 27  # U
#    999 28  # U
#    999 29  # U
#    999 30  # N
#    999 31  # U
#
# Useful:     23986
# Not Useful:  1009
# Total:      24995
# ALU Efficiency: 23986 / 24995 = 0.95963





# UNROLLED MIPS
#    # set branch entries
#    I.I(ADD, "BTT0", "br00", 0) #
#    I.I(ADD, "BTT1", "br01", 0) #
#    I.I(ADD, "BTT2", "br02", 0) #
#    I.I(ADD, "BTT3", "br03", 0) #
#    # Instruction to set indirect access
#    base_addr = mem_map["BPO"]["Origin"] 
#    I.I(ADD, base_addr,   0, "pointer_init"),               I.N("init")
#    I.NOP() # output pointer
#    I.I(ADD, "array_cnt", 0, "array_len")
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6"),                    I.N("loop")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "buffer7",   0, "buffer6")
#    I.I(ADD, "buffer6",   0, "buffer5")
#    I.I(ADD, "buffer5",   0, "buffer4")
#    I.I(ADD, "buffer4",   0, "buffer3")
#    I.I(ADD, "buffer3",   0, "buffer2")
#    I.I(ADD, "buffer2",   0, "buffer1")
#    I.I(ADD, "buffer1",   0, "buffer0")
#    I.I(ADD, "buffer0",   0, "array_top_pointer")
#    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
#    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
#    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
#    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#    I.NOP() # input pointer
#    I.NOP() # output pointer
##################################################################################################
#    I.I(ADD, "array_cnt", "minus_25", "array_cnt")
#    I.NOP(),                                            I.JZE("init", None, "br00")
#    I.NOP(),                                            I.JMP("loop",       "br01")

# Experiment
# 9 runs over 100 input values, 200,000 cycles
# Cycles: 188248 - 40 = 188208
# Useful cycles: 188208 / 8 = 23526
# Cycles per pass: 23526 / 9 = 2614
# Cycles per input: 2614 / 100 = 26.14

# PC Tally
# All useful except:
# loop counter init: 10 cycles
# loop counter decr: 38 cycles
# branch to init:    38 cycles
# Total not useful: 10 + 38 + 38 = 86
# Useful: 23526 - 86 = 23440
# Ratio: 23440 / 23526 = 0.99634






# UNROLLED Optimized
    # set branch entries
    I.I(ADD, "BTT0", "br00", 0) #
    I.I(ADD, "BTT1", "br01", 0) #
    I.I(ADD, "BTT2", "br02", 0) #
    I.I(ADD, "BTT3", "br03", 0) #
    # Instruction to set indirect access
    base_addr = mem_map["BPO"]["Origin"] 
    I.I(ADD, base_addr,   0, "pointer_init"),               I.N("init")
    I.I(ADD, "array_cnt", 0, "array_len")
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6"),                    I.N("loop")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_top_pointer", "acc_temp", 0)
#################################################################################################
    I.I(ADD, "buffer7",   0, "buffer6")
    I.I(ADD, "buffer6",   0, "buffer5")
    I.I(ADD, "buffer5",   0, "buffer4")
    I.I(ADD, "buffer4",   0, "buffer3")
    I.I(ADD, "buffer3",   0, "buffer2")
    I.I(ADD, "buffer2",   0, "buffer1")
    I.I(ADD, "buffer1",   0, "buffer0")
    I.I(ADD, "buffer0",   0, "array_top_pointer")
    I.I(MLS, "acc_temp", "coefficient7", "buffer7")
    I.I(MLS, "mul_temp", "coefficient6", "buffer6")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient5", "buffer5")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient4", "buffer4")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient3", "buffer3")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient2", "buffer2")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient1", "buffer1")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(MLS, "mul_temp", "coefficient0", "buffer0")
    I.I(ADD, "acc_temp", "acc_temp", "mul_temp")
    I.I(ADD, "array_cnt", "minus_25", "array_cnt")
#################################################################################################
    I.I(ADD, "array_top_pointer", "acc_temp", 0), I.JZE("init", None, "br00"), I.JNZ("loop", None, "br01")

# Experiment
# 10 runs over 100 input values, 200,000 cycles
# Cycles: 192520 - 40 = 192480
# Useful cycles: 192480 / 8 = 24060
# Cycles per pass: 24060 / 10 = 2406
# Cycles per input: 2406 / 100 = 24.06

# PC Tally
# All useful except:
# loop counter init: 11 cycles
# loop counter decr: 41 cycles
# Total not useful: 11 + 41 = 52
# Useful: 24060 - 52 = 24008
# Ratio: 24008 / 24060 = 0.99784



    I.resolve_forward_jumps()

    # Set programmed offsets
    read_PO  = (mem_map["B"]["Depth"] - mem_map["B"]["PO_INC_base"] + B.R("input_array_top")) & 0x3FF
    write_PO = (mem_map["H"]["Origin"] + mem_map["H"]["Depth"] - mem_map["H"]["PO_INC_base"] + A.W("output_array_top")) & 0xFFF
    PO = (1 << 34) | (1 << 32) | (write_PO << 20) | read_PO
    B.A(B.R("pointer_init"))
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

