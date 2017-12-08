
"""Control bit fields for the Triadic ALU"""

total_op_width          = 20

select_r                = 0b00
select_r_zero           = 0b01
select_r_neg            = 0b10
select_s                = 0b11
simple                  = 0b0
dual                    = 0b1
addsub_a_plus_b         = 0b00
addsub_minus_a_plus_b   = 0b01
addsub_a_minus_b        = 0b10
addsub_minus_a_minus_b  = 0b11
shift_none              = 0b00
shift_right             = 0b01
shift_right_signed      = 0b10
shift_left              = 0b11
split_no                = 0b0
split_yes               = 0b1

select_width            = 1
dyadic1_width           = 2
dyadic2_width           = 2
dual_width              = 1
addsub_width            = 2
dyadic3_width           = 2
shift_width             = 2
split_width             = 1

