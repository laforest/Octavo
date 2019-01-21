
# Define opcodes
#               split?      shift               d3              +/-                 dual?   d2              d1              Select

# This nop is not needed (could add 0 0 0), but it results in an all-zero control word, which might be handy.
nop     opcode  split_no    shift_none          always_zero     addsub_a_plus_b     simple  always_zero     always_zero     select_r # absolute no-op
# Add must always be present. It is used by code generation for branch and pointer initialization loads.
add     opcode  split_no    shift_none          b               addsub_a_plus_b     simple  always_zero     always_zero     select_r # a+b
sub     opcode  split_no    shift_none          b               addsub_a_minus_b    simple  always_zero     always_zero     select_r # a-b
psr     opcode  split_no    shift_none          a               addsub_a_plus_b     simple  always_one      always_zero     select_r # Pass R to ALU outputs
add*2   opcode  split_no    shift_left          b               addsub_a_minus_b    simple  always_zero     always_zero     select_r # (a+b) << 1
add/2   opcode  split_no    shift_right_signed  b               addsub_a_plus_b     simple  always_zero     always_zero     select_r # (a+b) >> 1 (sign extends)
add/2u  opcode  split_no    shift_right         b               addsub_a_plus_b     simple  always_zero     always_zero     select_r # (a+b) >> 1 (shifts zero into MSB)

