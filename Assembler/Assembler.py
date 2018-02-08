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
A.write_offset  = 10
A.filename      = "A.mem"

B.mem           = create_memory(1024, 36)
B.here          = -1
B.last          = 0
B.read_names    = {}
B.write_names   = {}
B.write_offset  = 1024
B.filename      = "B.mem"

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
    addresses = []
    for entry in mem_list:
        address = entry.write_addr[name]
        addresses.append(address)
    if len(addresses) == 0:
        print("ERROR: Cannot resolve undefined write name: {0}".format(name))
        sys.exit(1)
    if len(addresses) > 1:
        print("ERROR: Cannot resolve multiple identical write names: {0}".format(name))
        sys.exit(1)
    return addresses[0]

def simple(mem_obj, op, dest, src1, src2, mem_list = mem_list, instr_format = simple_instr_format):
    """Assemble a simple instruction"""
    D = lookup_write(dest, mem_list)
    A = A.read_names[src1]
    B = B.read_names[src2]
    instr = pack(instr_format, op, D, A, B)
    lit(mem_obj, instr.uint)

def dual(mem_obj, op, dest1, dest2, src1, src2, mem_list = mem_list, instr_format = dual_instr_format):
    """Assemble a dual instruction (split addressing mode)"""
    # The CPU re-adds the correct write offset after it decodes the instruction
    # It's a power-of-2 alignment, so it just prepends the right value
    DA = A.write_names[dest1] - A.write_offset
    DB = B.write_names[dest2] - B.write_offset
    A = A.read_names[src1]
    B = B.read_names[src2]
    instr = pack(instr_format, op, DA, DB, A, B)
    lit(mem_obj, instr.uint)

# ---------------------------------------------------------------------
# Opcode Decoder Memory: translate opcode into ALU control bits

class O:
    pass

thread_count = 8
opcode_count = 16

alu_control_format = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5},uint:{6},uint:{7}'.format(ALU.split_width, ALU.shift_width, ALU.dyadic3_width, ALU.addsub_width, ALU.dual_width, ALU.dyadic2_width, ALU.dyadic1_width, ALU.select_width)

O.mem       = create_memory(opcode_count*thread_count, ALU.total_op_width)
O.opcodes   = {} # {name:bits}

def define_opcode(mem_obj, name, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
    """Assembles and names the control bits of an opcode."""
    control_bits = BitArray()
    for entry in [split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select]:
        control_bits.append(entry)
    mem_obj.opcodes.update({name:control_bits})

def load_opcode(mem_obj, thread, name, opcode):
    """The opcode indexes into the opcode decoder memory, separately for each thread."""
    address = thread * opcode
    mem_obj.mem[address] = mem_obj.opcodes[name]

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
    mem_obj.conditions.update({name, condition}) 

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

PC.mem      = create_memory(thread_count, pc_width)
PC.filename = "PC.mem"

PC_prev.mem         = create_memory(thread_count, pc_width)
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

DO.mem      = create_memory(thread_count, do_width)
DO.filename = "DO.mem"

def set_do(mem_obj, thread, offset):
    offset = BitArray(uint=offset, length=mem_obj.mem[0].length)
    mem_obj.mem[thread] = offset;

# ---------------------------------------------------------------------
# Programmed Offset Memory



# ---------------------------------------------------------------------

if __name__ == "__main__":
    pprint(len(A.mem))
    loc(A, "foobar", 5)
    pprint(A.read_names["foobar"])
    pprint(A.write_names["foobar"])
    data(A, [1,3,5,7,9], "numnums")
    file_dump(A)    

