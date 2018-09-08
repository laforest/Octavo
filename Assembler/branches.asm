
# Define branch conditions
# The definition of a branch decides which of the 256 branch code generators gets called when parsing the branch invocation in the code.
# The code generator calculates and stores the initialization values, and generates the branch load instructions at the given location in the code.
# Storage for branch configuration goes to the least used literal pool (A/B) at the time.
# The first available branch detector slot is assigned, and consecutive branches are placed in decreasing priority branch detector slots.

#       name    a           b           Op

branch  jmp     negative    lessthan    1     # Jump always
branch  bsa     sentinel    lessthan    a     # Jump on Branch Sentinel A match
branch  ctz     negative    counter     !b    # Jump on Counter reaching Zero (not running)

