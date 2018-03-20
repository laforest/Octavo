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

class Base_Memory:

    def create_memory(self, depth, width):
        self.mem = []
        for entry in range(depth):
            self.mem.append(BitArray(width))

    def __init__(self, depth, width, filename):
        self.create_memory(depth, width)
        self.filename   = filename
        
    def dump_format(self, width):
        """Numbers must be represented as zero-padded whole hex numbers"""
        characters = width // 4
        remainder = width % 4
        characters += min(1, remainder)
        format_string = "{:0" + str(characters) + "x}"
        return format_string

    def file_dump(self):
        """Dump to Verilog loadable format for readmemh()."""
        file_header  = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""
        with open(self.filename, 'w') as f:
            f.write(file_header + "\n")
            # We assume all memory values are the same width
            format_string = self.dump_format(self.mem[0].length)
            for entry in self.mem:
                output = format_string.format(entry.uint)
                f.write(output + "\n")


class Data_Memory(Base_Memory):

    def __init__(self, depth, width, filename, write_offset):
        Base_Memory.__init__(self, depth, width, filename)
        self.here           = -1
        self.last           = 0
        self.read_names     = {}
        self.write_names    = {}
        self.write_offset   = write_offset

    # ---------------------------------------------------------------------
    # Location naming and lookup

    def loc(self, name, read_addr = None, write_addr = None):
        """Name a given location. May have only a read or write address, or both.
           If neither addresses are given, then name the current location, 
           after 'here' was incremented by another operation."""
        if read_addr is not None:
            if read_addr < 0 or read_addr > len(self.mem)-1:
                print("ERROR: Out of bounds name read address ({0}) assignment in {1}".format(read_addr, self.__name__))
                sys.exit(1)
            self.read_names.update({name:read_addr})
        if write_addr is None and read_addr is not None:
            # No bounds check here as write address can be over a different range, depending on where Memory is mapped.
            write_addr = read_addr + self.write_offset
        if write_addr is not None:
            self.write_names.update({name:write_addr})
        if write_addr is None and read_addr is None:
            if self.here < 0 or self.here > len(self.mem)-1:
                print("ERROR: Out of bounds name ({0}) in {1}".format(self.here, self.__name__))
            self.loc(name, read_addr = self.here)

    def lookup_read(self, name):
        if type(name) == type(int()):
            return name
        address = self.read_names.get(name, None)
        return address

    def lookup_write(self, name):
        if type(name) == type(int()):
            return name
        address = self.write_names.get(name, None)
        return address

    # ---------------------------------------------------------------------
    # Compile literals at locations (basic assembler mechanism and state)

    def align(self, addr):
        """Continue assembling at new address. Assumes pre-incrementing 'here'"""
        if type(addr) == str:
            addr = self.read_addr[addr]
        if addr < 0 or addr > len(self.mem)-1:
            print("ERROR: Out of bounds align ({0}) in {1}".format(self.here, self.__name__))
        if addr > self.last:
            self.last = addr
        self.here = addr - 1

    def resume(self):
        """Resume assembling at first free sequential location after an align()."""
        self.here = self.last - 1

    def lit(self, number):
        """Place a literal number 'here'"""
        self.here += 1
        if self.here < 0 or self.here > len(self.mem)-1:
            print("ERROR: Out of bounds lit ({0}) in {1}".format(self.here, self.__class__.__name__))
        if self.here >= self.last:
            self.last = self.here + 1
        word_length = self.mem[self.here].length
        if type(number) == type(int()):
            self.mem[self.here] = BitArray(uint=number, length=word_length)
        elif type(number) == type(BitArray()):
            # Oh, this is ugly. BitArray's LSB is our MSB...
            self.mem[self.here].overwrite(number,(word_length-number.length))
        else:
            printf("Incompatible literal type: {0}".format(number))
            sys.exit(1)

    def data(self, entries, name = None):
        """Place a list of numbers into consecutive locations.
           Optionally name the head of the list."""
        if len(entries) == 0:
            print("ERROR: Empty data list for {0}".format(self.__name__))
        if name is not None:
            head = entries.pop(0)
            self.lit(head)
            self.loc(name)
        for entry in entries:
            self.lit(entry)

# ---------------------------------------------------------------------
# Create the Data Memories

A = Data_Memory(1024, 36, "A.mem", MEMMAP.a)
B = Data_Memory(1024, 36, "B.mem", MEMMAP.b)

# ---------------------------------------------------------------------
# Thread information

