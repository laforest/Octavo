
# Define branch conditions
# The first available branch detector slot is assigned to a branch init, and consecutive branch inits are placed in decreasing priority branch detector slots.
# By convention, if a or b is unused, then configure it as the selector with an all-zero value. (others will work, but make the binary values messier to look at)

#                   a           b           Op

jmp     condition   a_negative  b_lessthan  always_one  # Jump always
bsa     condition   a_sentinel  b_lessthan  a           # Jump on Branch Sentinel A match
ctz     condition   a_negative  b_counter   not_b       # Jump on Counter reaching Zero (N-1 for N passes)

