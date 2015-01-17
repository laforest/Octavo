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
    A.L(0),                 A.N("jmp4")
    A.L(0),                 A.N("jmp5")
    A.L(0),                 A.N("jmp6")
    A.L(0),                 A.N("jmp7")
    A.L(0),                 A.N("jmp8")
    A.L(0),                 A.N("jmp9")
    A.L(0),                 A.N("jmp10")
    A.L(0),                 A.N("jmp11")
    A.L(0),                 A.N("jmp12")
    A.L(0),                 A.N("jmp13")
    A.L(0),                 A.N("jmp14")
    A.L(0),                 A.N("jmp15")
    A.L(0),                 A.N("jmp16")
    A.L(0),                 A.N("jmp17")
    A.L(0),                 A.N("jmp18")
    A.L(0),                 A.N("jmp19")
    A.L(0),                 A.N("jmp20")
    A.L(0),                 A.N("jmp21")
    A.L(0),                 A.N("jmp22")
    A.L(0),                 A.N("jmp23")
    A.L(0),                 A.N("jmp24")
    A.L(0),                 A.N("jmp25")
    A.L(0),                 A.N("jmp26")
    A.L(0),                 A.N("jmp27")
    A.L(0),                 A.N("jmp28")
    A.L(0),                 A.N("jmp29")
    A.L(0),                 A.N("jmp30")
    A.L(0),                 A.N("jmp31")
    A.L(0),                 A.N("jmp32")
    A.L(0),                 A.N("jmp33")
    A.L(0),                 A.N("jmp34")
    A.L(0),                 A.N("jmp35")
    A.L(0),                 A.N("jmp36")
    A.L(0),                 A.N("jmp37")
    A.L(0),                 A.N("jmp38")
    A.L(0),                 A.N("jmp39")
    A.L(0),                 A.N("jmp40")
    A.L(0),                 A.N("jmp41")
    A.L(0),                 A.N("jmp42")
    A.L(0),                 A.N("jmp43")
    A.L(0),                 A.N("jmp44")
    A.L(0),                 A.N("jmp45")
    A.L(0),                 A.N("jmp46")
    A.L(0),                 A.N("jmp47")
    A.L(0),                 A.N("jmp48")
    A.L(0),                 A.N("jmp49")
    A.L(0),                 A.N("jmp50")
    A.L(0),                 A.N("jmp51")
    A.L(0),                 A.N("jmp52")
    A.L(0),                 A.N("jmp53")
    A.L(0),                 A.N("jmp54")
    A.L(0),                 A.N("jmp55")
    A.L(0),                 A.N("jmp56")
    A.L(0),                 A.N("jmp57")
    A.L(0),                 A.N("jmp58")
    A.L(0),                 A.N("jmp59")
    A.L(0),                 A.N("jmp60")
    A.L(0),                 A.N("jmp61")
    A.L(0),                 A.N("jmp62")
    A.L(0),                 A.N("jmp63")
    A.L(0),                 A.N("jmp64")
    A.L(0),                 A.N("jmp65")
    A.L(0),                 A.N("jmp66")
    A.L(0),                 A.N("jmp67")
    A.L(0),                 A.N("jmp68")
    A.L(0),                 A.N("jmp69")
    A.L(0),                 A.N("jmp70")
    A.L(0),                 A.N("jmp71")
    A.L(0),                 A.N("jmp72")
    A.L(0),                 A.N("jmp73")
    A.L(0),                 A.N("jmp74")
    A.L(0),                 A.N("jmp75")
    A.L(0),                 A.N("jmp76")
    A.L(0),                 A.N("jmp77")
    A.L(0),                 A.N("jmp78")
    A.L(0),                 A.N("jmp79")
    A.L(0),                 A.N("jmp80")
    A.L(0),                 A.N("jmp81")
    A.L(0),                 A.N("jmp82")
    A.L(0),                 A.N("jmp83")
    A.L(0),                 A.N("jmp84")
    A.L(0),                 A.N("jmp85")
    A.L(0),                 A.N("jmp86")
    A.L(0),                 A.N("jmp87")
    A.L(0),                 A.N("jmp88")
    A.L(0),                 A.N("jmp89")
    A.L(0),                 A.N("jmp90")
    A.L(0),                 A.N("jmp91")
    A.L(0),                 A.N("jmp92")
    A.L(0),                 A.N("jmp93")
    A.L(0),                 A.N("jmp94")
    A.L(0),                 A.N("jmp95")
    A.L(0),                 A.N("jmp96")
    A.L(0),                 A.N("jmp97")
    A.L(0),                 A.N("jmp98")
    A.L(0),                 A.N("jmp99")
    A.L(0),                 A.N("jmp100")
    A.L(0),                 A.N("jmp101")
    A.L(0),                 A.N("jmp102")
    A.L(0),                 A.N("jmp103")
    A.L(0),                 A.N("jmp104")
    A.L(0),                 A.N("jmp105")
    A.L(0),                 A.N("jmp106")
    A.L(0),                 A.N("jmp107")
    A.L(0),                 A.N("jmp108")
    A.L(0),                 A.N("jmp109")
    A.L(0),                 A.N("jmp110")
    A.L(0),                 A.N("jmp111")
    A.L(0),                 A.N("jmp112")
    A.L(0),                 A.N("jmp113")
    A.L(0),                 A.N("jmp114")
    A.L(0),                 A.N("jmp115")
    A.L(0),                 A.N("jmp116")
    A.L(0),                 A.N("jmp117")
    A.L(0),                 A.N("jmp118")
    A.L(0),                 A.N("jmp119")
    A.L(0),                 A.N("jmp120")
    A.L(0),                 A.N("jmp121")
    A.L(0),                 A.N("jmp122")
    A.L(0),                 A.N("jmp123")
    A.L(0),                 A.N("jmp124")
    A.L(0),                 A.N("jmp125")
    A.L(0),                 A.N("jmp126")
    A.L(0),                 A.N("jmp127")
    A.L(0),                 A.N("jmp128")
    A.L(0),                 A.N("jmp129")
    A.L(0),                 A.N("jmp130")
    A.L(0),                 A.N("jmp131")
    A.L(0),                 A.N("jmp132")
    A.L(0),                 A.N("jmp133")
    A.L(0),                 A.N("jmp134")
    A.L(0),                 A.N("jmp135")
    A.L(0),                 A.N("jmp136")
    A.L(0),                 A.N("jmp137")
    A.L(0),                 A.N("jmp138")
    A.L(0),                 A.N("jmp139")
    A.L(0),                 A.N("jmp140")
    A.L(0),                 A.N("jmp141")
    A.L(0),                 A.N("jmp142")
    A.L(0),                 A.N("jmp143")
    A.L(0),                 A.N("jmp144")
    A.L(0),                 A.N("jmp145")
    A.L(0),                 A.N("jmp146")
    A.L(0),                 A.N("jmp147")
    A.L(0),                 A.N("jmp148")
    A.L(0),                 A.N("jmp149")
    A.L(0),                 A.N("jmp150")
    A.L(0),                 A.N("jmp151")
    A.L(0),                 A.N("jmp152")
    A.L(0),                 A.N("jmp153")
    A.L(0),                 A.N("jmp154")
    A.L(0),                 A.N("jmp155")
    A.L(0),                 A.N("jmp156")
    A.L(0),                 A.N("jmp157")
    A.L(0),                 A.N("jmp158")
    A.L(0),                 A.N("jmp159")
    A.L(0),                 A.N("jmp160")
    A.L(0),                 A.N("jmp161")
    A.L(0),                 A.N("jmp162")
    A.L(0),                 A.N("jmp163")
    A.L(0),                 A.N("jmp164")
    A.L(0),                 A.N("jmp165")
    A.L(0),                 A.N("jmp166")
    A.L(0),                 A.N("jmp167")
    A.L(0),                 A.N("jmp168")
    A.L(0),                 A.N("jmp169")
    A.L(0),                 A.N("jmp170")
    A.L(0),                 A.N("jmp171")
    A.L(0),                 A.N("jmp172")
    A.L(0),                 A.N("jmp173")
    A.L(0),                 A.N("jmp174")
    A.L(0),                 A.N("jmp175")
    A.L(0),                 A.N("jmp176")
    A.L(0),                 A.N("jmp177")
    A.L(0),                 A.N("jmp178")
    A.L(0),                 A.N("jmp179")
    A.L(0),                 A.N("jmp180")
    A.L(0),                 A.N("jmp181")
    A.L(0),                 A.N("jmp182")
    A.L(0),                 A.N("jmp183")
    A.L(0),                 A.N("jmp184")
    A.L(0),                 A.N("jmp185")
    A.L(0),                 A.N("jmp186")
    A.L(0),                 A.N("jmp187")
    A.L(0),                 A.N("jmp188")
    A.L(0),                 A.N("jmp189")
    A.L(0),                 A.N("jmp190")
    A.L(0),                 A.N("jmp191")
    A.L(0),                 A.N("jmp192")
    A.L(0),                 A.N("jmp193")
    A.L(0),                 A.N("jmp194")
    A.L(0),                 A.N("jmp195")
    A.L(0),                 A.N("jmp196")
    A.L(0),                 A.N("jmp197")
    A.L(0),                 A.N("jmp198")
    A.L(0),                 A.N("jmp199")
    A.L(0),                 A.N("jmp200")
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

    base_addr = mem_map["BO"]["Origin"]
    depth     = mem_map["BO"]["Depth"]
    I.P("BTM0", None, write_addr = base_addr)
    I.P("BTM1", None, write_addr = base_addr + 1)
    I.P("BTM2", None, write_addr = base_addr + 2)
    I.P("BTM3", None, write_addr = base_addr + 3)

    # Instructions to fill branch table
    I.I(ADD, "BTM0",               "jmp0", 0) # branch to even
    I.I(ADD, "BTM1",               "jmp0", 0) # branch to output
    I.I(ADD, "BTM2",               "jmp0", 0)
    I.I(ADD, "BTM3",               "jmp200", 0) # cached branch to init

    # Instruction to set indirect access
    base_addr = mem_map["BPO"]["Origin"] 
    I.I(ADD, base_addr,     0, "seed_pointer_init"),    I.N("init")                 # init:     ADD     seed_pointer, seed_pointer_init, 0
    # Like all control memory writes: has a RAW latency on 1 thread cycle.
    #I.NOP()                                                                         # !!!
    I.I(ADD, "BTM0", "jmp0", 0)                        

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
#
# Experiment:
# Code size: 14 instructions
# 25 passes over 100 elements inside 200,000 simulation cycles
# Cycles: 194072 - 40 = 194032
# Useful cycles: 194032 / 8 = 24254
# Cycles per pass: 24254 / 25 = 970.16
# Cycles per output: 970.16 / 100 = 9.7016
#
# PC Tally: (Revised)
#      1 1   # setup
#      1 2   # setup
#      1 3   # setup
#      1 4   # setup
#     26 5   # N U
#     26 6   # N
#   2601 7   # U
#   2601 8   # N
#   2576 9   # U
#   2576 10  # N
#    856 11  # U
#    856 12  # U
#    856 13  # N
#   1720 14  # U
#   2576 15  # U
#   2575 16  # N U
#   2575 17  # U 
#   2575 18  # N
#
# Useful:         26 + 2601 + 2576 + 856 + 856 + 1720 + 2576 + 2575 + 2575 = 16361
# Not Useful:     26 + 2601 + 856 + 2576 + 2575 = 8634
# Total:                                                         
# ALU Efficiency: 16361 / 24995                                = 0.65457



