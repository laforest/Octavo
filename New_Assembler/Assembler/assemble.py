#! /usr/bin/python

import pprint

# Opcodes
XOR, AND, OR, SUB, ADD, UND1, UND2, UND3, MHS, MLS, MHU, JMP, JZE, JNZ, JPO, JNE = range(16)

class Memory:
    word_mask       = 0xfffffffff   # 36 bits
    read_addr_mask  = 0x3ff         # 10 bits
    write_addr_mask = 0xfff         # 12 bits
    OP_mask         = 0xf           # 4 bits

    B_shift         = 0
    A_shift         = 10
    D_shift         = A_shift + 10
    OP_shift        = D_shift + 12

    depth           = read_addr_mask + 1    # 1024 words
    write_offset    = 0
    data            = []
    names           = {}
    here            = 0

    def ALIGN(self, addr):
        """Continue assembling at new address."""
        self.here = addr - 1

    def N(self, name):
        """Name current location"""
        self.names.update({name:self.here})

    def L(self, number):
        """Assemble a literal number"""
        self.here += 1
        self.data[self.here] = number

    def I(self, OP, D, A, B):
        """Assemble an instruction"""
        instr  = ((OP & self.OP_mask)         << self.OP_shift) 
        instr |= ((D  & self.write_addr_mask) << self.D_shift) 
        instr |= ((A  & self.read_addr_mask)  << self.A_shift) 
        instr |= ((B  & self.read_addr_mask)  << self.B_shift)
        self.L(instr)

    def RL(self, name):
        """Resolve Literal: set named location to current address"""
        address = self.names[name]
        self.data[address] = self.here

    def RD(self, name):
        """Set *empty* D field at named address with current address"""
        address = self.names[name]
        self.data[address] |= (self.here & self.write_addr_mask) << self.D_shift

    def RA(self, name):
        """Set *empty* A field at named address with current address"""
        address = self.names[name]
        self.data[address] |= (self.here & self.read_addr_mask) << self.A_shift

    def RB(self, name):
        """Set *empty* B field at named address with current address"""
        address = self.names[name]
        self.data[address] |= (self.here & self.read_addr_mask) << self.B_shift


    def offset_write(self, name):
        address = self.names[name]
        offset  = self.write_offset
        return (address + offset) & write_addr_mask

    def NOP(self):
        self.I(XOR, 0, 0, 0)


    def __init__(self, depth = depth, write_offset = write_offset):
        self.depth          = depth
        self.write_offset   = write_offset
        self.data           = [(0 & self.word_mask)] * self.depth
        

def test():
    a = Memory(depth = 10)
    print a.depth
    print a.write_offset
    a.I(ADD, 0, 16, 8), a.N("foo")
    a.RD("foo")
    pprint.pprint(a.data)
    print hex(a.data[a.here])
    pprint.pprint(a.names)

if __name__ == "__main__":
    test()

