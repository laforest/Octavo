#! /usr/bin/python

from Memory import Memory
import Triadic_ALU_Operators as ALU

class Opcode_Decoder_Memory(Memory):
    """Extends Memory to assemble the control bits of each opcode."""

    def __init__(self, file_name, depth = 0, width = 0, write_offset = 0):
        assert width >= ALU.total_op_width, "ERROR: memory too narrow ({0} bits) to hold ALU control bits in {1}".format(width, self.__class__.__name__)
        Memory.__init__(self, file_name, depth = depth, width = width, write_offset = write_offset)

        self.select_shift   = 0
        self.dyadic1_shift  = ALU.select_width
        self.dyadic2_shift  = self.dyadic1_shift + ALU.dyadic1_width
        self.dual_shift     = self.dyadic2_shift + ALU.dyadic2_width
        self.addsub_shift   = self.dual_shift    + ALU.dual_width
        self.dyadic3_shift  = self.addsub_shift  + ALU.addsub_width
        self.shift_shift    = self.dyadic3_shift + ALU.dyadic3_width 
        self.split_shift    = self.shift_shift   + ALU.shift_width

        self.select_mask    = self.width_mask(ALU.select_width)
        self.dyadic1_mask   = self.width_mask(ALU.dyadic1_width)
        self.dyadic2_mask   = self.width_mask(ALU.dyadic2_width)
        self.dual_mask      = self.width_mask(ALU.dual_width)
        self.addsub_mask    = self.width_mask(ALU.addsub_width)
        self.dyadic3_mask   = self.width_mask(ALU.dyadic3_width)
        self.shift_mask     = self.width_mask(ALU.shift_width)
        self.split_mask     = self.width_mask(ALU.split_width)

    def opcode(self, name, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        """Assembles the control bits of an opcode. Names the opcode."""
        control_bits  = (split   & self.split_mask)   << split_shift 
        control_bits |= (shift   & self.shift_mask)   << shift_shift
        control_bits |= (dyadic3 & self.dyadic3_mask) << dyadic3_shift
        control_bits |= (addsub  & self.addsub_mask)  << addsub_shift
        control_bits |= (dual    & self.dual_mask)    << dual_shift
        control_bits |= (dyadic2 & self.dyadic2_mask) << dyadic2_shift
        control_bits |= (dyadic1 & self.dyadic1_mask) << dyadic1_shift
        control_bits |= (select  & self.select_mask)  << select_shift
        self.lit(control_bits)
        self.loc(name)


