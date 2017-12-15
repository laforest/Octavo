
"""Control bit fields for the Flow Control Branch Detector"""

import Dyadic_Operations as Dyadic

# From Verilog code
total_op_width          = 31

origin_enabled          = 0b1   
origin_disabled         = 0b0   
predict_taken           = 0b1
predict_not_taken       = 0b0
predict_enabled         = 0b1
predict_disabled        = 0b0
A_flag_negative         = 0b00
A_flag_carryout         = 0b01
A_flag_sentinel         = 0b10
A_flag_external         = 0b11
B_flag_lessthan         = 0b00
B_flag_counter          = 0b01
B_flag_sentinel         = 0b10
B_flag_external         = 0b11

origin_width            = 10
origin_enable_width     = 1
destination_width       = 10
predict_taken_width     = 1
predict_enable_width    = 1
A_flag_width            = 2
B_flag_width            = 2
AB_operator_width       = Dyadic.op_width
condition_width         = A_flag_width + B_flag_width + AB_operator_width


assert (origin_width + origin_enable_width + destination_width + predict_taken_width + predict_enable_width + condition_width) == total_op_width, "ERROR: Branch Detector control word width and sum of control bits widths do not agree"

