#! /usr/bin/python3

from bitstring      import BitArray
from Debug          import Debug

# ---------------------------------------------------------------------------

class Dyadic_Operators (Debug):
    """Common definition of dyadic operations.
       Treat them as mux data inputs, LSB
       on the right, with a/b as the MSB/LSB selectors."""

    def __init__ (self):
        Debug.__init__(self)
        self.operator_width = 4

        self.always_zero    = BitArray("0b0000")
        self.a_and_b        = BitArray("0b1000")
        self.a_and_not_b    = BitArray("0b0100")
        self.a              = BitArray("0b1100")
        self.not_a_and_b    = BitArray("0b0010")
        self.b              = BitArray("0b1010")
        self.a_xor_b        = BitArray("0b0110")
        self.a_or_b         = BitArray("0b1110")
        self.a_nor_b        = BitArray("0b0001")
        self.a_xnor_b       = BitArray("0b1001")
        self.not_b          = BitArray("0b0101")
        self.a_or_not_b     = BitArray("0b1101")
        self.not_a          = BitArray("0b0011")
        self.not_a_or_b     = BitArray("0b1011")
        self.a_nand_b       = BitArray("0b0111")
        self.always_one     = BitArray("0b1111")

# ---------------------------------------------------------------------------

class Triadic_ALU_Operators (Debug):
    """Control bit fields for the Triadic ALU"""

    def __init__ (self, dyadic_obj):
        Debug.__init__(self)
        self.dyadic = dyadic_obj

        # From Verilog code
        self.control_width          = 20

        self.select_r               = BitArray("0b00")
        self.select_r_zero          = BitArray("0b01")
        self.select_r_neg           = BitArray("0b10")
        self.select_s               = BitArray("0b11")
        self.simple                 = BitArray("0b0")
        self.dual                   = BitArray("0b1")
        self.addsub_a_plus_b        = BitArray("0b00")
        self.addsub_minus_a_plus_b  = BitArray("0b01")
        self.addsub_a_minus_b       = BitArray("0b10")
        self.addsub_minus_a_minus_b = BitArray("0b11")
        self.shift_none             = BitArray("0b00")
        self.shift_right            = BitArray("0b01")
        self.shift_right_signed     = BitArray("0b10")
        self.shift_left             = BitArray("0b11")
        self.split_no               = BitArray("0b0")
        self.split_yes              = BitArray("0b1")

        self.select_width           = 2
        self.dyadic1_width          = self.dyadic.operator_width
        self.dyadic2_width          = self.dyadic.operator_width
        self.dual_width             = 1
        self.addsub_width           = 2
        self.dyadic3_width          = self.dyadic.operator_width
        self.shift_width            = 2
        self.split_width            = 1

        assert (self.select_width + self.dyadic1_width + self.dyadic2_width + self.dual_width + self.addsub_width + self.dyadic3_width + self.shift_width + self.split_width) == self.control_width, "ERROR: ALU control word width and sum of control bits widths do not agree"


# ---------------------------------------------------------------------------

class Branch_Detector_Operators (Debug):
    """Control bit fields for the Flow Control Branch Detector"""

    def __init__ (self, dyadic_obj):
        Debug.__init__(self)
        self.dyadic = dyadic_obj

        # From Verilog code
        self.control_width          = 31

        self.origin_enabled         = BitArray("0b1")
        self.origin_disabled        = BitArray("0b0")
        self.predict_taken          = BitArray("0b1")
        self.predict_not_taken      = BitArray("0b0")
        self.predict_enabled        = BitArray("0b1")
        self.predict_disabled       = BitArray("0b0")
        self.a_negative             = BitArray("0b00")
        self.a_carryout             = BitArray("0b01")
        self.a_sentinel             = BitArray("0b10")
        self.a_external             = BitArray("0b11")
        self.b_lessthan             = BitArray("0b00")
        self.b_counter              = BitArray("0b01")
        self.b_sentinel             = BitArray("0b10")
        self.b_external             = BitArray("0b11")

        self.origin_width           = 10
        self.origin_enable_width    = 1
        self.destination_width      = 10
        self.predict_taken_width    = 1
        self.predict_enable_width   = 1
        self.a_width                = 2
        self.b_width                = 2
        self.ab_operator_width      = self.dyadic.operator_width
        self.condition_width        = self.a_width + self.b_width + self.ab_operator_width

        assert (self.origin_width + self.origin_enable_width + self.destination_width + self.predict_taken_width + self.predict_enable_width + self.condition_width) == self.control_width, "ERROR: Branch Detector control word width and sum of control bits widths do not agree"

# ---------------------------------------------------------------------------

class Operators (Debug):

    def __init__ (self):
        Debug.__init__(self)
        self.dyadic             = Dyadic_Operators()
        self.triadic            = Triadic_ALU_Operators(self.dyadic)
        self.branch_detector    = Branch_Detector_Operators(self.dyadic)

