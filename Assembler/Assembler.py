#! /usr/bin/python3

"""Quick and dirty assembler for Octavo, for initial test, debug, and benchmarking."""

import Dyadic_Operators as Dyadic
import Triadic_ALU_Operators as ALU
import Branch_Detector_Operators as Branch
from bitstring import pack,BitArray
import sys
from pprint import pprint


# ---------------------------------------------------------------------
# Dumping memory data to file

def dump_format(width):
    """Numbers must be represented as zero-padded whole hex numbers"""
    characters = width // 4
    remainder = width % 4
    characters += min(1, remainder)
    format_string = "{:0" + str(characters) + "x}"
    return format_string

def file_dump(mem_obj):
    """Dump to Verilog loadable format for readmemh()."""
    file_header  = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""
    mem         = mem_obj.mem
    filename    = mem_obj.filename
    with open(filename, 'w') as f:
        f.write(file_header + "\n")
        # We assume all memory values are the same width
        format_string = dump_format(mem[0].length)
        for entry in mem:
            output = format_string.format(entry.uint)
            f.write(output + "\n")

# ---------------------------------------------------------------------
# Location naming and lookup

def loc(mem_obj, name, read_addr = None, write_addr = None):
    """Name a given location. May have only a read or write address, or both.
       If neither addresses are given, then name the current location, 
       after 'here' was incremented by another operation."""
    if read_addr is not None:
        if read_addr < 0 or read_addr > len(mem_obj.mem)-1:
            print("ERROR: Out of bounds name read address ({0}) assignment in {1}".format(read_addr, mem_obj.__name__))
            sys.exit(1)
        mem_obj.read_names.update({name:read_addr})
    if write_addr is None and read_addr is not None:
        # No bounds check here as write address can be over a different range, depending on where Memory is mapped.
        write_addr = read_addr + mem_obj.write_offset
    if write_addr is not None:
        mem_obj.write_names.update({name:write_addr})
    if write_addr is None and read_addr is None:
        if mem_obj.here < 0 or mem_obj.here > len(mem_obj.mem)-1:
            print("ERROR: Out of bounds name ({0}) in {1}".format(mem_obj.here, mem_obj.__name__))
        loc(mem_obj, name, mem_obj.here)

# ---------------------------------------------------------------------
# Compile literals at locations (basic assembler mechanism and state)

def align(mem_obj, addr):
    """Continue assembling at new address. Assumes pre-incrementing 'here'"""
    if type(addr) == str:
        addr = mem_obj.read_addr[addr]
    if addr < 0 or addr > len(mem_obj.mem)-1:
        print("ERROR: Out of bounds align ({0}) in {1}".format(mem_obj.here, mem_obj.__name__))
    if addr > mem_obj.last:
        mem_obj.last = addr
    mem_obj.here = addr - 1

def resume(mem_obj):
    """Resume assembling at first free sequential location after an align()."""
    mem_obj.here = mem_obj.last - 1

def lit(mem_obj, number):
    """Place a literal number 'here'"""
    mem_obj.here += 1
    if mem_obj.here < 0 or mem_obj.here > len(mem_obj.mem)-1:
        print("ERROR: Out of bounds lit ({0}) in {1}".format(mem_obj.here, mem_obj.__class__.__name__))
    if mem_obj.here >= mem_obj.last:
        mem_obj.last = mem_obj.here + 1
    mem_obj.mem[mem_obj.here] = BitArray(uint=number, length=mem_obj.mem[mem_obj.here].length)

def data(mem_obj, entries, name = None):
    """Place a list of numbers into consecutive locations.
       Optionally name the head of the list."""
    if len(entries) == 0:
        print("ERROR: Empty data list for {0}".format(mem_obj.__name__))
    if name is not None:
        head = entries.pop(0)
        lit(mem_obj, head)
        loc(mem_obj, name)
    for entry in entries:
        lit(mem_obj, entry)

# ---------------------------------------------------------------------
# Create the Data Memories

