
"""Control bit fields for the Triadic ALU"""

from bitstring import BitArray
import Dyadic_Operators as Dyadic

# From Verilog code
total_op_width          = 20

select_r                = BitArray("0b00")
select_r_zero           = BitArray("0b01")
select_r_neg            = BitArray("0b10")
select_s                = BitArray("0b11")
simple                  = BitArray("0b0")
dual                    = BitArray("0b1")
addsub_a_plus_b         = BitArray("0b00")
addsub_minus_a_plus_b   = BitArray("0b01")
addsub_a_minus_b        = BitArray("0b10")
addsub_minus_a_minus_b  = BitArray("0b11")
shift_none              = BitArray("0b00")
shift_right             = BitArray("0b01")
shift_right_signed      = BitArray("0b10")
shift_left              = BitArray("0b11")
split_no                = BitArray("0b0")
split_yes               = BitArray("0b1")

select_width            = 2
dyadic1_width           = Dyadic.op_width
dyadic2_width           = Dyadic.op_width
dual_width              = 1
addsub_width            = 2
dyadic3_width           = Dyadic.op_width
shift_width             = 2
split_width             = 1

assert (select_width + dyadic1_width + dyadic2_width + dual_width + addsub_width + dyadic3_width + shift_width + split_width) == total_op_width, "ERROR: ALU control word width and sum of control bits widths do not agree"

if __name__ == "__main__":
    print(shift_right_signed.bin)

