#! /usr/bin/python3

"""Quick and dirty assembler for Octavo, for initial test, debug, and benchmarking."""

import Dyadic_Operators as Dyadic
import Triadic_ALU_Operators as ALU
import Branch_Detector_Operators as Branch
from bitstring import pack,BitArray
import sys
from math import ceil
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
    word_length = mem_obj.mem[mem_obj.here].length
    if type(number) == type(int()):
        mem_obj.mem[mem_obj.here] = BitArray(uint=number, length=word_length)
    elif type(number) == type(BitArray()):
        # Oh, this is ugly. BitArray's LSB is our MSB...
        mem_obj.mem[mem_obj.here].overwrite(number,(word_length-number.length))
    else:
        printf("Incompatible literal type: {0}".format(number))
        sys.exit(1)

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
    depth           = 1024
    width           = 36
    mem             = create_memory(depth, width)
    here            = -1
    last            = 0
    read_names      = {}
    write_names     = {}
    write_offset    = 0
    filename        = "A.mem"

class B:
    depth           = 1024
    width           = 36
    mem             = create_memory(depth, width)
    here            = -1
    last            = 0
    read_names      = {}
    write_names     = {}
    write_offset    = 1024
    filename        = "B.mem"

# ---------------------------------------------------------------------
# Memory map

class MEMMAP:
    # These are for A/B
    zero        = 0
    shared      = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    pool        = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    indirect    = [24,25,26,27]
    io          = [28,29,30,31]
    normal      = 32
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
    bs1_sentinel= [3100,3106,3112,3118]
    bs1_mask    = [3101,3107,3113,3119]
    bs2_sentinel= [3102,3108,3114,3120]
    bs2_mask    = [3103,3109,3115,3121]
    bc          = [3104,3110,3116,3122]
    bd          = [3105,3111,3117,3123]
    od          = [3200,3201,3202,3203,3204,3205,3206,3207,3208,3209,3210,3211,3212,3213,3214,3215]

# ---------------------------------------------------------------------
# Thread information

class Thread:
    count = 8
    start = [0]    * count
    end   = [1023] * count
    base_offset = int(1024 / count) - ceil(MEMMAP.normal / count)

Thread.default_offset = [(Thread.base_offset * thread) for thread in range(Thread.count)]
Thread.normal_mem_start = [(MEMMAP.normal + Thread.default_offset[thread]) for thread in range(Thread.count)]

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
    mem           = create_memory(1024, 36)
    here          = -1
    last          = 0
    write_names   = {}
    write_offset  = 3072
    filename      = "I.mem"

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
    if len(addresses) > 1:
        print("ERROR: Cannot resolve multiple identical write names: {0}".format(name))
        sys.exit(1)
    if len(addresses) == 0:
        return None
    return addresses[0]

def lookup_read(name, mem):
    if type(name) == type(int()):
        return name
    address = mem.read_names.get(name, None)
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
    condition_format    = 'uint:{0},uint:{1},uint:{2}'.format(Branch.A_flag_width, Branch.B_flag_width, Branch.AB_operator_width)
    branch_format       = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5}'.format(Branch.origin_width, Branch.origin_enable_width, Branch.destination_width, Branch.predict_taken_width, Branch.predict_enable_width, Branch.condition_width)
    conditions          = {} # {name:bits}
    unresolved_branches = [] # list of parameters to br()

def condition(mem_obj, name, A_flag, B_flag, AB_operator):
    condition = BitArray()
    for entry in [A_flag, B_flag, AB_operator]:
        condition.append(entry)
    mem_obj.conditions.update({name:condition}) 

def branch(origin, origin_enable, destination, predict_taken, predict_enable, condition_name):
    condition           = BD.conditions[condition_name]
    origin_bits         = BitArray(uint=origin, length=Branch.origin_width)
    destination_bits    = BitArray(uint=destination, length=Branch.destination_width)
    config = BitArray()
    for entry in [origin_bits, origin_enable, destination_bits, predict_taken, predict_enable, condition]:
        config.append(entry)
    return config

def bt(destination):
    loc(I, destination, write_addr = I.here)