# Overhead Unrolled
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp1", 0),                        I.JZE("even0", None, "jmp0")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output0",     "jmp1")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even0")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output0")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp2", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp3", 0),                        I.JZE("even1", None, "jmp2")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output1",     "jmp3")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even1")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output1")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp4", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp5", 0),                        I.JZE("even2", None, "jmp4")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output2",     "jmp5")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even2")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output2")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp6", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp7", 0),                        I.JZE("even3", None, "jmp6")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output3",     "jmp7")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even3")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output3")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp8", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp9", 0),                        I.JZE("even4", None, "jmp8")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output4",     "jmp9")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even4")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output4")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp10", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp11", 0),                        I.JZE("even5", None, "jmp10")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output5",     "jmp11")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even5")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output5")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp12", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp13", 0),                        I.JZE("even6", None, "jmp12")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output6",     "jmp13")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even6")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output6")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp14", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp15", 0),                        I.JZE("even7", None, "jmp14")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output7",     "jmp15")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even7")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output7")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp16", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp17", 0),                        I.JZE("even8", None, "jmp16")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output8",     "jmp17")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even8")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output8")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp18", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp19", 0),                        I.JZE("even9", None, "jmp18")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output9",     "jmp19")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even9")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output9")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp20", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp21", 0),                        I.JZE("even10", None, "jmp20")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output10",     "jmp21")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even10")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output10")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp22", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp23", 0),                        I.JZE("even11", None, "jmp22")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output11",     "jmp23")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even11")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output11")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp24", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp25", 0),                        I.JZE("even12", None, "jmp24")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output12",     "jmp25")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even12")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output12")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp26", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp27", 0),                        I.JZE("even13", None, "jmp26")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output13",     "jmp27")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even13")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output13")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp28", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp29", 0),                        I.JZE("even14", None, "jmp28")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output14",     "jmp29")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even14")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output14")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp30", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp31", 0),                        I.JZE("even15", None, "jmp30")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output15",     "jmp31")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even15")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output15")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp32", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp33", 0),                        I.JZE("even16", None, "jmp32")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output16",     "jmp33")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even16")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output16")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp34", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp35", 0),                        I.JZE("even17", None, "jmp34")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output17",     "jmp35")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even17")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output17")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp36", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp37", 0),                        I.JZE("even18", None, "jmp36")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output18",     "jmp37")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even18")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output18")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp38", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp39", 0),                        I.JZE("even19", None, "jmp38")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output19",     "jmp39")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even19")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output19")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp40", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp41", 0),                        I.JZE("even20", None, "jmp40")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output20",     "jmp41")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even20")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output20")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp42", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp43", 0),                        I.JZE("even21", None, "jmp42")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output21",     "jmp43")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even21")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output21")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp44", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp45", 0),                        I.JZE("even22", None, "jmp44")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output22",     "jmp45")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even22")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output22")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp46", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp47", 0),                        I.JZE("even23", None, "jmp46")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output23",     "jmp47")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even23")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output23")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp48", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp49", 0),                        I.JZE("even24", None, "jmp48")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output24",     "jmp49")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even24")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output24")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp50", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp51", 0),                        I.JZE("even25", None, "jmp50")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output25",     "jmp51")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even25")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output25")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp52", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp53", 0),                        I.JZE("even26", None, "jmp52")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output26",     "jmp53")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even26")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output26")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp54", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp55", 0),                        I.JZE("even27", None, "jmp54")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output27",     "jmp55")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even27")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output27")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp56", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp57", 0),                        I.JZE("even28", None, "jmp56")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output28",     "jmp57")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even28")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output28")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp58", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp59", 0),                        I.JZE("even29", None, "jmp58")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output29",     "jmp59")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even29")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output29")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp60", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp61", 0),                        I.JZE("even30", None, "jmp60")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output30",     "jmp61")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even30")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output30")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp62", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp63", 0),                        I.JZE("even31", None, "jmp62")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output31",     "jmp63")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even31")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output31")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp64", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp65", 0),                        I.JZE("even32", None, "jmp64")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output32",     "jmp65")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even32")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output32")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp66", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp67", 0),                        I.JZE("even33", None, "jmp66")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output33",     "jmp67")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even33")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output33")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp68", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp69", 0),                        I.JZE("even34", None, "jmp68")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output34",     "jmp69")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even34")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output34")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp70", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp71", 0),                        I.JZE("even35", None, "jmp70")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output35",     "jmp71")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even35")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output35")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp72", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp73", 0),                        I.JZE("even36", None, "jmp72")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output36",     "jmp73")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even36")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output36")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp74", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp75", 0),                        I.JZE("even37", None, "jmp74")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output37",     "jmp75")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even37")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output37")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp76", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp77", 0),                        I.JZE("even38", None, "jmp76")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output38",     "jmp77")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even38")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output38")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp78", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp79", 0),                        I.JZE("even39", None, "jmp78")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output39",     "jmp79")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even39")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output39")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp80", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp81", 0),                        I.JZE("even40", None, "jmp80")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output40",     "jmp81")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even40")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output40")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp82", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp83", 0),                        I.JZE("even41", None, "jmp82")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output41",     "jmp83")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even41")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output41")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp84", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp85", 0),                        I.JZE("even42", None, "jmp84")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output42",     "jmp85")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even42")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output42")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp86", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp87", 0),                        I.JZE("even43", None, "jmp86")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output43",     "jmp87")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even43")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output43")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp88", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp89", 0),                        I.JZE("even44", None, "jmp88")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output44",     "jmp89")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even44")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output44")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp90", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp91", 0),                        I.JZE("even45", None, "jmp90")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output45",     "jmp91")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even45")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output45")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp92", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp93", 0),                        I.JZE("even46", None, "jmp92")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output46",     "jmp93")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even46")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output46")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp94", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp95", 0),                        I.JZE("even47", None, "jmp94")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output47",     "jmp95")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even47")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output47")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp96", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp97", 0),                        I.JZE("even48", None, "jmp96")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output48",     "jmp97")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even48")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output48")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp98", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp99", 0),                        I.JZE("even49", None, "jmp98")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output49",     "jmp99")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even49")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output49")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp100", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp101", 0),                        I.JZE("even50", None, "jmp100")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output50",     "jmp101")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even50")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output50")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp102", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp103", 0),                        I.JZE("even51", None, "jmp102")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output51",     "jmp103")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even51")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output51")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp104", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp105", 0),                        I.JZE("even52", None, "jmp104")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output52",     "jmp105")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even52")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output52")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp106", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp107", 0),                        I.JZE("even53", None, "jmp106")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output53",     "jmp107")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even53")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output53")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp108", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp109", 0),                        I.JZE("even54", None, "jmp108")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output54",     "jmp109")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even54")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output54")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp110", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp111", 0),                        I.JZE("even55", None, "jmp110")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output55",     "jmp111")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even55")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output55")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp112", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp113", 0),                        I.JZE("even56", None, "jmp112")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output56",     "jmp113")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even56")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output56")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp114", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp115", 0),                        I.JZE("even57", None, "jmp114")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output57",     "jmp115")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even57")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output57")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp116", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp117", 0),                        I.JZE("even58", None, "jmp116")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output58",     "jmp117")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even58")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output58")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp118", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp119", 0),                        I.JZE("even59", None, "jmp118")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output59",     "jmp119")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even59")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output59")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp120", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp121", 0),                        I.JZE("even60", None, "jmp120")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output60",     "jmp121")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even60")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output60")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp122", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp123", 0),                        I.JZE("even61", None, "jmp122")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output61",     "jmp123")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even61")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output61")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp124", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp125", 0),                        I.JZE("even62", None, "jmp124")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output62",     "jmp125")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even62")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output62")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp126", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp127", 0),                        I.JZE("even63", None, "jmp126")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output63",     "jmp127")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even63")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output63")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp128", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp129", 0),                        I.JZE("even64", None, "jmp128")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output64",     "jmp129")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even64")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output64")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp130", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp131", 0),                        I.JZE("even65", None, "jmp130")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output65",     "jmp131")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even65")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output65")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp132", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp133", 0),                        I.JZE("even66", None, "jmp132")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output66",     "jmp133")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even66")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output66")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp134", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp135", 0),                        I.JZE("even67", None, "jmp134")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output67",     "jmp135")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even67")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output67")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp136", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp137", 0),                        I.JZE("even68", None, "jmp136")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output68",     "jmp137")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even68")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output68")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp138", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp139", 0),                        I.JZE("even69", None, "jmp138")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output69",     "jmp139")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even69")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output69")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp140", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp141", 0),                        I.JZE("even70", None, "jmp140")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output70",     "jmp141")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even70")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output70")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp142", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp143", 0),                        I.JZE("even71", None, "jmp142")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output71",     "jmp143")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even71")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output71")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp144", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp145", 0),                        I.JZE("even72", None, "jmp144")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output72",     "jmp145")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even72")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output72")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp146", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp147", 0),                        I.JZE("even73", None, "jmp146")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output73",     "jmp147")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even73")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output73")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp148", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp149", 0),                        I.JZE("even74", None, "jmp148")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output74",     "jmp149")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even74")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output74")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp150", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp151", 0),                        I.JZE("even75", None, "jmp150")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output75",     "jmp151")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even75")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output75")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp152", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp153", 0),                        I.JZE("even76", None, "jmp152")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output76",     "jmp153")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even76")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output76")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp154", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp155", 0),                        I.JZE("even77", None, "jmp154")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output77",     "jmp155")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even77")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output77")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp156", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp157", 0),                        I.JZE("even78", None, "jmp156")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output78",     "jmp157")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even78")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output78")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp158", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp159", 0),                        I.JZE("even79", None, "jmp158")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output79",     "jmp159")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even79")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output79")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp160", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp161", 0),                        I.JZE("even80", None, "jmp160")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output80",     "jmp161")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even80")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output80")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp162", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp163", 0),                        I.JZE("even81", None, "jmp162")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output81",     "jmp163")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even81")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output81")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp164", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp165", 0),                        I.JZE("even82", None, "jmp164")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output82",     "jmp165")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even82")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output82")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp166", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp167", 0),                        I.JZE("even83", None, "jmp166")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output83",     "jmp167")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even83")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output83")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp168", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp169", 0),                        I.JZE("even84", None, "jmp168")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output84",     "jmp169")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even84")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output84")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp170", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp171", 0),                        I.JZE("even85", None, "jmp170")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output85",     "jmp171")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even85")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output85")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp172", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp173", 0),                        I.JZE("even86", None, "jmp172")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output86",     "jmp173")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even86")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output86")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp174", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp175", 0),                        I.JZE("even87", None, "jmp174")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output87",     "jmp175")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even87")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output87")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp176", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp177", 0),                        I.JZE("even88", None, "jmp176")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output88",     "jmp177")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even88")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output88")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp178", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp179", 0),                        I.JZE("even89", None, "jmp178")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output89",     "jmp179")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even89")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output89")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp180", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp181", 0),                        I.JZE("even90", None, "jmp180")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output90",     "jmp181")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even90")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output90")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp182", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp183", 0),                        I.JZE("even91", None, "jmp182")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output91",     "jmp183")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even91")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output91")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp184", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp185", 0),                        I.JZE("even92", None, "jmp184")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output92",     "jmp185")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even92")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output92")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp186", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp187", 0),                        I.JZE("even93", None, "jmp186")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output93",     "jmp187")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even93")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output93")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp188", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp189", 0),                        I.JZE("even94", None, "jmp188")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output94",     "jmp189")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even94")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output94")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp190", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp191", 0),                        I.JZE("even95", None, "jmp190")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output95",     "jmp191")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even95")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output95")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp192", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp193", 0),                        I.JZE("even96", None, "jmp192")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output96",     "jmp193")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even96")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output96")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp194", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp195", 0),                        I.JZE("even97", None, "jmp194")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output97",     "jmp195")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even97")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output97")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp196", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp197", 0),                        I.JZE("even98", None, "jmp196")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output98",     "jmp197")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even98")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output98")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp198", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT
#NMP##################################################################################################################################
    I.I(ADD, "temp", 0, "seed_pointer"),                                                # begin:    LW      temp, seed_pointer
    I.I(AND, "temp2", "one", "temp")                                                    #           AND     temp2, temp, 1
    I.I(ADD, "BTM1", "jmp199", 0),                        I.JZE("even99", None, "jmp198")    #           BEQ     even, temp2, 0
    I.I(MLS, "temp", "three", "temp")                                                   #           MULT    temp, temp, 3
    I.I(ADD, "temp", "one", "temp")                                                     #           ADDI    temp, temp, 1
    I.NOP(),                                            I.JMP("output99",     "jmp199")    #           JMP     output
    I.I(MHU, "temp", "right_shift_1", "temp"),          I.N("even99")                    # even:     SRA     temp, 1
    I.I(ADD, "seed_pointer", 0, "temp"),                I.N("output99")                  # output:   SW      temp, seed_pointer
    I.I(ADD, "BTM0", "jmp200", 0),                                                        #           ADD     seed_pointer, seed_pointer, 1
    I.I(ADD, "A_IO", 0, "temp")                                                         #           SW      temp, IO_PORT

    I.NOP(),                                            I.JMP("init", "jmp200")  #                JMP     init
