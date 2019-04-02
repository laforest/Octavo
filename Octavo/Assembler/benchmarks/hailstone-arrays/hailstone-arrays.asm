
# Assembly code for Hailstone benchmark and initial test
# If x is odd, x = (3x+1)/2, else x = x / 2

# Rough syntax: if the first word is not a recognized command, it's a label for
# the next word, which is a command, followed by its arguments.

# Common library of definitions
include ../common/opcodes.asm
include ../common/conditions.asm

# Shared variables across all threads
lsb_mask    shared      0xFFFFFFFFE
# Counter values must be N-1 for N passes
seeds_len   shared      2
# name                  I/O port memory and number
seed_out    port        A 0

# Common private variables (pointer is common, but init creates per-thread data)
threads 0 1 2 3 4 5 6 7
seed        private     0
newseed     private     0
#                       base_addr   increment   offset
seeds_rd    pointer     seeds       1           0
seeds_wr    pointer     seeds       1           0

# Private to each thread as separate data memory copies

threads 0 
seeds       private     41 47 54 

threads 1
seeds       private     55 62 71

threads 2
seeds       private     73 82 83

threads 3
seeds       private     91 94 95

threads 4
seeds       private     97 103 107

threads 5
seeds       private     108 109 110

threads 6
seeds       private     121 124 125

threads 7
seeds       private     126 129 137

# Code

# Runtime code is thread-agnostic, but the assembler needs to know
# which thread(s) code will run in to manage the correct list of opcodes
# when loading them.
threads 0 1 2 3 4 5 6 7

# These are baked into the Opcode Decoder memory
preload     nop add

# These are loaded at runtime
start       load sub
            load psr
            load add*2
            load add/2
            load add/2u
            init    even                                # Init branch
            init    output                              # Init branch
            init    next_seed                           # Init branch
hailstone   init    seeds_rd                            # Init read pointer to start of array
            init    seeds_wr                            # Init write pointer to start of array
            init    hailstone                           # Init loop counter branch to length of array
next_seed   add     seed        seeds_rd    0           # Load x
                                                        # Odd case: y = (3x+1)/2
            add*2   newseed     seed        0           # y = (x+0)*2 (2x)
            bsa not_taken 0 lsb_mask even               # Branch and cancel add*2 if loaded x (seed) was an even number (LSB == 0)
            add     newseed     seed        newseed     # y = (x+y)   (3x)
            add/2u  newseed     1           newseed     # y = (1+y)/2 (3x+1)/2
            jmp taken output                            # Go output the number
                                                        # Even case: y = x/2
even        add/2u  newseed     seed        0           # y = (x+0)/2 (x/2)
            nop     0           0           0           # even out cycle count of even/odd cases (to keep thread output in order)
output      add     seeds_wr    0           newseed     # x = 0+y
            add     seed_out    0           newseed     # output port = 0+x
            ctz unpredicted seeds_len hailstone         # Start over if we've processed whole array
            jmp unpredicted next_seed                   # else, process the next array element

# Set starting point (PC) for each thread
program_counter start start start start start start start start

