
# Define opcodes
#       name    split?      shift               d3              +/-                 dual?   d2              d1              Select

# Add must always be present for branch/indirect configuration loading code generation 
opcode  add     split_no    shift_none          b               addsub_a_plus_b     simple  always_zero     always_zero     select_r

opcode  nop     split_no    shift_none          always_zero     addsub_a_plus_b     simple  always_zero     always_zero     select_r
opcode  sub     split_no    shift_none          b               addsub_a_minus_b    simple  always_zero     always_zero     select_r
opcode  psr     split_no    shift_none          a               addsub_a_plus_b     simple  always_one      always_zero     select_r  # Pass R
opcode  add*2   split_no    shift_left          b               addsub_a_minus_b    simple  always_zero     always_zero     select_r
opcode  add/2   split_no    shift_right_signed  b               addsub_a_plus_b     simple  always_zero     always_zero     select_r
opcode  add/2u  split_no    shift_right         b               addsub_a_plus_b     simple  always_zero     always_zero     select_r