def br(condition, destination, predict, storage, origin_enable = True, origin = None):
    if origin is None:
        origin      = I.here
    dest_addr = lookup_write(destination, [I])
    if dest_addr is None:
        BD.unresolved_branches.append([condition, destination, predict, storage, origin_enable, origin])    
        return
    if predict is True:
        predict         = Branch.predict_taken
        predict_enable  = Branch.predict_enabled
    elif predict is False:
        predict         = Branch.predict_not_taken
        predict_enable  = Branch.predict_enabled
    elif predict is None:
        predict         = Branch.predict_not_taken
        predict_enable  = Branch.predict_disabled
    else:
        printf("Invalid branch prediction setting on branch {0}.".format(storage))
        sys.exit(1)
    if origin_enable is True:
        origin_enable = Branch.origin_enabled
    elif origin_enabled is False:
        origin_enable = Branch.origin_disabled
    else:
        printf("Invalid branch origin enabled setting on branch {0}.".format(storage))
        sys.exit(1)
    branch_config = branch(origin, origin_enable, dest_addr, predict, predict_enable, condition)
    # Works because a loc() usually sets both read/write addresses
    # and the read address is the local, absolute location in memory
    # (write address is offset to the global memory map)
    if (storage in A.write_names):
        address = A.read_names[storage]
        for thread in range(Thread.count):
            offset = Thread.default_offset[thread]
            A.mem[address+offset] = branch_config
    elif (storage in B.write_names):
        address = B.read_names[storage]
        for thread in range(Thread.count):
            offset = Thread.default_offset[thread]
            B.mem[address+offset] = branch_config
    else:
        printf("Invalid storage location on branch {0}.".format(storage))
        sys.exit(1)

def resolve_forward_branches():
    for entry in BD.unresolved_branches:
        br(*entry)

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

# This should be 10 for A/B memories, but readmemh() expects an
# integral hex number, so 10 or 12 bits represents the same.
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

po_offset_bits_A        = 10
po_offset_bits_B        = 10
po_offset_bits_DA       = 12
po_offset_bits_DB       = 12

class PO:

    po_entries              = 4
    po_increment_bits       = 4
    po_increment_sign_bits  = 1

    def __init__(self, filename, target_mem_obj, offset_width):
        self.target_mem_obj = target_mem_obj
        self.offset_width   = offset_width
        self.total_width    = self.po_increment_sign_bits + self.po_increment_bits + offset_width
        self.mem            = create_memory(Thread.count*self.po_entries, self.total_width)
        self.filename       = filename

    def gen_read_po(self, thread, po_entry, target_name, increment):
        offset = lookup_read(target_name, self.target_mem_obj) + Thread.default_offset[thread] - MEMMAP.indirect[po_entry]
        if increment >= 0:
            sign = 0
        else:
            sign = 1
        sign        = BitArray(uint=sign,      length=self.po_increment_sign_bits)
        increment   = BitArray(uint=increment, length=self.po_increment_bits)
        offset      = BitArray(uint=offset,    length=self.offset_width)
        po          = BitArray()
        for field in [sign, increment, offset]:
            po.append(field)
        return po

    def set_po(self, thread, entry, po):
        if entry < 0 or entry > self.po_entries-1:
            print("Out of bounds PO entry: {0}".format(entry))
            sys.exit(1)
        address = entry + (thread*self.po_entries)
        print(address, po)
        self.mem[address] = po;

PO_A  = PO("PO_A.mem", A, po_offset_bits_A)
PO_B  = PO("PO_B.mem", B, po_offset_bits_B)
PO_DA = PO("PO_DA.mem", A, po_offset_bits_DA)
PO_DB = PO("PO_DB.mem", B, po_offset_bits_DB)

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# Quick test

initializable_memories = [A,B,I,OD,DO,PO_A,PO_B,PO_DA,PO_DB,PC,PC_prev]

def dump_all(mem_obj_list):
    for mem in mem_obj_list:
        file_dump(mem)

# Set these in init memory so we don't have to do a tedious once-run
# init sequence for the Default Offsets. These normally never change at runtime.
def init_DO(DO = DO):
    for thread in range(Thread.count):
        set_do(DO, thread, Thread.default_offset[thread])

def init_PC(PC = PC, PC_prev = PC_prev):
    for thread in range(Thread.count):
        start = Thread.start[thread]
        set_pc(PC,      thread, start)
        set_pc(PC_prev, thread, start)