#
# Experiment
# 32 passes over 100 elements inside 200,000 simulation cycles
# Cycles: 196888 - 56 = 196832
# Useful Cycles: 196832 / 8 = 24604
# Cycles per pass: 24604 / 32 = 768.88
# Cycles per output: 768.88 / 100 = 7.6888
#
# PC Tally:
# All instructions useful except:
# final JMP: 32
# init NOP: 32
# JZE for even: 32 * 100 = 3200
# JMP to output: avg. of 10.71 * 100 = 1071
# Not Useful: 32 + 32 + 3200 + 1071 = 4335
# Useful: 24604 - 4335 = 20269
# Ratio: 20269 / 24604 = 0.82381







# Efficient version
#    I.I(ADD, "temp", 0, "seed_pointer"),        I.N("hailstone")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even", False, "jmp0"), I.JNE("init", False, "jmp1")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output", "jmp2")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output")
#    I.I(ADD, "A_IO", 0, "temp"),                I.JMP("hailstone", "jmp3")
#
# Experiment:
# Code size: 8 instructions
# 49 passes over 100 elements inside 200,000 simulation cycles
# Cycles: 197608 - 40 = 197568
# Useful cycles: 197568 / 8 = 24696
# Cycles per pass: 24696 / 49 = 504.00
# Cycles per output: 504 / 100 = 5.04
#
# Speedup: 9.7016 / 5.04 = 1.92492 (or +48%)
# Code size ratio: 8 / 14 = 0.5714 (or -43%)
# But account for tables: 4 branch tables at 10+10+3+2 = 25 bits each = 100 bits, 1 PO table: 10+10+12+3 = 35 bits
# 135 bits / 36 bits per instruction = 3.75 instruction 
# 8 + 3.75 = 11.75, only 16% smaller at best. (table storage isn't perfectly efficient)
# or count storage words for initialization data: 8 + 4 + 1 = 13, so it basically breaks even.
#
# PC Tally (Revised)
#      1 1   # setup
#      1 2   # setup
#      1 3   # setup
#      1 4   # setup
#     50 5   # N U
#     50 6   # N
#   5009 7   # U
#   3378 8a  # U N (cancelled) 5009 - 1631 = 3378
#   1631 8b  # N U (executed)
#   1631 9   # U
#   3328 10  # U
#   4959 11  # U
#   4959 12  # U
#
# Useful:         50 + 5009 + 1631 + 1631 + 3328 + 4959 + 4959 = 21567
# Not Useful:     50 + 3378                                    = 3428
# Total:                                                         24995
# ALU Efficiency: 21567 / 24995                                = 0.86285






