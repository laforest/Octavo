#! /usr/bin/python

from Memory import Memory
from math   import ceil, log

class Instruction_Memory(Memory):
    """Extends Memory to assemble instructions.
       Requires a reference to the memories addressed by the operands,
       to resolve read/write addresses."""

    def __init__(self, file_name, A_mem, B_mem, other_mem = [], depth = 0, width = 0, op_width = 0, dest_width = 0, src_width = 0, write_offset = 0):

        assert dest_width % 2 == 0, "ERROR: Destination bit width must be even. Was given {0} in {1}".format(dest_width, self.__class__.__name__)
        assert dest_width - src_width == 2, "ERROR: Destination bit width ({0}) must be 2 bits more than source bit width ({1}) in ({2})".format(dest_width, src_width, self.__class__.__name__)

        Memory.__init__(self, file_name, depth = depth, width = width, write_offset = write_offset)
        self.op_width           = op_width
        self.dest_width         = dest_width
        self.half_dest_width    = dest_width/2
        self.src_width          = src_width
        self.instr_width        = op_width + dest_width + src_width + src_width

        assert self.instr_width <= self.width, "ERROR: Instruction width {0} greater than Memory word width {1} in {2}".format(self.instr_width, self.width, self.__class__.__name__)

        self.src2_shift     = 0
        self.src1_shift     = self.src_width
        self.dest_shift     = self.src1_shift  + self.src_width
        self.dest2_shift    = self.dest_shift
        self.dest1_shift    = self.dest2_shift + self.half_dest_width
        self.op_shift       = self.dest_shift  + self.dest_width

        self.op_mask        = self.width_mask(op_width)
        self.dest_mask      = self.width_mask(dest_width)
        self.half_dest_mask = self.width_mask(half_dest_width)
        self.src_mask       = self.width_mask(src_width)

        # List of all other memories addressed in instructions (includes this one)
        self.A_mem          = A_mem
        self.B_mem          = B_mem
        self.other_mem      = other_mem + [self]

    def lookup_write(self, name, mem_list):
        """Lookup the write address of a name across all memories."""
        addresses = []
        for mem in mem_list:
            address = mem.write_addr(name)
            if address is not None:
                addresses.append(address)
        assert len(addresses) > 0, "ERROR: Cannot resolve undefined write name: {0}".format(name)   
        assert len(addresses) == 1, "ERROR: Cannot resolve multiple identical write names: {0}".format(name)   
        return addresses[0]

    def lookup_read(self, name, mem):
        addr = mem.read_addr(name)
        assert addr is not None, "ERROR: Read name {0} does not exist in {1}".format(name, mem.__class__.__name__)
        return addr

    def simple(self, op, dest, src1, src2):
        """Assemble a simple instruction"""
        mem_list = [self.A_mem] + [self.B_mem] + self.other_mem
        D = self.lookup_write(dest, mem_list)
        A = self.lookup_read(src1, self.A_mem)
        B = self.lookup_read(src2, self.B_mem)
        instr  = ((op & self.op_mask)   << self.op_shift)
        instr |= ((D  & self.dest_mask) << self.dest_shift)
        instr |= ((A  & self.src_mask)  << self.src1_shift)
        instr |= ((B  & self.src_mask)  << self.src2_shift)
        self.lit(instr)

    def dual(self, op, dest1, dest2, src1, src2):
        """Assemble a dual instruction (split addressing mode)"""
        DA = self.lookup_write(dest1, self.A_mem)
        DB = self.lookup_write(dest2, self.B_mem)
        # Do the write addresses, re-based to 0, fit in half the destination address bit width?
        # The CPU re-adds the correct write offset after it decodes the instruction
        assert int(ceil(log((DA - self.A_mem.write_offset),2))) <= self.half_dest_width, "ERROR: DA value {0} out of range in {1}".format(DA, self.__class__.__name__)
        assert int(ceil(log((DB - self.B_mem.write_offset),2))) <= self.half_dest_width, "ERROR: DB value {0} out of range in {1}".format(DB, self.__class__.__name__)
        A = self.lookup_read(src1, self.A_mem)
        B = self.lookup_read(src2, self.B_mem)
        instr  = ((op & self.op_mask)        << self.op_shift)
        instr |= ((DA & self.half_dest_mask) << self.dest1_shift)
        instr |= ((DB & self.half_dest_mask) << self.dest2_shift)
        instr |= ((A  & self.src_mask)       << self.src1_shift)
        instr |= ((B  & self.src_mask)       << self.src2_shift)
        self.lit(instr)