def create_memory(depth, width):
    mem = []
    for entry in range(depth):
        mem.append(BitArray(width))
    return mem

class A:
    pass

class B:
    pass

A.mem           = create_memory(1024, 36)
A.here          = -1
A.last          = 0
A.read_names    = {}
A.write_names   = {}
A.write_offset  = 0
A.filename      = "A.mem"

B.mem           = create_memory(1024, 36)
B.here          = -1
B.last          = 0
B.read_names    = {}
B.write_names   = {}
B.write_offset  = 1024
B.filename      = "B.mem"

# ---------------------------------------------------------------------
# Thread information

class Thread:
    count = 8
    start = [1,50,50,50,50,50,50,50]
    end   = [5,50,50,50,50,50,50,50]

# ---------------------------------------------------------------------
# Opcode Decoder Memory: translate opcode into ALU control bits

class OD:
    pass

opcode_count = 16

alu_control_format = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5},uint:{6},uint:{7}'.format(ALU.split_width, ALU.shift_width, ALU.dyadic3_width, ALU.addsub_width, ALU.dual_width, ALU.dyadic2_width, ALU.dyadic1_width, ALU.select_width)

OD.mem       = create_memory(opcode_count*Thread.count, ALU.total_op_width)
OD.opcodes   = {} # {name:bits}
OD.filename  = "OD.mem"

def define_opcode(mem_obj, name, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
    """Assembles and names the control bits of an opcode."""
    control_bits = BitArray()
    for entry in [split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select]:
        control_bits.append(entry)
    mem_obj.opcodes.update({name:control_bits})

def load_opcode(mem_obj, thread, name, opcode):
    """The opcode indexes into the opcode decoder memory, separately for each thread."""
    address = (thread * opcode_count) + opcode
    mem_obj.mem[address] = mem_obj.opcodes[name]

def lookup_opcode(mem_obj, thread, name):
    """Finds the bit pattern for the named opcode, searches for address of those bits."""
    control_bits = mem_obj.opcodes[name]
    op_zero = (thread * opcode_count)
    for opcode in range(op_zero, op_zero + opcode_count):
        if mem_obj.mem[opcode] == control_bits:
            return opcode
    print("Could not find opcode named {0} in thread {1}".format(name, thread))
    sys.exit(1)
    

# ---------------------------------------------------------------------
# Create the Instruction Memory

class I:
    pass

I.mem           = create_memory(1024, 36)
I.here          = -1
I.last          = 0
I.write_names   = {}
I.write_offset  = 3072
I.filename      = "I.mem"

simple_instr_format = 'uint:4,uint:12,uint:10,uint:10'
dual_instr_format   = 'uint:4,uint:6,uint:6,uint:10,uint:10'

mem_list = [A,B,I]

def lookup_write(name, mem_list):
    """Lookup the write address of a name across the listed memories."""
    if type(name) == type(int()):
        return name
    addresses = []
    for entry in mem_list:
        address = entry.write_names.get(name, None)
        if address is not None:
            addresses.append(address)
    if len(addresses) == 0:
        print("ERROR: Cannot resolve undefined write name: {0}".format(name))
        sys.exit(1)
    if len(addresses) > 1:
        print("ERROR: Cannot resolve multiple identical write names: {0}".format(name))
        sys.exit(1)
    return addresses[0]

def lookup_read(name, mem):
    if type(name) == type(int()):
        return name
    address = mem.read_names[name]
    return address

def simple(mem_obj, thread, op_name, dest, src1, src2, mem_list = mem_list, instr_format = simple_instr_format, OD = OD, A = A, B = B):
    """Assemble a simple instruction"""
    op = lookup_opcode(OD, thread, op_name)
    D = lookup_write(dest, mem_list)
    A = lookup_read(src1, A)
    B = lookup_read(src2, B)
    instr = pack(instr_format, op, D, A, B)
    lit(mem_obj, instr.uint)

def dual(mem_obj, thread, op_name, dest1, dest2, src1, src2, mem_list = mem_list, instr_format = dual_instr_format, OD = OD):
    """Assemble a dual instruction (split addressing mode)"""
    # The CPU re-adds the correct write offset after it decodes the instruction
    # It's a power-of-2 alignment, so it just prepends the right value
    op = lookup_opcode(OD, thread, op_name)
    DA = A.write_names[dest1] - A.write_offset
    DB = B.write_names[dest2] - B.write_offset
    A = A.read_names[src1]
    B = B.read_names[src2]
    instr = pack(instr_format, op, DA, DB, A, B)
    lit(mem_obj, instr.uint)

# ---------------------------------------------------------------------
# Branch Detector

branch_count = 4

class BD:
    pass

condition_format = 'uint:{0},uint:{1},uint:{2}'.format(Branch.A_flag_width, Branch.B_flag_width, Branch.AB_operator_width)

branch_format = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5}'.format(Branch.origin_width, Branch.origin_enable_width, Branch.destination_width, Branch.predict_taken_width, Branch.predict_enable_width, Branch.condition_width)