def init_ISA(OD = OD, MEMMAP = MEMMAP):
    define_opcode(OD, "NOP", ALU.split_no, ALU.shift_none, Dyadic.always_zero, ALU.addsub_a_plus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "ADD", ALU.split_no, ALU.shift_none, Dyadic.b, ALU.addsub_a_plus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "SUB", ALU.split_no, ALU.shift_none, Dyadic.b, ALU.addsub_a_minus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "PSR", ALU.split_no, ALU.shift_none, Dyadic.a, ALU.addsub_a_plus_b, ALU.simple, Dyadic.always_one, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "ADD*2", ALU.split_no, ALU.shift_left, Dyadic.b, ALU.addsub_a_minus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "ADD/2", ALU.split_no, ALU.shift_right_signed, Dyadic.b, ALU.addsub_a_plus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    define_opcode(OD, "ADD/2U", ALU.split_no, ALU.shift_right, Dyadic.b, ALU.addsub_a_plus_b, ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    for thread in range(Thread.count):
        load_opcode(OD, thread, "NOP",    0)
        load_opcode(OD, thread, "ADD",    1)
        load_opcode(OD, thread, "SUB",    2)
        load_opcode(OD, thread, "ADD*2",  3)
        load_opcode(OD, thread, "ADD/2",  4)
        load_opcode(OD, thread, "ADD/2U", 5)
        load_opcode(OD, thread, "PSR",    6)

def init_BD(BD = BD):
    # Jump always
    condition(BD, "JMP", Branch.A_flag_negative, Branch.B_flag_lessthan, Dyadic.always_one)
    # Jump on Branch Sentinel A match
    condition(BD, "BSA", Branch.A_flag_sentinel, Branch.B_flag_lessthan, Dyadic.a)
    # Jump on Counter reaching Zero (not running)
    condition(BD, "CTZ", Branch.A_flag_negative, Branch.B_flag_counter, Dyadic.not_b)

def init_A(A = A, MEMMAP = MEMMAP):
    align(A, 0)
    lit(A, 0), loc(A, "zeroA")

    align(A, MEMMAP.pool[0])
    lit(A, 1), loc(A, "oneA")

    align(A, MEMMAP.indirect[0])
    lit(A, 0), loc(A, "seed_ptrA")

    align(A, Thread.normal_mem_start[0])
    lit(A, 0), loc(A, "seedA")
    data(A, [11]*6, "seeds")

    align(A, Thread.normal_mem_start[1])
    lit(A, 0)
    data(A, [11]*6)

    align(A, Thread.normal_mem_start[2])
    lit(A, 0)
    data(A, [11]*6)

    align(A, Thread.normal_mem_start[3])
    lit(A, 0)
    data(A, [11]*6)

    align(A, Thread.normal_mem_start[4])
    lit(A, 0)
    data(A, [11]*6)

    align(A, Thread.normal_mem_start[5])
    lit(A, 0)
    data(A, [11]*6)

    align(A, Thread.normal_mem_start[6])
    lit(A, 0)
    data(A, [11]*6)

    align(A, Thread.normal_mem_start[7])
    lit(A, 0)
    data(A, [11]*6)

def init_B(B = B, MEMMAP = MEMMAP):
    align(B, 0)
    lit(B, 0), loc(B, "zeroB")

    align(B, MEMMAP.pool[0])
    lit(B, 1), loc(B, "oneB")
    lit(B, 6), loc(B, "sixB")
    lit(B, 0xFFFFFFFFE), loc(B, "all_but_LSB_mask")
    lit(B, 0), loc(B, "restart_test")
    lit(B, 0), loc(B, "next_test")
    lit(B, 0), loc(B, "even_test")
    lit(B, 0), loc(B, "output_test")

    align(B, Thread.normal_mem_start[0])
    lit(B, 0), loc(B, "nextseedB")
    lit(B, PO_A.gen_read_po(0, 0, "seeds", 1)), loc(B, "seed_ptrA_init_read")
    lit(B, PO_DA.gen_read_po(0, 0, "seeds", 1)), loc(B, "seed_ptrA_init_write")

    align(B, Thread.normal_mem_start[1])
    lit(B, 0)
    lit(B, PO_A.gen_read_po(1, 0, "seeds", 1))
    lit(B, PO_DA.gen_read_po(1, 0, "seeds", 1))

    align(B, Thread.normal_mem_start[2])
    lit(B, 0)
    lit(B, PO_A.gen_read_po(2, 0, "seeds", 1))
    lit(B, PO_DA.gen_read_po(2, 0, "seeds", 1))

    align(B, Thread.normal_mem_start[3])
    lit(B, 0)
    lit(B, PO_A.gen_read_po(3, 0, "seeds", 1))
    lit(B, PO_DA.gen_read_po(3, 0, "seeds", 1))

    align(B, Thread.normal_mem_start[4])
    lit(B, 0)
    lit(B, PO_A.gen_read_po(4, 0, "seeds", 1))
    lit(B, PO_DA.gen_read_po(4, 0, "seeds", 1))

    align(B, Thread.normal_mem_start[5])
    lit(B, 0)
    lit(B, PO_A.gen_read_po(5, 0, "seeds", 1))
    lit(B, PO_DA.gen_read_po(5, 0, "seeds", 1))

    align(B, Thread.normal_mem_start[6])
    lit(B, 0)
    lit(B, PO_A.gen_read_po(6, 0, "seeds", 1))
    lit(B, PO_DA.gen_read_po(6, 0, "seeds", 1))

    align(B, Thread.normal_mem_start[7])
    lit(B, 0)
    lit(B, PO_A.gen_read_po(7, 0, "seeds", 1))
    lit(B, PO_DA.gen_read_po(7, 0, "seeds", 1))

def init_I(I = I, PC = PC):
    align(I, Thread.start[0])

    simple(I, 0, "ADD", MEMMAP.bd[0],           "zeroA",        "restart_test"), bt("restart")
    simple(I, 0, "ADD", MEMMAP.bc[0],           "zeroA",        "sixB")
    simple(I, 0, "ADD", MEMMAP.bd[2],           "zeroA",        "even_test"),
    simple(I, 0, "ADD", MEMMAP.bs1_sentinel[2], "zeroA",        "zeroB"),
    simple(I, 0, "ADD", MEMMAP.bs1_mask[2],     "zeroA",        "all_but_LSB_mask"),
    simple(I, 0, "ADD", MEMMAP.bd[3],           "zeroA",        "output_test"),
    simple(I, 0, "ADD", MEMMAP.a_po[0],         "zeroA",        "seed_ptrA_init_read")
    simple(I, 0, "ADD", MEMMAP.da_po[0],        "zeroA",        "seed_ptrA_init_write"),
    simple(I, 0, "ADD", MEMMAP.bd[1],           "zeroA",        "next_test"),

    #simple(I, 0, "NOP", "zeroA",                "zeroA",        "zeroB")

    # Load x
    simple(I, 0, "ADD",     "seedA",        "seed_ptrA",     "zeroB"),      bt("next_seed")

    # Odd case y = (3x+1)/2
    simple(I, 0, "ADD*2",   "nextseedB",    "seedA",        "zeroB"),       br("BSA", "even_case", False, "even_test")  # y = (x+0)*2
    simple(I, 0, "ADD",     "nextseedB",    "seedA",        "nextseedB"),                                               # y = (x+y)
    simple(I, 0, "ADD/2U",  "nextseedB",    "oneA",         "nextseedB"),   br("JMP", "output", True, "output_test")    # y = (1+y)/2

    # Even case y = x/2
    simple(I, 0, "ADD/2U",  "nextseedB",    "seedA",        "zeroB"),       bt("even_case")                             # y = (x+0)/2
    simple(I, 0, "NOP",     "zeroA",        "zeroA",        "zeroB")
    simple(I, 0, "NOP",     "zeroA",        "zeroA",        "zeroB")

    # Store y (replace x)
    simple(I, 0, "ADD",     "seed_ptrA",    "zeroA",        "nextseedB"),   bt("output"), br("CTZ", "restart", None, "restart_test"), br("JMP", "next_seed", None, "next_test")

    align(I, Thread.start[1])

    align(I, Thread.start[2])

    align(I, Thread.start[3])

    align(I, Thread.start[4])

    align(I, Thread.start[5])

    align(I, Thread.start[6])

    align(I, Thread.start[7])

    resolve_forward_branches()

# ---------------------------------------------------------------------

if __name__ == "__main__":
    init_DO()
    init_PC()
    init_ISA()
    init_BD()
    init_A()
    init_B()
    init_I()
    dump_all(initializable_memories)

