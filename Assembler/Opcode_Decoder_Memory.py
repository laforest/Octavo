#! /usr/bin/python

from Memory import Memory
import Triadic_ALU_Operators as ALU
from bitstring import pack,BitArray

class Opcode_Decoder_Memory(Memory):
    """Extends Memory to assemble the control bits of each opcode."""

    def __init__(self, file_name, depth = 0, width = 0, write_offset = 0):
        assert width >= ALU.total_op_width, "ERROR: memory too narrow ({0} bits) to hold ALU control bits in {1}".format(width, self.__class__.__name__)
        Memory.__init__(self, file_name, depth = depth, width = width, write_offset = write_offset)

        self.alu_control_format = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5},uint:{6},uint:{7}'.format(ALU.split_width, ALU.shift_width, ALU.dyadic3_width, ALU.addsub_width, ALU.dual_width, ALU.dyadic2_width, ALU.dyadic1_width, ALU.select_width)

    def opcode(self, name, opcode, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        """Assembles the control bits of an opcode. Names the opcode. Opcode indexes memory."""
        control_bits = BitArray()
        for entry in [split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select]:
            control_bits.append(entry)
        self.align(opcode)
        self.lit(control_bits.uint)
        self.loc(name)

if __name__ == "__main__":
    import Dyadic_Operators as Dyadic
    OP_mem = Opcode_Decoder_Memory("foobar.mem", depth = 128, width = 20, write_offset = 1000)
    op = 8
    test = OP_mem.opcode("foo", op, ALU.split_yes, ALU.shift_left, Dyadic.not_a_or_b, ALU.addsub_a_minus_b, ALU.dual, Dyadic.a_xor_b, Dyadic.a_and_b, ALU.select_r_neg)
    print(OP_mem.lookup("foo").length)
    print(OP_mem.read_addr("foo"))
    print(OP_mem.lookup("foo").bin)
    print(OP_mem.lookup("foo").unpack(OP_mem.alu_control_format))

