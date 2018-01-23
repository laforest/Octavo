
"""Common definition of dyadic operations.
   Treat them as mux data inputs, LSB
   on the right, with a/b as the MSB/LSB selectors."""

from bitstring import BitArray

op_width     = 4

always_zero  = BitArray("0b0000")
a_and_b      = BitArray("0b1000")
a_and_not_b  = BitArray("0b0100")
a            = BitArray("0b1100")
not_a_and_b  = BitArray("0b0010")
b            = BitArray("0b1010")
a_xor_b      = BitArray("0b0110")
a_or_b       = BitArray("0b1110")
a_nor_b      = BitArray("0b0001")
a_xnor_b     = BitArray("0b1001")
not_b        = BitArray("0b0101")
a_or_not_b   = BitArray("0b1101")
not_a        = BitArray("0b0011")
not_a_or_b   = BitArray("0b1011")
a_nand_b     = BitArray("0b0111")
always_one   = BitArray("0b1111")

if __name__ == "__main__":
    print(a_or_not_b.bin)