class Thread:

    def __init__(self, thread_count, data_mem_depth, start_of_private_data):
        self.count = thread_count
        self.start = [0] * self.count
        self.base_offset = int(data_mem_depth / self.count) - ceil(start_of_private_data / self.count)
        self.default_offset = [(self.base_offset * thread) for thread in range(self.count)]
        self.normal_mem_start = [(start_of_private_data + self.default_offset[thread]) for thread in range(self.count)]

T = Thread(8, 1024, MEMMAP.normal)

# ---------------------------------------------------------------------
# Opcode Decoder Memory: translate opcode into ALU control bits

class Opcode_Decoder(Base_Memory):

    opcode_count        = 16
    alu_control_format  = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5},uint:{6},uint:{7}'.format(ALU.split_width, ALU.shift_width, ALU.dyadic3_width, ALU.addsub_width, ALU.dual_width, ALU.dyadic2_width, ALU.dyadic1_width, ALU.select_width)

    def __init__(self, filename):
        depth = self.opcode_count * T.count
        width = ALU.total_op_width
        Base_Memory.__init__(self, depth, width, filename)
        self.opcodes   = {} # {name:bits}

    def define_opcode(self, name, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        """Assembles and names the control bits of an opcode."""
        control_bits = BitArray()
        for entry in [split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select]:
            control_bits.append(entry)
        self.opcodes.update({name:control_bits})

    def load_opcode(self, thread, name, opcode):
        """The opcode indexes into the opcode decoder memory, separately for each thread."""
        address = (thread * self.opcode_count) + opcode
        self.mem[address] = self.opcodes[name]

    def lookup_opcode(self, thread, name):
        """Finds the bit pattern for the named opcode, searches for address of those bits."""
        control_bits = self.opcodes[name]
        op_zero = (thread * self.opcode_count)
        for opcode in range(op_zero, op_zero + self.opcode_count):
            if self.mem[opcode] == control_bits:
                return opcode
        print("Could not find opcode named {0} in thread {1}".format(name, thread))
        sys.exit(1)
    
OD = Opcode_Decoder("OD.mem")

# ---------------------------------------------------------------------
# Create the Instruction Memory

class Instruction_Memory(Data_Memory):

    simple_instr_format = 'uint:4,uint:12,uint:10,uint:10'
    dual_instr_format   = 'uint:4,uint:6,uint:6,uint:10,uint:10'

    def __init__(self, depth, width, filename, write_offset, write_mem_list):
        Data_Memory.__init__(self, depth, width, filename, write_offset)
        self.write_mem_list = write_mem_list

    def lookup_writable(self, name):
        """Lookup the write address of a name across the listed writable memories."""
        if type(name) == type(int()):
            return name
        addresses = []
        for entry in self.write_mem_list:
            address = entry.write_names.get(name, None)
            if address is not None:
                addresses.append(address)
        if len(addresses) > 1:
            print("ERROR: Cannot resolve multiple identical write names: {0}".format(name))
            sys.exit(1)
        if len(addresses) == 0:
            return None
        return addresses[0]

    def simple(self, thread, op_name, dest, src1, src2):
        """Assemble a simple instruction"""
        op = OD.lookup_opcode(thread, op_name)
        D_operand = self.lookup_writable(dest)
        A_operand = A.lookup_read(src1)
        B_operand = B.lookup_read(src2)
        instr = pack(self.simple_instr_format, op, D_operand, A_operand, B_operand)
        self.lit(instr.uint)

    def dual(self, thread, op_name, dest1, dest2, src1, src2):
        """Assemble a dual instruction (split addressing mode)"""
        # The CPU re-adds the correct write offset after it decodes the instruction
        # It's a power-of-2 alignment, so it just prepends the right value
        op = OD.lookup_opcode(thread, op_name)
        DA_operand = A.lookup_write(dest1) - A.write_offset
        DB_operand = B.lookup_write(dest2) - B.write_offset
        A_operand  = A.lookup_read(src1)
        B_operand  = B.lookup_read(src2)
        instr = pack(self.dual_instr_format, op, DA_operand, DB_operand, A_operand, B_operand)
        self.lit(instr.uint)

I = Instruction_Memory(1024, 36, "I.mem", MEMMAP.i, [A,B])
I.write_mem_list.append(I)

# ---------------------------------------------------------------------
# Branch Detector


class Branch_Detector:

    branch_count        = 4
    condition_format    = 'uint:{0},uint:{1},uint:{2}'.format(Branch.A_flag_width, Branch.B_flag_width, Branch.AB_operator_width)
    branch_format       = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5}'.format(Branch.origin_width, Branch.origin_enable_width, Branch.destination_width, Branch.predict_taken_width, Branch.predict_enable_width, Branch.condition_width)

    def __init__(self):
        self.conditions          = {} # {name:bits}
        self.unresolved_branches = [] # list of parameters to br()

    def condition(self, name, A_flag, B_flag, AB_operator):
        condition_bits = BitArray()
        for entry in [A_flag, B_flag, AB_operator]:
            condition_bits.append(entry)
        self.conditions.update({name:condition_bits}) 

    def branch(self, origin, origin_enable, destination, predict_taken, predict_enable, condition_name):
        condition_bits      = self.conditions[condition_name]
        origin_bits         = BitArray(uint=origin, length=Branch.origin_width)
        destination_bits    = BitArray(uint=destination, length=Branch.destination_width)
        config = BitArray()
        for entry in [origin_bits, origin_enable, destination_bits, predict_taken, predict_enable, condition_bits]:
            config.append(entry)
        return config

    def bt(self, destination):
        I.loc(destination, write_addr = I.here)

    def br(self, condition_bits, destination, predict, storage, origin_enable = True, origin = None):
        if origin is None:
            origin      = I.here
        dest_addr = I.lookup_write(destination)
        if dest_addr is None:
            self.unresolved_branches.append([condition_bits, destination, predict, storage, origin_enable, origin])    
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
        branch_config = self.branch(origin, origin_enable, dest_addr, predict, predict_enable, condition_bits)
        # Works because a loc() usually sets both read/write addresses
        # and the read address is the local, absolute location in memory
        # (write address is offset to the global memory map)
        if (storage in A.write_names):
            address = A.read_names[storage]
            for thread in range(T.count):
                offset = T.default_offset[thread]
                A.mem[address+offset] = branch_config
        elif (storage in B.write_names):
            address = B.read_names[storage]
            for thread in range(T.count):
                offset = T.default_offset[thread]
                B.mem[address+offset] = branch_config
        else:
            printf("Invalid storage location on branch {0}.".format(storage))
            sys.exit(1)

    def resolve_forward_branches(self):
        for entry in self.unresolved_branches:
            self.br(*entry)

