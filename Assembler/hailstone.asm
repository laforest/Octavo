
# Assembly code for Hailstone benchmark and initial test

# Common library of definitions
include opcodes.asm
include branches.asm

# The location of a variable, array, or pointer is set by first read/write use, default to least full memory.
# The storage location of the initialization value of a pointer is also set by first read/write use.
# Pointers are allocated the first free indirect memory location in their set memory.
# Pointers must be manually unloaded to free an indirect memory location.
# Both read and write initial values are stored in the same A/B memory.
# Literal numbers as read operands get stored in the literal pool of the accessed A/B memory, and replaced by its storage address.
# Literal numbers as write operands is an error.
# (reading/writing from absolute addresses is not allowed for now)

# Future: need code and data de-allocation words to allow loading code/data at runtime.

start_data

variable    seed    0
array       seeds   11 11 11 11 11 11

#           name                base_addr   read_increment          base_addr   write_increment
pointer     seeds_ptr   read    seeds       1               write   seeds       1

constant    only_lsb    0xFFFFFFFFE
variable    newseed 0

#           name        I/O port number
port        seed_out    0

start_code

# In which threads will this code run. This determines how many copies of the variables and arrays will be created.
# The pointers are already multi-threaded in hardware.
# Constants and literals exist as single copies in the literal pool area.

threads     0 1 2 3 4 5 6 7

# There are also drop_branch and drop_pointers to free up the used branch detector and indirect memory entries.

hailstone   load_branch     hailstone
            load_branch     even
            load_branch     output
            load_pointer    seeds_ptr
            load_branch     next_seed

next_seed   add     seed        seeds_ptr    0                          # Load x

            # Odd case y = (3x+1)/2

            add*2   newseed     seed        0                           # y = (x+0)*2
            bsa not_taken sentinel 0 mask only_lsb even

            add     newseed     seed        newseed                     # y = (x+y)
            add/2u  newseed     1           newseed                     # y = (1+y)/2
            jmp taken output                                            # y = (1+y)/2

            # Even case y = x/2
even        add/2u  newseed     seed        0                           # y = (x+0)/2
            nop     0           0           0                           # even out cycle count for waveform debug
            nop     0           0           0

            # Store y (replace x)
output      add     seeds_ptr   0           newseed 
            add     seed_out    0           newseed
            ctz unpredicted initial_count 6 hailstone
            jmp unpredicted next_seed 

# Set initial PC for each thread

program_counter hailstone hailstone hailstone hailstone hailstone hailstone hailstone hailstone
            

