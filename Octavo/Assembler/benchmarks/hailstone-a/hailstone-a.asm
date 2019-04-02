
# Hailstone-A
# Apply modified Hailstone (If x is odd: x = (3x+1)/2, else x = x/2)
# to a single seed, accelerated through a table look-up.

# ECL FIXME INCOMPLETE!!! Needs assembler support (see DESIGN_NOTES)

# Common library of definitions
include ../common/opcodes.asm
include ../common/conditions.asm

# Shared Variables

# N-1 for N loops
steps       shared  27          # 222 steps  / 8 threads
lower_mask  shared  0xFFFFFFF00 # Mask-off all but lower 8 bits
rshift_8    shared  268435456   # 2**(36-8) = 2**28 (take upper product as right shift by 8)
mult_A      port    A 0         # Multiplier operand, and lower word of product
mult_B      port    B 0         # Multiplier operand, and upper word of product
seed_out    port    A 3         # output port for current result

# Precomputed lookahead on 8 LSB of sequence
lookahead shared  0 1 2 2 1 1 1 8 2 10 2 4 2 2 5 5 1 2 20 20 1 1 8 8 1 26 1 242 10 10 10 91 2 11 4 4 13 13 13 38 2 121 2 14 5 5 5 137 2 17 17 17 2 2 161 161 20 56 20 19 20 20 182 182 1 7 22 22 8 8 8 206 26 71 26 8 26 26 76 76 1 80 242 242 1 1 28 28 10 29 10 263 10 10 91 91 4 94 11 11 11 11 11 890 4 101 4 103 107 107 107 319 13 4 37 37 13 13 38 38 40 350 40 118 121 121 364 1093 2 125 14 14 44 44 44 43 5 395 5 134 5 5 137 137 17 47 47 47 17 17 16 16 17 49 17 445 152 152 152 1367 2 155 53 53 161 161 161 479 2 1457 2 164 56 56 56 167 20 19 19 19 20 20 175 175 20 59 20 179 182 182 182 1640 8 62 188 188 7 7 7 190 22 64 22 65 22 22 593 593 8 67 202 202 8 8 206 206 71 23 71 209 71 71 638 638 26 647 8 8 74 74 74 661 26 668 26 674 76 76 76 2051 80 26 233 233 80 80 236 236 242 238 242 719 728 728 2186 6560

# Count of odd numbers encountered over lookahead sequence calculation, cubed.
oddcntcbd shared 1 81 81 81 27 27 27 243 27 243 27 81 27 27 81 81 9 27 243 243 9 9 81 81 9 243 9 2187 81 81 81 729 9 81 27 27 81 81 81 243 9 729 9 81 27 27 27 729 9 81 81 81 9 9 729 729 81 243 81 81 81 81 729 729 3 27 81 81 27 27 27 729 81 243 81 27 81 81 243 243 3 243 729 729 3 3 81 81 27 81 27 729 27 27 243 243 9 243 27 27 27 27 27 2187 9 243 9 243 243 243 243 729 27 9 81 81 27 27 81 81 81 729 81 243 243 243 729 2187 3 243 27 27 81 81 81 81 9 729 9 243 9 9 243 243 27 81 81 81 27 27 27 27 27 81 27 729 243 243 243 2187 3 243 81 81 243 243 243 729 3 2187 3 243 81 81 81 243 27 27 27 27 27 27 243 243 27 81 27 243 243 243 243 2187 9 81 243 243 9 9 9 243 27 81 27 81 27 27 729 729 9 81 243 243 9 9 243 243 81 27 81 243 81 81 729 729 27 729 9 9 81 81 81 729 27 729 27 729 81 81 81 2187 81 27 243 243 81 81 243 243 243 243 243 729 729 729 2187 6561

# Private Variables

threads 0 1 2 3 4 5 6 7

seed    private 77031   # longest hailstone sequence for seed < 100,000 (222 terms)
lower   private 0       # lower 8 bits of seed
upper   private 0       # upper 28 bits of seed
temp    private 0       # intermediate calculation

# We'll be indexing into these tables, so we need to add to the init values
lookahead_ptr pointer lookahead 0 0
oddcntcbd_ptr pointer oddcntcbd 0 0

# Code

preload     nop add and dmv

start       init    even                                            #
            init    output                                          #
            init    next_seed                                       #

hailstone   init    seeds_rd                                        #
            init    seeds_wr                                        #
            init    hailstone                                       #

next_seed   and     lower                   seed            lower_mask          # Compute table index
            dmv     mult_A mult_B           seed            rshift_8            # Do right shift by 8
            add     oddcntcbd_ptr_config    lower           oddcntcbd_ptr_init  # index into table
            add     lookahead_ptr_config    lower           lookahead_ptr_init  # index into table
            dmv     mult_A mult_B           oddcntcbd_ptr   mult_B              # compute partial result 
            nop     0                       0               0                   # wait for multiplier
            add     seed                    mult_A          lookahead_ptr       # finish computing result
            ctz     unpredicted steps done                                      # If we have done all the steps, go to "stop" loop
            jmp     unpredicted next_seed                                       # else do the next seed

done        nop     0                       0               0                   # Wait forever here
            jmp unpredicted done

# Set starting point (PC) for each thread
program_counter start start start start start start start start