BD.conditions   = {} # {name:bits}
BD.branches     = {} # {name:bits}

def condition(mem_obj, name, A_flag, B_flag, AB_operator):
    condition = BitArray()
    for entry in [A_flag, B_flag, AB_operator]:
        condition.append(entry)
    mem_obj.conditions.update({name:condition}) 

def branch(mem_obj, name, origin, origin_enable, destination, predict_taken, predict_enable, condition_name):
    condition           = mem_obj.conditions[condition_name]
    origin_bits         = BitArray(uint=origin, length=Branch.origin_width)
    destination_bits    = BitArray(uint=destination, length=Branch.destination_width)
    config = BitArray()
    for entry in [origin_bits, origin_enable, destination_bits, predict_taken, predict_enable, condition]:
        config.append(entry)
    mem_obj.branches.update({name:config})

# ---------------------------------------------------------------------
# Program Counter

pc_width = 10

class PC:
    pass

class PC_prev:
    pass

PC.mem      = create_memory(Thread.count, pc_width)
PC.names    = {} # {name:address}
PC.filename = "PC.mem"

PC_prev.mem         = create_memory(Thread.count, pc_width)
PC_prev.filename    = "PC_prev.mem"

pc_format = 'uint:{0}'.format(pc_width)

def set_pc(mem_obj, thread, pc_value):
    pc_value = BitArray(uint=pc_value, length=mem_obj.mem[0].length)
    mem_obj.mem[thread] = pc_value;

# ---------------------------------------------------------------------
# Default Offset Memory

# This should be 10 for A/B memories, but it's not set up in the Verilog.
# That will cause readmemh() warnings, which we'll have to fix later.
do_width = 12 

class DO:
    pass

DO.mem      = create_memory(Thread.count, do_width)
DO.filename = "DO.mem"

def set_do(mem_obj, thread, offset):
    offset = BitArray(uint=offset, length=mem_obj.mem[0].length)
    mem_obj.mem[thread] = offset;

# ---------------------------------------------------------------------
# Programmed Offset Memory

po_entries              = 4
po_increment_bits       = 4
po_increment_sign_bits  = 1
po_offset_bits          = 12
po_width                = po_increment_sign_bits + po_increment_bits + po_offset_bits

class PO:
    pass

PO.mem      = create_memory(Thread.count*po_entries, po_width)
PO.filename = "PO.mem"

def set_po(mem_obj, thread, entry, sign, increment, offset, po_increment_sign_bits = po_increment_sign_bits, po_increment_bits = po_increment_bits, po_offset_bits = po_offset_bits, po_entries = po_entries, po_width = po_width):
    if entry < 0 or entry > po_entries-1:
        print("Out of bounds PO entry: {0}".format(entry))
        sys.exit(1)
    sign        = BitArray(uint=sign,      length=po_increment_sign_bits)
    increment   = BitArray(uint=increment, length=po_increment_bits)
    offset      = BitArray(uint=offset,    length=po_offset_bits)
    po          = BitArray()
    for field in [sign, increment, offset]:
        po.append(field)
    if po.length != po_width:
        print("PO length error! Got {0}, expected {1}".format(po.length, po_width))
        sys.exit(1)
    mem_obj.mem[thread*entry] = po;

