
# Assembly code for Hailstone benchmark and initial test

# Common library of definitions
include opcodes.asm
include branches.asm

# Pre-set memory A

            memory  A
            thread  0 1 2 3 4 5 6 7
            pool    1
seed_ptr    ind     0
seed        lit     0
seeds       lit     11 11 11 11 11 11

# Pre-set memory B

            memory  B
            thread  0 1 2 3 4 5 6 7
            pool    1
            pool    6
mask        pool    0xFFFFFFFFE             # All but LSB mask
hailstone   pool    0
next_seed   pool    0
even        pool    0
output      pool    0
newseed     lit     0
seed_ptr_ir apo     0 seeds 1
seed_ptr_iw dapo    0 seeds 1

# Hailstone program

            memory I
hailstone   add     bd0  0 hailstone  
            add     bc0  0 6                # literals replaced by pool entry address
            add     bd2  0 even  
            add     b1s2 0 0
            add     b1m2 0 mask
            add     bd3  0 output  
            add     apo  0 seed_ptr_ir
            add     dapo 0 seed_ptr_iw
            add     bd1  0 next_seed  

next_seed   add     seed        seed_ptr    0                           # Load x

            # Odd case y = (3x+1)/2
            add*2   newseed     seed        0           bsa n even      # y = (x+0)*2
            add     newseed     seed        newseed                             # y = (x+y)
            add/2u  newseed     1           newseed     jmp t output    # y = (1+y)/2

            # Even case y = x/2
even        add/2u  newseed     seed        0                                   # y = (x+0)/2
            nop     0           0           0
            nop     0           0           0

            # Store y (replace x)
output      add     seed_ptr    0           newseed 
            add     io0         0           newseed     ctz u hailstone jmp u next_seed 

# Set initial PC for each thread

            program_counter hailstone hailstone hailstone hailstone hailstone hailstone hailstone hailstone
            

