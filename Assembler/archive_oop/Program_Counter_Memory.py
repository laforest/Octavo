#! /usr/bin/python

from Memory import Memory
from bitstring import pack,BitArray

class Program_Counter_Memory(Memory):
    """Extends Memory to assemble the initial Program Counter values."""

    def __init__(self, file_name, depth = 0, width = 0, write_offset = 0):
        Memory.__init__(self, file_name, depth = depth, width = width, write_offset = write_offset)

        self.pc_format = 'uint:{0}'.format(self.width)

    def set_pc(self, name, address, pc_value):
        """Assembles a Program Counter value at a given location."""
        pc_value = BitArray(uint=pc_value, length=self.width)
        self.align(address)
        self.lit(pc_value.uint)
        self.loc(name)

if __name__ == "__main__":
    PC_mem = Program_Counter_Memory("foobar.mem", depth = 8, width = 10, write_offset = 4000)
    test = PC_mem.set_pc("foo", 7, 789)
    print(PC_mem.lookup("foo").length)
    print(PC_mem.read_addr("foo"))
    print(PC_mem.lookup("foo").bin)
    print(PC_mem.lookup("foo").unpack(PC_mem.pc_format))

