#! /usr/bin/python

import empty
from opcodes import *
from memory_map import mem_map
from branching_flags import *

bench_dir  = "FSM_S"
bench_file = "fsm_s"
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
    A.L(0),                 A.N("state0")
    A.L(1),                 A.N("state1")
    A.L(2),                 A.N("state2")
    A.L(3),                 A.N("state3")
    A.L(4),                 A.N("state4")
    A.L(5),                 A.N("state5")
    A.L(6),                 A.N("state6")
    A.L(7),                 A.N("state7")
    # Placeholders for branch table entries
    A.L(0),                 A.N("br0a")
    A.L(0),                 A.N("br0b")
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
    A.L(0),                 A.N("br34")
    A.L(0),                 A.N("br35")
    A.L(0),                 A.N("br36")
    return A

def assemble_B():
    B = empty["B"]
    B.file_name = bench_name
    B.P("B_IO", mem_map["B"]["IO_base"])
    B.P("array_top_pointer",      mem_map["B"]["PO_INC_base"],   write_addr = mem_map["H"]["PO_INC_base"])
    B.A(0)
    B.L(0)
    B.L(0),     B.N("curr_state")
    B.L(0),     B.N("next_state")
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

###
# Implements: [+-]?(\.[0-9]+|[0-9]+\.[0-9]*)
# Matches simple Python FP numbers
# See: http://www.regexper.com/#[%2B-]%3F%28\.[0-9]%2B|[0-9]%2B\.[0-9]*%29
###


