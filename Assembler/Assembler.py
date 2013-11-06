#! /usr/bin/python

import pprint
import math

# Opcodes
XOR, AND, OR, SUB, ADD, UND1, UND2, UND3, MHS, MLS, MHU, JMP, JZE, JNZ, JPO, JNE = range(16)

class Memory:
    def width_mask(self, width):
        return (1 << width) - 1

    def format_dump(self, entry):
        width = int(math.ceil(self.mem_width / 4.0))
        format_string = "{:0" + str(width) + "x}"
        return format_string.format(entry)

    def file_dump(self):
        with open(self.file_name, 'w') as f:
            f.write(self.file_header + "\n")
            for entry in self.data:
                output = self.format_dump(entry)
                f.write(output + "\n")

    def ALIGN(self, addr):
        """Continue assembling at new address."""
        self.here = addr

    def N(self, name):
        """Name current location"""
        self.names.update({name:(self.here - 1)})

    def L(self, number):
        """Assemble a literal number"""
        self.data[self.here] = number & self.mem_mask
        self.here += 1

    def lookup(self, entry):
        if type(entry) == type(str()):
            return self.names[entry]
        return entry

    def I(self, OP, D, A, B):
        """Assemble an instruction"""
        D = self.lookup(D)
        A = self.lookup(A)
        B = self.lookup(B)
        instr  = ((OP & self.OP_mask) << self.OP_shift) 
        instr |= ((D  & self.D_mask)  << self.D_shift) 
        instr |= ((A  & self.A_mask)  << self.A_shift) 
        instr |= ((B  & self.B_mask)  << self.B_shift)
        self.L(instr)

    def RL(self, name):
        """Resolve Literal: set named location to current address"""
        address = self.names[name]
        self.data[address] = self.here - 1

    def RD(self, name):
        """Set *empty* D field at named address with current address"""
        address = self.names[name]
        self.data[address] |= ((self.here - 1) & self.D_mask) << self.D_shift

    def RA(self, name):
        """Set *empty* A field at named address with current address"""
        address = self.names[name]
        self.data[address] |= ((self.here - 1) & self.A_mask) << self.A_shift

    def RB(self, name):
        """Set *empty* B field at named address with current address"""
        address = self.names[name]
        self.data[address] |= ((self.here - 1) & self.B_mask) << self.B_shift

    def offset_write(self, addr):
        return (addr + self.write_offset) & self.D_mask

    def add_write_port(self, name, addr):
        self.names.update({name:self.offset_write(addr)})

    def add_read_port(self, name, addr):
        self.names.update({name:addr})

    def add_port_pair(self, read_name, write_name, addr):
        self.add_read_port(read_name, addr)
        self.add_write_port(write_name, addr)

    def NOP(self):
        self.I(XOR, 0, 0, 0)

    def __init__(self,  file_name,
                        depth        = 1024, 
                        write_offset = 0,
                        word_width   = 36,
                        mem_width    = 36):
        self.A_width        = 10
        self.B_width        = 10
        self.D_width        = 12
        self.OP_width       = 4
        self.word_width     = self.OP_width + self.D_width + self.A_width + self.B_width

        self.mem_width      = self.word_width

        self.depth          = 2**self.A_width # Normally, 1024 words
        self.B_shift        = 0
        self.A_shift        = self.A_width
        self.D_shift        = self.A_shift + self.B_width
        self.OP_shift       = self.D_shift + self.D_width

        self.depth          = depth
        self.write_offset   = write_offset
        self.file_name      = file_name
        self.word_width     = word_width
        self.mem_width      = mem_width

        self.A_mask         = self.width_mask(self.A_width)
        self.B_mask         = self.width_mask(self.B_width)
        self.D_mask         = self.width_mask(self.D_width)
        self.OP_mask        = self.width_mask(self.OP_width)
        self.word_mask      = self.width_mask(self.word_width)
        self.mem_mask       = self.width_mask(self.mem_width)
        self.data           = [(0 & self.mem_mask)] * self.depth

        self.names          = {}
        self.here           = 0

        self.file_header    = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""


class PC_Memory(Memory):
    def pack2(self, msw, lsw):
        upper =  ((msw & self.word_mask) << self.word_width) 
        lower =   (lsw & self.word_mask) 
        return (upper | lower) & self.mem_mask

    def set_pc(self, start, name):
        # next and current PCs
        self.L(self.pack2(start, start)), self.N(name)

    def get_pc(self, name):
        # Both next and current PC are the same initially
        return self.data[self.names[name]] & self.word_mask

#if __name__ == "__main__":
#    pc = Memory("test.PC", depth = 10, word_width = 10, mem_width = 20)
#    pc.L(pc.pack2(1,1)),     pc.N("THREAD0_START")
#    pc.L(pc.pack2(16,16)),   pc.N("THREAD1_START")
#    pc.L(pc.pack2(32,32)),   pc.N("THREAD2_START")
#    pc.L(pc.pack2(48,48)),   pc.N("THREAD3_START")
#    pc.L(pc.pack2(64,64)),   pc.N("THREAD4_START")
#    pc.L(pc.pack2(80,80)),   pc.N("THREAD5_START")
#    pc.L(pc.pack2(96,96)),   pc.N("THREAD6_START")
#    pc.L(pc.pack2(112,112)), pc.N("THREAD7_START")
#    pc.file_dump()
#
