#! /usr/bin/python

from opcodes import *

class Memory:
    "A basic Memory capable of assembling literals, naming locations, and dumping its contents into a format $readmemh can use."

    def width_mask(self, width):
        return (1 << width) - 1

    def dump_format(self):
        "Numbers must be represented as zero-padded whole hex numbers" 
        characters = self.width // 4
        remainder = self.width % 4
        characters += min(1, remainder)
        format_string = "{:0" + str(characters) + "x}"
        return format_string

    def find_unresolved(self):
        unresolved = []
        for key, value in self.names.items():
            if value == -1:
                unresolved.append(key)
        assert len(unresolved) == 0,  "ERROR: Unresolved references in {0}?: {1}".format(self.__class__.__name__, unresolved)   

    def file_dump(self):
        self.find_unresolved()
        with open(self.file_name + self.file_ext, 'w') as f:
            f.write(self.file_header + "\n")
            format_string = self.dump_format()
            for entry in self.data:
                output = format_string.format(entry)
                f.write(output + "\n")

    def ALIGN(self, addr):
        """Continue assembling at new address. Assumes pre-incr 'here'"""
        self.here = addr - 1

    def N(self, name):
        """Name current location. Must place after L."""
        self.names.update({name:(self.here)})

    def L(self, number):
        """Assemble a literal number"""
        self.here += 1
        self.data[self.here] = number & self.mask

    def __init__(self, file_name, file_ext = ".MEM", depth = 1024, width = 36, write_offset = 0):
        self.file_name    = file_name
        self.file_ext     = file_ext
        self.depth        = depth
        self.width        = width
        self.write_offset = write_offset
        self.mask         = self.width_mask(self.width)
        self.data         = [(0 & self.mask)] * self.depth
        self.names        = {}
        self.here         = -1
        # Lifted from Modelsim's output of $writememh
        self.file_header  = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""



class Instruction_Memory(Memory):
    "Extends Memory to assemble instructions, and resolve forward name/field references"

    def lookup_read(self, entry):
        """Shortcut to dereference local names into read addresses."""
        if type(entry) == type(int()):
            return entry

        if type(entry) == type(str()):
            mem = self
            name = entry

        if type(entry) == type(tuple()):
            assert len(entry) == 2, "ERROR: Address tuple {0} must be of format (mem, name).".format(entry)
            mem, name = entry

        try:
            addr = mem.names[name]
        except KeyError:
            # Assume it's a forward reference
            addr = -1
            mem.names.update({name:addr})
        return addr

    def lookup_write(self, entry):
        "Tack on write address offset for (mem, name) references"
        addr = self.lookup_read(entry)
        if type(entry) == type(tuple()):
            mem, name = entry
            addr += mem.write_offset
        return addr 

    def I(self, OP, D, A, B):
        """Assemble an instruction"""
        D = self.lookup_write(D)
        A = self.lookup_read(A)
        B = self.lookup_read(B)
        # print OP, D, A, B
        instr  = ((OP & self.OP_mask) << self.OP_shift) 
        instr |= ((D  & self.D_mask)  << self.D_shift) 
        instr |= ((A  & self.A_mask)  << self.A_shift) 
        instr |= ((B  & self.B_mask)  << self.B_shift)
        self.L(instr)

    def RL(self, name):
        """Resolve Literal: set named locatfile_name, depth = 1024, width = 36ion to current address"""
        address = self.names[name]
        self.data[address] = self.here

    # XXX clear field before setting

    def RD(self, name):
        """Set *empty* D field at named address with current address"""
        address = self.names[name]
        self.data[address] |= (self.here & self.D_mask) << self.D_shift

    def RA(self, name):
        """Set *empty* A field at named address with current address"""
        address = self.names[name]
        self.data[address] |= (self.here & self.A_mask) << self.A_shift

    def RB(self, name):
        """Set *empty* B field at named address with current address"""
        address = self.names[name]
        self.data[address] |= (self.here & self.B_mask) << self.B_shift

    # Never change this encoding. NOP must be all zero, and zero-out location 0
    def NOP(self):
        self.I(XOR, 0, 0, 0)

    def __init__(self, file_name, file_ext = ".I", depth = 1024, width = 36, OP_width = 4, D_width = 12, A_width = 10, B_width = 10, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)
        self.OP_width       = OP_width
        self.D_width        = D_width
        self.A_width        = A_width
        self.B_width        = B_width
        self.instr_width    = OP_width + D_width + A_width + B_width

        assert self.instr_width <= self.width, "ERROR: Instruction width {0} greater than Memory word width {1}".format(self.instr_width, self.width)

        self.B_shift        = 0
        self.A_shift        = A_width
        self.D_shift        = self.A_shift + B_width
        self.OP_shift       = self.D_shift + D_width

        self.OP_mask        = self.width_mask(OP_width)
        self.D_mask         = self.width_mask(D_width)
        self.A_mask         = self.width_mask(A_width)
        self.B_mask         = self.width_mask(B_width)



class Data_Memory(Instruction_Memory):
    "Extends Instruction_Memory to support I/O ports as names. Done this way so we can assemble code in Data Memory."

    def add_port(self, name, addr):
        self.names.update({name:addr})

    def add_port_pair(self, read_name, write_name, addr):
        self.add_port(read_name, addr)
        self.add_port(write_name, addr)

    def __init__(self, file_name, file_ext = ".AB", depth = 1024, width = 36, OP_width = 4, D_width = 12, A_width = 10, B_width = 10, write_offset = 0):
        Instruction_Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, OP_width = OP_width, D_width = D_width, A_width = A_width, B_width = B_width, write_offset = write_offset)



class PC_Memory(Memory):
    "Program Counter Memory. Packs two words per Memory word."

    def pack2(self, msw, lsw):
        upper =  ((msw & self.word_mask) << self.word_width) 
        lower =   (lsw & self.word_mask) 
        return (upper | lower) & self.mask

    def set_pc(self, start, name):
        # next and current PCs
        self.L(self.pack2(start, start)), self.N(name)

    def get_pc(self, name):
        # Both next and current PC are the same at assemble-time
        return self.data[self.names[name]] & self.word_mask

    def __init__(self, file_name, file_ext = ".PC", depth = 8, width = 20, write_offset = 0, word_width = 10):
        assert word_width > 0, "ERROR: Word width must be > 0 to pack anything into PC memory."
        assert (word_width * 2) <= width, "ERROR: Cannot pack two {1} bit words into a {2} bit memory word".format(word_width, width) 
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)
        self.word_width = word_width
        self.word_mask  = self.width_mask(word_width)



class Default_Offset_Memory(Memory):
    "Default offsets to add to A/B/D operands. One per thread."

    # Change extension to match: s/X/A/ for example.
    def __init__(self, file_name, file_ext = ".XDO", depth = 8, width = 10, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

class Programmed_Offset_Memory(Memory):
    "Programmed offsets to add to A/B/D operands. One per thread."

    # Change extension to match: s/X/A/ for example.
    def __init__(self, file_name, file_ext = ".XPO", depth = 8, width = 10, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

class Increments_Memory(Memory):
    "Increments to A/B/D Programmed Offsets after access. One per thread."

    # Change extension to match: s/X/A/ for example.
    def __init__(self, file_name, file_ext = ".XIN", depth = 8, width = 1, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

