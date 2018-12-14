
# Assembly code for Hailstone benchmark and initial test

# Common library of definitions
include opcodes.asm
include conditions.asm

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

# Runtime code is thread-agnostic, but the assembler needs to know
# which thread(s) code will run in to manage the correct list of opcodes
# when loading them.
threads 0 1 2 3 4 5 6 7

preload     nop add

start       load sub
            load psr
            load add*2
            load add/2
            load add/2u

            init    even
            init    output
            init    next_seed
hailstone   init    seeds_ptr
            init    hailstone

next_seed   add     seed        seeds_ptr   0           # Load x

            # Odd case y = (3x+1)/2
            add*2   newseed     seed        0           # y = (x+0)*2
            bsa not_taken 0 lsb_mask even

            add     newseed     seed        newseed     # y = (x+y)
            add/2u  newseed     1           newseed     # y = (1+y)/2
            jmp taken output                            # y = (1+y)/2

# Even case y = x/2
even        add/2u  newseed     seed        0           # y = (x+0)/2
            nop     0           0           0           # even out cycle count of even/odd cases (to keep thread output in order)

# Store y (replace x)
output      add     seeds_ptr   0           newseed 
            add     seed_out    0           newseed
            ctz unpredicted seeds_len hailstone
            jmp unpredicted next_seed 

# Set initial PC for each thread

program_counter start start start start start start start start

