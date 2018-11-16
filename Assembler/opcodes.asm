
# Define opcodes
#               split?      shift               d3              +/-                 dual?   d2              d1              Select

# If nop has opcode zero, then we can create an all-zero no-op instruction word, which is nice.
nop     opcode  split_no    shift_none          always_zero     addsub_a_plus_b     simple  always_zero     always_zero     select_r

# Add must always be present for branch/indirect configuration loading code generation 
add     opcode  split_no    shift_none          b               addsub_a_plus_b     simple  always_zero     always_zero     select_r
        
sub     opcode  split_no    shift_none          b               addsub_a_minus_b    simple  always_zero     always_zero     select_r
psr     opcode  split_no    shift_none          a               addsub_a_plus_b     simple  always_one      always_zero     select_r  # Pass R
add*2   opcode  split_no    shift_left          b               addsub_a_minus_b    simple  always_zero     always_zero     select_r
add/2   opcode  split_no    shift_right_signed  b               addsub_a_plus_b     simple  always_zero     always_zero     select_r
add/2u  opcode  split_no    shift_right         b               addsub_a_plus_b     simple  always_zero     always_zero     select_r

