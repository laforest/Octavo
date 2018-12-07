
# Assembly code for Hailstone benchmark and initial test

# Common library of definitions
include opcodes.asm
include conditions.asm

# The location of a variable, array, or pointer is set by first read/write use, default to least full memory.
# The storage location of the initialization value of a pointer is also set by first read/write use.
# Pointers are allocated the first free indirect memory location in their set memory.
# Pointers must be manually unloaded to free an indirect memory location.
# Both read and write initial values are stored in the same A/B memory.
# Literal numbers as read operands get stored in the literal pool of the accessed A/B memory, and replaced by its storage address.
# Literal numbers as write operands is an error.
# (reading/writing from absolute addresses is not allowed for now)

# Future: need code and data de-allocation words to allow loading code/data at runtime.

# If first word is not an opcode, or a code-generating command, then it's a branch or read/write label.
# Then pass remainder of line back to line parser.

# In which threads will this code run. This determines how many copies of the variables and arrays will be created.
# The pointers are already multi-threaded in hardware.
# Constants and literals exist as single copies in the literal pool area.
# There are also drop_branch and drop_pointers to free up the used branch detector and indirect memory entries.

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
#                       base_addr   read_increment  base_addr   write_increment
seeds_ptr   pointer     seeds       1               seeds       1

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

hailstone   init    hailstone
            init    even
            init    output
            init    seeds_ptr
            init    next_seed

next_seed   add     seed        seeds_ptr   0                           # Load x

            # Odd case y = (3x+1)/2
            add*2   newseed     seed        0                           # y = (x+0)*2
            bsa not_taken 0 lsb_mask even

            add     newseed     seed        newseed                     # y = (x+y)
            add/2u  newseed     1           newseed                     # y = (1+y)/2
            jmp taken output                                            # y = (1+y)/2

# Even case y = x/2
even        add/2u  newseed     seed        0                           # y = (x+0)/2
            nop     0           0           0                           # even out cycle count of even/odd cases

# Store y (replace x)
output      add     seeds_ptr   0           newseed 
            add     seed_out    0           newseed
            ctz unpredicted seeds_len hailstone
            jmp unpredicted next_seed 

# Set initial PC for each thread

program_counter hailstone hailstone hailstone hailstone hailstone hailstone hailstone hailstone
            