def assemble_I(PC, A, B):
    I = empty["I"]
    I.file_name = bench_name

    # Thread 0 has implicit first NOP from pipeline, so starts at 1
    # All threads start at 1, to avoid triggering branching unit at 0.
    I.A(1)

    # Instructions to fill branch table
    base_addr = mem_map["BO"]["Origin"]
    #depth     = mem_map["BO"]["Depth"]
    I.P("BTM0", None, write_addr = base_addr)
    I.P("BTM1", None, write_addr = base_addr + 1)
    I.P("BTM2", None, write_addr = base_addr + 2)
    I.P("BTM3", None, write_addr = base_addr + 3)

    I.I(ADD, "BTM0",      0, 0) # Used throughout at temp storage
    I.I(ADD, "BTM1", "br0a", 0) # Saves a cycle in outer
    I.I(ADD, "BTM2", "br0b", 0) # Saves a cycle in outer
    I.I(ADD, "BTM3", "br00", 0) # Saves a cycle in outer

    # Instruction to set indirect access
    base_addr = mem_map["BPO"]["Origin"] 
    I.I(ADD, base_addr,   0, "array_top_pointer_init")     
    I.NOP()

    #7
    I.I(XOR, "temp2", "state6", "next_state"),              I.N("outer")
    I.I(XOR, "temp2", "state7", "next_state"),              I.JZE("newstate", False, "br0a")
    I.I(ADD, "temp", 0, "array_top_pointer"),               I.JZE("newstate", False, "br0b")
    I.I(ADD, "curr_state",  0, "next_state"),               I.N("newstate"), I.JNE("state7",   False, "br00")

    #Jump table
    I.I(ADD, "BTM0", "br01", 0)
    I.I(XOR, "temp2", "state0", "curr_state")
    I.I(ADD, "BTM0", "br09", 0),                            I.JZE("state0", False, "br01")  
    I.I(XOR, "temp2", "state1", "curr_state")
    I.I(ADD, "BTM0", "br14", 0),                            I.JZE("state1", False, "br09")
    I.I(XOR, "temp2", "state2", "curr_state")
    I.I(ADD, "BTM0", "br18", 0),                            I.JZE("state2", False, "br14")
    I.I(XOR, "temp2", "state3", "curr_state")
    I.I(ADD, "BTM0", "br23", 0),                            I.JZE("state3", False, "br18")
    I.I(XOR, "temp2", "state4", "curr_state")
    I.I(ADD, "BTM0", "br28", 0),                            I.JZE("state4", False, "br23")
    I.I(XOR, "temp2", "state5", "curr_state")
    I.I(ADD, "BTM0", "br33", 0),                            I.JZE("state5", False, "br28")
    I.I(XOR, "temp2", "state6", "curr_state")
    I.I(ADD, "BTM0", "br34", 0),                            I.JZE("state6", False, "br33")
    I.NOP()
    I.NOP(),                                                I.JMP("state7",        "br34")



    I.I(ADD, "BTM0", "br02", 0),                            I.N("state0") 
    I.I(XOR, "temp2", "space", "temp")
    I.I(ADD, "next_state", "state0", 0),                    I.JZE("outer",  True,  "br02")

    I.I(ADD, "BTM0", "br03", 0)
    I.I(XOR, "temp2", "plus", "temp")
    I.I(ADD, "next_state", "state1", 0),                    I.JZE("outer",  True,  "br03")

    I.I(ADD, "BTM0", "br04", 0)
    I.I(XOR, "temp2", "minus", "temp")
    I.I(ADD, "next_state",  "state1", 0),                   I.JZE("outer",  True,  "br04")

    I.I(ADD, "BTM0", "br05", 0)
    I.I(XOR, "temp2", "dot", "temp")
    I.I(ADD, "next_state",  "state2", 0),                   I.JZE("outer",  True,  "br05")

    I.I(ADD, "BTM0", "br06", 0)
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "next_state", "state7", 0),                    I.JNE("outer",  True,  "br06")

    I.I(ADD, "BTM0", "br07", 0)
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "next_state", "state4", 0),                    I.JPO("outer",  True,  "br07")

    I.I(ADD, "BTM0", "br08", 0)
    I.NOP()
    I.I(ADD, "next_state", "state7", 0),                    I.JMP("outer",         "br08")



    I.I(ADD, "BTM0", "br10", 0),                            I.N("state1")
    I.I(XOR, "temp2", "dot", "temp")
    I.I(ADD, "next_state", "state2", 0),                    I.JZE("outer",  True,  "br10")

    I.I(ADD, "BTM0", "br11", 0)
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "next_state", "state7", 0),                    I.JNE("outer",  True,  "br11")

    I.I(ADD, "BTM0", "br12", 0)
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "next_state", "state4", 0),                    I.JPO("outer",  True,  "br12")

    I.I(ADD, "BTM0", "br13", 0)
    I.NOP()
    I.I(ADD, "next_state", "state7", 0),                    I.JMP("outer",         "br13")



    I.I(ADD, "BTM0", "br15", 0),                            I.N("state2")
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "next_state", "state7", 0),                    I.JNE("outer",  True,  "br15")

    I.I(ADD, "BTM0", "br16", 0)
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "next_state", "state3", 0),                    I.JPO("outer",  True,  "br16")

    I.I(ADD, "BTM0", "br17", 0)
    I.NOP()
    I.I(ADD, "next_state", "state7", 0),                    I.JMP("outer",         "br17")



    I.I(ADD, "BTM0", "br19", 0),                            I.N("state3")
    I.I(XOR, "temp2", "space", "temp")
    I.I(ADD, "next_state", "state6", 0),                    I.JZE("outer",  True,  "br19")

    I.I(ADD, "BTM0", "br20", 0)
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "next_state", "state7", 0),                    I.JNE("outer",  True,  "br20")

    I.I(ADD, "BTM0", "br21", 0)
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "next_state", "state3", 0),                    I.JPO("outer",  True,  "br21")

    I.I(ADD, "BTM0", "br22", 0)
    I.NOP()
    I.I(ADD, "next_state", "state7", 0),                    I.JMP("outer",         "br22")



    I.I(ADD, "BTM0", "br24", 0),                            I.N("state4")
    I.I(XOR, "temp2", "dot", "temp")
    I.I(ADD, "next_state", "state5", 0),                    I.JZE("outer",  True,  "br24")

    I.I(ADD, "BTM0", "br25", 0)
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "next_state", "state7", 0),                    I.JNE("outer",  True,  "br25")

    I.I(ADD, "BTM0", "br26", 0)
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "next_state", "state4", 0),                    I.JPO("outer",  True,  "br26")

    I.I(ADD, "BTM0", "br27", 0)
    I.NOP()
    I.I(ADD, "next_state", "state7", 0),                    I.JMP("outer",         "br27")



    I.I(ADD, "BTM0", "br29", 0),                            I.N("state5")
    I.I(XOR, "temp2", "space", "temp")
    I.I(ADD, "next_state", "state6", 0),                    I.JZE("outer",  True,  "br29")

    I.I(ADD, "BTM0", "br30", 0)
    I.I(ADD, "temp2", "zero_char_neg", "temp")
    I.I(ADD, "next_state", "state7", 0),                    I.JNE("outer",  True,  "br30")

    I.I(ADD, "BTM0", "br31", 0)
    I.I(SUB, "temp2", "ten", "temp2")
    I.I(ADD, "next_state", "state3", 0),                    I.JPO("outer",  True,  "br31")

    I.I(ADD, "BTM0", "br32", 0)
    I.NOP()
    I.I(ADD, "next_state", "state7", 0),                    I.JMP("outer",         "br32")



    I.I(ADD, "BTM0", "br35", 0),                            I.N("state6")
    I.I(ADD, "next_state", "state0", 0)
    I.I(ADD, "A_IO", "one", 0),                             I.JMP("outer",         "br35")


    # stay here as we are done
    I.I(ADD, "BTM0", "br36", 0),                            I.N("state7")
    I.NOP()
    I.I(ADD, "B_IO", "one", 0),                             I.N("end"), I.JMP("end",        "br36")

    
    


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