# ---------------------------------------------------------------------
# Memory map

class MEMMAP:
    # These are for A/B
    zero        = 0
    shared      = [1,2,3,4,5,6,7,8,9,10,11,12]
    pool        = [9,10,11,12]
    io          = [1,2,3,4,5,6,7,8]
    indirect    = [13,14,15,16]
    normal      = 17
    # Memory base addresses
    a           = 0
    b           = 1024
    i           = 2048
    h           = 3072
    # Config registers in H memory
    s           = 3072
    a_po        = [3076,3077,3078,3079]
    b_po        = [3080,3081,3082,3083]
    da_po       = [3084,3085,3086,3087]
    db_po       = [3088,3089,3090,3091]
    do          = 3092
    fc          = [3100,3106,3112,3118]
    od          = [3200,3201,3202,3203,3204,3205,3206,3207,3208,3209,3210,3211,3212,3213,3214,3215]

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# Quick test

initializable_memories = [A,B,I,OD,DO,PO,PC,PC_prev]

def dump_all(mem_obj_list):
    for mem in mem_obj_list:
        file_dump(mem)

# Thread 0 must start its code at 1, as first PC is always 0 (register set at config)
# Start all threads at 1. Avoids sticking at zero due to null Branch Detector entry.
def init_PC(PC = PC, PC_prev = PC_prev):
    for thread in range(Thread.count):
        start = Thread.start[thread]
        set_pc(PC,      thread, start)
        set_pc(PC_prev, thread, start)