BD = Branch_Detector()

# ---------------------------------------------------------------------
# Program Counter, current and previous

class Program_Counter(Base_Memory):

    pc_width = 10
    pc_format = 'uint:{0}'.format(pc_width)

    def __init__(self, filename):
        depth = T.count
        width = self.pc_width
        Base_Memory.__init__(self, depth, width, filename)

    def set_pc(self, thread, pc_value):
        pc_value = BitArray(uint=pc_value, length=self.mem[0].length)
        self.mem[thread] = pc_value;

PC      = Program_Counter("PC.mem")
PC_prev = Program_Counter("PC_prev.mem")

# ---------------------------------------------------------------------
# Default Offset Memory


class Default_Offset(Base_Memory):

    # This should be 10 for A/B memories, and 12 for DA/DB, but readmemh()
    # expects an integral hex number, so 10 or 12 bits represents the same.
    do_width = 12 

    def __init__(self, filename):
        depth = T.count
        width = self.do_width
        Base_Memory.__init__(self, depth, width, filename)

    def set_do(self, thread, offset):
        offset = BitArray(uint=offset, length=self.mem[0].length)
        self.mem[thread] = offset;

DO = Default_Offset("DO.mem")

# ---------------------------------------------------------------------
# Programmed Offset Memory

class Programmed_Offset(Base_Memory):

    # Contrary to DO, the offset length matters here, since other
    # data follows it in the upper bits.
    po_offset_bits_A        = 10
    po_offset_bits_B        = 10
    po_offset_bits_DA       = 12
    po_offset_bits_DB       = 12

    po_entries              = 4
    po_increment_bits       = 4
    po_increment_sign_bits  = 1

    def __init__(self, filename, target_mem_obj, offset_width):
        self.target_mem_obj = target_mem_obj
        self.offset_width   = offset_width
        self.total_width    = self.po_increment_sign_bits + self.po_increment_bits + self.offset_width
        depth               = T.count * self.po_entries
        Base_Memory.__init__(self, depth, self.total_width, filename)

    def gen_read_po(self, thread, po_entry, target_name, increment):
        offset = self.target_mem_obj.lookup_read(target_name) + T.default_offset[thread] - MEMMAP.indirect[po_entry]
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
        address = entry + (thread * po_entries)
        print(address, po)
        self.mem[address] = po;