# Efficient Unrolled
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp0", 0)
#    I.I(ADD, "BTM1", "jmp1", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even0", False, "jmp0")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output0", "jmp1")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even0")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output0")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp2", 0)
#    I.I(ADD, "BTM1", "jmp3", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even1", False, "jmp2")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output1", "jmp3")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even1")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output1")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp4", 0)
#    I.I(ADD, "BTM1", "jmp5", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even2", False, "jmp4")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output2", "jmp5")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even2")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output2")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp6", 0)
#    I.I(ADD, "BTM1", "jmp7", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even3", False, "jmp6")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output3", "jmp7")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even3")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output3")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp8", 0)
#    I.I(ADD, "BTM1", "jmp9", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even4", False, "jmp8")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output4", "jmp9")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even4")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output4")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp10", 0)
#    I.I(ADD, "BTM1", "jmp11", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even5", False, "jmp10")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output5", "jmp11")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even5")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output5")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp12", 0)
#    I.I(ADD, "BTM1", "jmp13", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even6", False, "jmp12")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output6", "jmp13")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even6")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output6")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp14", 0)
#    I.I(ADD, "BTM1", "jmp15", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even7", False, "jmp14")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output7", "jmp15")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even7")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output7")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp16", 0)
#    I.I(ADD, "BTM1", "jmp17", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even8", False, "jmp16")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output8", "jmp17")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even8")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output8")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp18", 0)
#    I.I(ADD, "BTM1", "jmp19", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even9", False, "jmp18")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output9", "jmp19")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even9")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output9")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp20", 0)
#    I.I(ADD, "BTM1", "jmp21", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even10", False, "jmp20")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output10", "jmp21")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even10")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output10")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp22", 0)
#    I.I(ADD, "BTM1", "jmp23", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even11", False, "jmp22")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output11", "jmp23")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even11")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output11")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp24", 0)
#    I.I(ADD, "BTM1", "jmp25", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even12", False, "jmp24")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output12", "jmp25")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even12")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output12")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp26", 0)
#    I.I(ADD, "BTM1", "jmp27", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even13", False, "jmp26")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output13", "jmp27")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even13")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output13")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp28", 0)
#    I.I(ADD, "BTM1", "jmp29", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even14", False, "jmp28")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output14", "jmp29")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even14")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output14")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp30", 0)
#    I.I(ADD, "BTM1", "jmp31", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even15", False, "jmp30")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output15", "jmp31")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even15")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output15")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp32", 0)
#    I.I(ADD, "BTM1", "jmp33", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even16", False, "jmp32")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output16", "jmp33")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even16")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output16")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp34", 0)
#    I.I(ADD, "BTM1", "jmp35", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even17", False, "jmp34")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output17", "jmp35")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even17")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output17")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp36", 0)
#    I.I(ADD, "BTM1", "jmp37", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even18", False, "jmp36")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output18", "jmp37")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even18")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output18")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp38", 0)
#    I.I(ADD, "BTM1", "jmp39", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even19", False, "jmp38")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output19", "jmp39")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even19")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output19")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp40", 0)
#    I.I(ADD, "BTM1", "jmp41", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even20", False, "jmp40")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output20", "jmp41")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even20")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output20")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp42", 0)
#    I.I(ADD, "BTM1", "jmp43", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even21", False, "jmp42")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output21", "jmp43")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even21")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output21")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp44", 0)
#    I.I(ADD, "BTM1", "jmp45", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even22", False, "jmp44")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output22", "jmp45")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even22")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output22")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp46", 0)
#    I.I(ADD, "BTM1", "jmp47", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even23", False, "jmp46")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output23", "jmp47")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even23")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output23")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp48", 0)
#    I.I(ADD, "BTM1", "jmp49", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even24", False, "jmp48")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output24", "jmp49")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even24")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output24")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp50", 0)
#    I.I(ADD, "BTM1", "jmp51", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even25", False, "jmp50")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output25", "jmp51")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even25")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output25")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp52", 0)
#    I.I(ADD, "BTM1", "jmp53", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even26", False, "jmp52")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output26", "jmp53")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even26")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output26")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp54", 0)
#    I.I(ADD, "BTM1", "jmp55", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even27", False, "jmp54")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output27", "jmp55")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even27")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output27")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp56", 0)
#    I.I(ADD, "BTM1", "jmp57", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even28", False, "jmp56")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output28", "jmp57")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even28")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output28")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp58", 0)
#    I.I(ADD, "BTM1", "jmp59", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even29", False, "jmp58")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output29", "jmp59")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even29")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output29")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp60", 0)
#    I.I(ADD, "BTM1", "jmp61", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even30", False, "jmp60")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output30", "jmp61")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even30")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output30")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp62", 0)
#    I.I(ADD, "BTM1", "jmp63", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even31", False, "jmp62")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output31", "jmp63")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even31")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output31")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp64", 0)
#    I.I(ADD, "BTM1", "jmp65", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even32", False, "jmp64")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output32", "jmp65")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even32")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output32")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp66", 0)
#    I.I(ADD, "BTM1", "jmp67", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even33", False, "jmp66")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output33", "jmp67")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even33")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output33")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp68", 0)
#    I.I(ADD, "BTM1", "jmp69", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even34", False, "jmp68")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output34", "jmp69")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even34")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output34")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp70", 0)
#    I.I(ADD, "BTM1", "jmp71", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even35", False, "jmp70")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output35", "jmp71")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even35")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output35")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp72", 0)
#    I.I(ADD, "BTM1", "jmp73", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even36", False, "jmp72")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output36", "jmp73")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even36")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output36")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp74", 0)
#    I.I(ADD, "BTM1", "jmp75", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even37", False, "jmp74")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output37", "jmp75")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even37")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output37")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp76", 0)
#    I.I(ADD, "BTM1", "jmp77", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even38", False, "jmp76")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output38", "jmp77")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even38")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output38")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp78", 0)
#    I.I(ADD, "BTM1", "jmp79", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even39", False, "jmp78")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output39", "jmp79")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even39")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output39")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp80", 0)
#    I.I(ADD, "BTM1", "jmp81", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even40", False, "jmp80")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output40", "jmp81")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even40")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output40")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp82", 0)
#    I.I(ADD, "BTM1", "jmp83", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even41", False, "jmp82")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output41", "jmp83")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even41")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output41")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp84", 0)
#    I.I(ADD, "BTM1", "jmp85", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even42", False, "jmp84")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output42", "jmp85")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even42")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output42")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp86", 0)
#    I.I(ADD, "BTM1", "jmp87", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even43", False, "jmp86")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output43", "jmp87")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even43")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output43")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp88", 0)
#    I.I(ADD, "BTM1", "jmp89", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even44", False, "jmp88")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output44", "jmp89")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even44")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output44")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp90", 0)
#    I.I(ADD, "BTM1", "jmp91", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even45", False, "jmp90")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output45", "jmp91")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even45")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output45")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp92", 0)
#    I.I(ADD, "BTM1", "jmp93", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even46", False, "jmp92")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output46", "jmp93")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even46")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output46")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp94", 0)
#    I.I(ADD, "BTM1", "jmp95", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even47", False, "jmp94")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output47", "jmp95")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even47")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output47")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp96", 0)
#    I.I(ADD, "BTM1", "jmp97", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even48", False, "jmp96")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output48", "jmp97")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even48")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output48")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp98", 0)
#    I.I(ADD, "BTM1", "jmp99", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even49", False, "jmp98")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output49", "jmp99")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even49")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output49")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp100", 0)
#    I.I(ADD, "BTM1", "jmp101", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even50", False, "jmp100")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output50", "jmp101")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even50")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output50")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp102", 0)
#    I.I(ADD, "BTM1", "jmp103", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even51", False, "jmp102")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output51", "jmp103")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even51")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output51")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp104", 0)
#    I.I(ADD, "BTM1", "jmp105", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even52", False, "jmp104")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output52", "jmp105")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even52")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output52")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp106", 0)
#    I.I(ADD, "BTM1", "jmp107", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even53", False, "jmp106")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output53", "jmp107")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even53")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output53")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp108", 0)
#    I.I(ADD, "BTM1", "jmp109", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even54", False, "jmp108")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output54", "jmp109")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even54")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output54")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp110", 0)
#    I.I(ADD, "BTM1", "jmp111", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even55", False, "jmp110")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output55", "jmp111")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even55")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output55")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp112", 0)
#    I.I(ADD, "BTM1", "jmp113", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even56", False, "jmp112")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output56", "jmp113")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even56")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output56")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp114", 0)
#    I.I(ADD, "BTM1", "jmp115", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even57", False, "jmp114")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output57", "jmp115")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even57")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output57")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp116", 0)
#    I.I(ADD, "BTM1", "jmp117", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even58", False, "jmp116")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output58", "jmp117")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even58")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output58")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp118", 0)
#    I.I(ADD, "BTM1", "jmp119", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even59", False, "jmp118")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output59", "jmp119")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even59")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output59")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp120", 0)
#    I.I(ADD, "BTM1", "jmp121", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even60", False, "jmp120")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output60", "jmp121")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even60")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output60")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp122", 0)
#    I.I(ADD, "BTM1", "jmp123", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even61", False, "jmp122")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output61", "jmp123")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even61")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output61")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp124", 0)
#    I.I(ADD, "BTM1", "jmp125", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even62", False, "jmp124")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output62", "jmp125")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even62")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output62")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp126", 0)
#    I.I(ADD, "BTM1", "jmp127", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even63", False, "jmp126")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output63", "jmp127")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even63")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output63")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp128", 0)
#    I.I(ADD, "BTM1", "jmp129", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even64", False, "jmp128")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output64", "jmp129")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even64")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output64")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp130", 0)
#    I.I(ADD, "BTM1", "jmp131", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even65", False, "jmp130")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output65", "jmp131")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even65")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output65")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp132", 0)
#    I.I(ADD, "BTM1", "jmp133", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even66", False, "jmp132")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output66", "jmp133")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even66")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output66")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp134", 0)
#    I.I(ADD, "BTM1", "jmp135", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even67", False, "jmp134")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output67", "jmp135")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even67")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output67")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp136", 0)
#    I.I(ADD, "BTM1", "jmp137", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even68", False, "jmp136")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output68", "jmp137")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even68")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output68")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp138", 0)
#    I.I(ADD, "BTM1", "jmp139", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even69", False, "jmp138")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output69", "jmp139")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even69")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output69")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp140", 0)
#    I.I(ADD, "BTM1", "jmp141", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even70", False, "jmp140")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output70", "jmp141")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even70")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output70")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp142", 0)
#    I.I(ADD, "BTM1", "jmp143", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even71", False, "jmp142")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output71", "jmp143")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even71")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output71")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp144", 0)
#    I.I(ADD, "BTM1", "jmp145", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even72", False, "jmp144")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output72", "jmp145")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even72")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output72")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp146", 0)
#    I.I(ADD, "BTM1", "jmp147", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even73", False, "jmp146")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output73", "jmp147")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even73")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output73")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp148", 0)
#    I.I(ADD, "BTM1", "jmp149", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even74", False, "jmp148")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output74", "jmp149")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even74")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output74")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp150", 0)
#    I.I(ADD, "BTM1", "jmp151", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even75", False, "jmp150")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output75", "jmp151")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even75")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output75")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp152", 0)
#    I.I(ADD, "BTM1", "jmp153", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even76", False, "jmp152")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output76", "jmp153")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even76")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output76")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp154", 0)
#    I.I(ADD, "BTM1", "jmp155", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even77", False, "jmp154")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output77", "jmp155")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even77")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output77")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp156", 0)
#    I.I(ADD, "BTM1", "jmp157", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even78", False, "jmp156")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output78", "jmp157")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even78")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output78")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp158", 0)
#    I.I(ADD, "BTM1", "jmp159", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even79", False, "jmp158")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output79", "jmp159")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even79")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output79")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp160", 0)
#    I.I(ADD, "BTM1", "jmp161", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even80", False, "jmp160")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output80", "jmp161")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even80")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output80")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp162", 0)
#    I.I(ADD, "BTM1", "jmp163", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even81", False, "jmp162")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output81", "jmp163")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even81")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output81")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp164", 0)
#    I.I(ADD, "BTM1", "jmp165", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even82", False, "jmp164")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output82", "jmp165")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even82")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output82")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp166", 0)
#    I.I(ADD, "BTM1", "jmp167", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even83", False, "jmp166")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output83", "jmp167")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even83")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output83")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp168", 0)
#    I.I(ADD, "BTM1", "jmp169", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even84", False, "jmp168")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output84", "jmp169")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even84")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output84")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp170", 0)
#    I.I(ADD, "BTM1", "jmp171", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even85", False, "jmp170")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output85", "jmp171")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even85")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output85")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp172", 0)
#    I.I(ADD, "BTM1", "jmp173", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even86", False, "jmp172")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output86", "jmp173")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even86")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output86")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp174", 0)
#    I.I(ADD, "BTM1", "jmp175", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even87", False, "jmp174")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output87", "jmp175")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even87")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output87")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp176", 0)
#    I.I(ADD, "BTM1", "jmp177", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even88", False, "jmp176")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output88", "jmp177")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even88")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output88")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp178", 0)
#    I.I(ADD, "BTM1", "jmp179", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even89", False, "jmp178")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output89", "jmp179")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even89")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output89")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp180", 0)
#    I.I(ADD, "BTM1", "jmp181", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even90", False, "jmp180")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output90", "jmp181")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even90")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output90")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp182", 0)
#    I.I(ADD, "BTM1", "jmp183", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even91", False, "jmp182")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output91", "jmp183")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even91")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output91")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp184", 0)
#    I.I(ADD, "BTM1", "jmp185", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even92", False, "jmp184")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output92", "jmp185")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even92")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output92")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp186", 0)
#    I.I(ADD, "BTM1", "jmp187", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even93", False, "jmp186")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output93", "jmp187")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even93")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output93")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp188", 0)
#    I.I(ADD, "BTM1", "jmp189", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even94", False, "jmp188")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output94", "jmp189")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even94")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output94")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp190", 0)
#    I.I(ADD, "BTM1", "jmp191", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even95", False, "jmp190")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output95", "jmp191")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even95")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output95")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp192", 0)
#    I.I(ADD, "BTM1", "jmp193", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even96", False, "jmp192")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output96", "jmp193")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even96")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output96")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp194", 0)
#    I.I(ADD, "BTM1", "jmp195", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even97", False, "jmp194")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output97", "jmp195")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even97")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output97")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp196", 0)
#    I.I(ADD, "BTM1", "jmp197", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even98", False, "jmp196")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output98", "jmp197")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even98")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output98")
#    I.I(ADD, "A_IO", 0, "temp")
###YYY##################################################################################################################################
#    I.I(ADD, "BTM0", "jmp198", 0)
#    I.I(ADD, "BTM1", "jmp199", 0)
#    I.I(ADD, "temp", 0, "seed_pointer")
#    I.I(MLS, "temp", "three", "temp"),          I.JEV("even99", False, "jmp198")
#    I.I(ADD, "temp", "one", "temp"),            I.JMP("output99", "jmp199")
#    I.I(MHU, "temp", "right_shift_1", "temp"),  I.N("even99")
#    I.I(ADD, "seed_pointer", 0, "temp"),        I.N("output99")
#    I.I(ADD, "A_IO", 0, "temp"),                I.JMP("init", "jmp200")  #                JMP     init


# Experiment:
# 35 passes over 100 elements inside 200,000 simulation cycles
# Cycles: 196320 - 40 = 196280
# Useful cycles: 196280 / 8 = 24535
# Cycles per pass: 24535 / 35 = 701
# Cycles per output: 701 / 100 = 7.01

# PC Tally:
# All cycles useful except:
# 2 BTM loads per unrolled loop: 2 * 100 = 200
# Cancelled MUL per loop
# awk '{sum+=$1}END{print sum/NR; print NR}'
# Average value of the +1 executed after *3, to figure out cancelled ratio: 11.69
# Cancelled: 35 - 11.69 = 23.31 * 100 = 2331
# Not Cancelled (run with +1): 11.69 * 100 = 1169
# Total not useful: 200 + 2331 = 2531
# Total useful: 24535 - 2531 = 22004
# ALU efficiency: 22004 / 24535 = 0.89684

# Cross-check: number of even (MHU) cycles: 23.96 * 100 = 2396
# 1169 * 2 = 2338
# 2338 / 2396 = 0.9758 odd/even (useful)



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