def init_ISA(OD = OD, MEMMAP = MEMMAP):
    define_opcode(OD, "NOP", ALU.split_no, ALU.shift_none, Dyadic.always_zero, ALU.addsub_a_plus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "ADD", ALU.split_no, ALU.shift_none, Dyadic.b, ALU.addsub_a_plus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "SUB", ALU.split_no, ALU.shift_none, Dyadic.b, ALU.addsub_a_minus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "ADD*2", ALU.split_no, ALU.shift_left, Dyadic.b, ALU.addsub_a_minus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "ADD/2", ALU.split_no, ALU.shift_right_signed, Dyadic.b, ALU.addsub_a_minus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    for thread in range(Thread.count):
        load_opcode(OD, thread, "NOP",   0)
        load_opcode(OD, thread, "ADD",   1)
        load_opcode(OD, thread, "SUB",   2)
        load_opcode(OD, thread, "ADD*2", 3)
        load_opcode(OD, thread, "ADD/2", 4)

def init_branches(BD = BD):
    condition(BD, "JMP", Branch.A_flag_negative, Branch.B_flag_lessthan, Dyadic.always_one)
    for thread in range(Thread.count):
        # Only load the branch entry once
        start = Thread.start[thread] + 1
        end   = Thread.end[thread]
        name  = "loop_thread_{0}".format(thread)
        branch(BD, name, end, Branch.origin_enabled, start, Branch.predict_taken, Branch.predict_enabled, "JMP")

def init_A(A = A, MEMMAP = MEMMAP):
    align(A, 0)
    lit(A, 0), loc(A, "zero_A")
    #align(A, MEMMAP.pool[0])
    align(A, MEMMAP.normal)
    lit(A, 1), loc(A, "thread_0_val")
    lit(A, 2), loc(A, "thread_1_val")
    lit(A, 3), loc(A, "thread_2_val")
    lit(A, 4), loc(A, "thread_3_val")
    lit(A, 5), loc(A, "thread_4_val")
    lit(A, 6), loc(A, "thread_5_val")
    lit(A, 7), loc(A, "thread_6_val")
    lit(A, 8), loc(A, "thread_7_val")

def init_B(B = B, MEMMAP = MEMMAP):
    align(B, 0)
    lit(B, 0), loc(B, "zero_B")
    align(B, MEMMAP.pool[0])
    lit(B, 1), loc(B, "one")
    lit(B, 2), loc(B, "two")
    align(B, MEMMAP.normal)
    lit(B, BD.branches["loop_thread_0"].uint), loc(B, "branch_0")
    lit(B, BD.branches["loop_thread_1"].uint), loc(B, "branch_1")
    lit(B, BD.branches["loop_thread_2"].uint), loc(B, "branch_2")
    lit(B, BD.branches["loop_thread_3"].uint), loc(B, "branch_3")
    lit(B, BD.branches["loop_thread_4"].uint), loc(B, "branch_4")
    lit(B, BD.branches["loop_thread_5"].uint), loc(B, "branch_5")
    lit(B, BD.branches["loop_thread_6"].uint), loc(B, "branch_6")
    lit(B, BD.branches["loop_thread_7"].uint), loc(B, "branch_7")
    

def init_I(I = I, PC = PC):
    align(I, 0)
    simple(I, 0, "NOP", "zero_A", "zero_A", "zero_B")

    align(I, Thread.start[0])
    simple(I, 0, "ADD", MEMMAP.fc[0], "zero_A", "branch_0")

#    align(I, Thread.start[1])
#    simple(I, 0, "ADD", MEMMAP.fc[0], "zero_A", "branch_1")
#    simple(I, 0, "ADD", "thread_1_val", "thread_1_val", "one")
#    simple(I, 0, "ADD", MEMMAP.io[0],   "thread_1_val", "zero_B")
#
#    align(I, Thread.start[2])
#    simple(I, 0, "ADD", MEMMAP.fc[0], "zero_A", "branch_2")
#    simple(I, 0, "ADD", "thread_2_val", "thread_2_val", "one")
#    simple(I, 0, "ADD", MEMMAP.io[0],   "thread_2_val", "zero_B")
#
#    align(I, Thread.start[3])
#    simple(I, 0, "ADD", MEMMAP.fc[0], "zero_A", "branch_3")
#    simple(I, 0, "ADD", "thread_3_val", "thread_3_val", "one")
#    simple(I, 0, "ADD", MEMMAP.io[0],   "thread_3_val", "zero_B")
#
#    align(I, Thread.start[4])
#    simple(I, 0, "ADD", MEMMAP.fc[0], "zero_A", "branch_4")
#    simple(I, 0, "ADD", "thread_4_val", "thread_4_val", "one")
#    simple(I, 0, "ADD", MEMMAP.io[0],   "thread_4_val", "zero_B")
#
#    align(I, Thread.start[5])
#    simple(I, 0, "ADD", MEMMAP.fc[0], "zero_A", "branch_5")
#    simple(I, 0, "ADD", "thread_5_val", "thread_5_val", "one")
#    simple(I, 0, "ADD", MEMMAP.io[0],   "thread_5_val", "zero_B")
#
#    align(I, Thread.start[6])
#    simple(I, 0, "ADD", MEMMAP.fc[0], "zero_A", "branch_6")
#    simple(I, 0, "ADD", "thread_6_val", "thread_6_val", "one")
#    simple(I, 0, "ADD", MEMMAP.io[0],   "thread_6_val", "zero_B")
#
#    align(I, Thread.start[7])
#    simple(I, 0, "ADD", MEMMAP.fc[0], "zero_A", "branch_7")
#    simple(I, 0, "ADD", "thread_7_val", "thread_7_val", "one")
#    simple(I, 0, "ADD", MEMMAP.io[0],   "thread_7_val", "zero_B")

# ---------------------------------------------------------------------

if __name__ == "__main__":
    init_PC()
    init_ISA()
    init_branches()
    init_A()
    init_B()
    init_I()
    dump_all(initializable_memories)