PO_A  = Programmed_Offset("PO_A.mem",  A, Programmed_Offset.po_offset_bits_A)
PO_B  = Programmed_Offset("PO_B.mem",  B, Programmed_Offset.po_offset_bits_B)
PO_DA = Programmed_Offset("PO_DA.mem", A, Programmed_Offset.po_offset_bits_DA)
PO_DB = Programmed_Offset("PO_DB.mem", B, Programmed_Offset.po_offset_bits_DB)

# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# Quick test

initializable_memories = [A,B,I,OD,DO,PO_A,PO_B,PO_DA,PO_DB,PC,PC_prev]

def dump_all(mem_obj_list):
    for mem in mem_obj_list:
        mem.file_dump()

# Set these in init memory so we don't have to do a tedious once-run
# init sequence for the Default Offsets. These normally never change at runtime.
def init_DO():
    for thread in range(T.count):
        DO.set_do(thread, T.default_offset[thread])

def init_PC():
    for thread in range(T.count):
        start = T.start[thread]
        PC.set_pc(thread, start)
        PC_prev.set_pc(thread, start)

def init_ISA():
    OD.define_opcode("NOP",     ALU.split_no, ALU.shift_none,           Dyadic.always_zero, ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define_opcode("ADD",     ALU.split_no, ALU.shift_none,           Dyadic.b,           ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define_opcode("SUB",     ALU.split_no, ALU.shift_none,           Dyadic.b,           ALU.addsub_a_minus_b,   ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define_opcode("PSR",     ALU.split_no, ALU.shift_none,           Dyadic.a,           ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_one,  Dyadic.always_zero, ALU.select_r)
    OD.define_opcode("ADD*2",   ALU.split_no, ALU.shift_left,           Dyadic.b,           ALU.addsub_a_minus_b,   ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define_opcode("ADD/2",   ALU.split_no, ALU.shift_right_signed,   Dyadic.b,           ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    OD.define_opcode("ADD/2U",  ALU.split_no, ALU.shift_right,          Dyadic.b,           ALU.addsub_a_plus_b,    ALU.simple, Dyadic.always_zero, Dyadic.always_zero, ALU.select_r)
    for thread in range(T.count):
        OD.load_opcode(thread, "NOP",    0)
        OD.load_opcode(thread, "ADD",    1)
        OD.load_opcode(thread, "SUB",    2)
        OD.load_opcode(thread, "ADD*2",  3)
        OD.load_opcode(thread, "ADD/2",  4)
        OD.load_opcode(thread, "ADD/2U", 5)
        OD.load_opcode(thread, "PSR",    6)

def init_BD():
    # Jump always
    BD.condition("JMP", Branch.A_flag_negative, Branch.B_flag_lessthan, Dyadic.always_one)
    # Jump on Branch Sentinel A match
    BD.condition("BSA", Branch.A_flag_sentinel, Branch.B_flag_lessthan, Dyadic.a)
    # Jump on Counter reaching Zero (not running)
    BD.condition("CTZ", Branch.A_flag_negative, Branch.B_flag_counter, Dyadic.not_b)

def init_A():
    A.align(0)
    A.lit(0), A.loc("zeroA")

    A.align(MEMMAP.pool[0])
    A.lit(1), A.loc("oneA")

    A.align(MEMMAP.indirect[0])
    A.lit(0), A.loc("seed_ptrA")

    A.align(T.normal_mem_start[0])
    A.lit(0), A.loc("seedA")
    A.data([11]*6, "seeds")

    A.align(T.normal_mem_start[1])
    A.lit(0)
    A.data([11]*6)

    A.align(T.normal_mem_start[2])
    A.lit(0)
    A.data([11]*6)

    A.align(T.normal_mem_start[3])
    A.lit(0)
    A.data([11]*6)

    A.align(T.normal_mem_start[4])
    A.lit(0)
    A.data([11]*6)

    A.align(T.normal_mem_start[5])
    A.lit(0)
    A.data([11]*6)

    A.align(T.normal_mem_start[6])
    A.lit(0)
    A.data([11]*6)

    A.align(T.normal_mem_start[7])
    A.lit(0)
    A.data([11]*6)


def init_B():
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

    B.align(T.normal_mem_start[0])
    B.lit(0),                                   B.loc("nextseedB")
    B.lit(PO_A.gen_read_po(0, 0, "seeds", 1)),  B.loc("seed_ptrA_init_read")
    B.lit(PO_DA.gen_read_po(0, 0, "seeds", 1)), B.loc("seed_ptrA_init_write")

    B.align(T.normal_mem_start[1])
    B.lit(0)
    B.lit(PO_A.gen_read_po(1, 0, "seeds", 1))
    B.lit(PO_DA.gen_read_po(1, 0, "seeds", 1))

    B.align(T.normal_mem_start[2])
    B.lit(0)
    B.lit(PO_A.gen_read_po(2, 0, "seeds", 1))
    B.lit(PO_DA.gen_read_po(2, 0, "seeds", 1))

    B.align(T.normal_mem_start[3])
    B.lit(0)
    B.lit(PO_A.gen_read_po(3, 0, "seeds", 1))
    B.lit(PO_DA.gen_read_po(3, 0, "seeds", 1))

    B.align(T.normal_mem_start[4])
    B.lit(0)
    B.lit(PO_A.gen_read_po(4, 0, "seeds", 1))
    B.lit(PO_DA.gen_read_po(4, 0, "seeds", 1))

    B.align(T.normal_mem_start[5])
    B.lit(0)
    B.lit(PO_A.gen_read_po(5, 0, "seeds", 1))
    B.lit(PO_DA.gen_read_po(5, 0, "seeds", 1))

    B.align(T.normal_mem_start[6])
    B.lit(0)
    B.lit(PO_A.gen_read_po(6, 0, "seeds", 1))
    B.lit(PO_DA.gen_read_po(6, 0, "seeds", 1))

    B.align(T.normal_mem_start[7])
    B.lit(0)
    B.lit(PO_A.gen_read_po(7, 0, "seeds", 1))
    B.lit(PO_DA.gen_read_po(7, 0, "seeds", 1))


def init_I():
    I.align(T.start[0])

    I.simple(0, "ADD", MEMMAP.bd[0],           "zeroA",        "restart_test"), BD.bt("restart")
    I.simple(0, "ADD", MEMMAP.bc[0],           "zeroA",        "sixB")
    I.simple(0, "ADD", MEMMAP.bd[2],           "zeroA",        "even_test"),
    I.simple(0, "ADD", MEMMAP.bs1_sentinel[2], "zeroA",        "zeroB"),
    I.simple(0, "ADD", MEMMAP.bs1_mask[2],     "zeroA",        "all_but_LSB_mask"),
    I.simple(0, "ADD", MEMMAP.bd[3],           "zeroA",        "output_test"),
    I.simple(0, "ADD", MEMMAP.a_po[0],         "zeroA",        "seed_ptrA_init_read")
    I.simple(0, "ADD", MEMMAP.da_po[0],        "zeroA",        "seed_ptrA_init_write"),
    I.simple(0, "ADD", MEMMAP.bd[1],           "zeroA",        "next_test"),

    #I.simple(0, "NOP", "zeroA",                "zeroA",        "zeroB")

    # Load x
    I.simple(0, "ADD",     "seedA",        "seed_ptrA",     "zeroB"),      BD.bt("next_seed")

    # Odd case y = (3x+1)/2
    I.simple(0, "ADD*2",   "nextseedB",    "seedA",        "zeroB"),       BD.br("BSA", "even_case", False, "even_test")    # y = (x+0)*2
    I.simple(0, "ADD",     "nextseedB",    "seedA",        "nextseedB"),                                                    # y = (x+y)
    I.simple(0, "ADD/2U",  "nextseedB",    "oneA",         "nextseedB"),   BD.br("JMP", "output", True, "output_test")      # y = (1+y)/2

    # Even case y = x/2
    I.simple(0, "ADD/2U",  "nextseedB",    "seedA",        "zeroB"),       BD.bt("even_case")                               # y = (x+0)/2
    I.simple(0, "NOP",     "zeroA",        "zeroA",        "zeroB")
    I.simple(0, "NOP",     "zeroA",        "zeroA",        "zeroB")

    # Store y (replace x)
    I.simple(0, "ADD",     "seed_ptrA",    "zeroA",        "nextseedB"),   BD.bt("output"), BD.br("CTZ", "restart", None, "restart_test"), BD.br("JMP", "next_seed", None, "next_test")

    I.align(T.start[1])

    I.align(T.start[2])

    I.align(T.start[3])

    I.align(T.start[4])

    I.align(T.start[5])

    I.align(T.start[6])

    I.align(T.start[7])

    BD.resolve_forward_branches()

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

