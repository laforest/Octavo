
# Hailstone-S
# Apply modified Hailstone (If x is odd: x = (3x+1)/2, else x = x/2)
# to 100 random numbers
# Each thread does the same work.

# Common library of definitions
include ../common/opcodes.asm
include ../common/conditions.asm

# Shared Variables

# N-1 for N loops
seeds_len   shared  99
lsb_mask    shared  0xFFFFFFFFE
mult_A      port    A 0
mult_B      port    B 0
seed_out    port    A 3

# Private Variables

threads 0 1 2 3 4 5 6 7

seed    private 0
newseed private 0

# 100 number lifted from same benchmark in thesis
seeds private 333 15093 53956 91327 26294 85971 25760 51582 30794 69334 62299 49438 84916 58898 64309 95439 76368 36062 92253 38435 14227 40480 87357 87055 56934 58240 44037 43602 46250 24175 14299 91354 31251 56785 55811 49030 17973 35340 45723 47437 30536 76451 68232 93312 36248 99951 92797 27659 59184 51654 87317 81803 69681 43028 14176 88215 42476 30393 93081 81433 12647 40314 59206 76654 2331 13004 69549 71920 36328 67928 25851 12980 72936 90323 94762 18764 435 86581 402 41511 36071 4237 16356 40304 6110 11919 18517 45699 34058 16748 49922 18452 34965 8700 81423 37177 6577 12411 58089 56872   

seeds_rd pointer seeds 1 0
seeds_wr pointer seeds 1 0

# Code

preload     nop add add/2u

start       init    even                                # Init branch
            init    output                              # Init branch
            init    next_seed                           # Init branch
            add     mult_A      3           0           # Init multiplier input with constant

hailstone   init    seeds_rd                            # Init read pointer to start of array
            init    seeds_wr                            # Init write pointer to start of array
            init    hailstone                           # Init loop counter branch to length of array

next_seed   add     seed        seeds_rd    0           # Load x
                                                        # Odd case: y = (3x+1)/2
            add     mult_B      seed        0           # y = x*3
            bsa not_taken 0 lsb_mask even               # Branch and cancel add if loaded x (seed) was an even number (LSB == 0)
            nop     0           0           0           # Wait for multiplier
            add/2u  newseed     mult_A      1           # y = (3x+1)/2 (mult_A is the lower half of the product)
            jmp taken output                            # Go output the number
                                                        # Even case: y = x/2
even        add/2u  newseed     seed        0           # y = (x+0)/2 (x/2)
output      add     seeds_wr    0           newseed     # x = 0+y
            add     seed_out    0           newseed     # output port = 0+x
            ctz unpredicted seeds_len hailstone         # Start over if we've processed whole array
            jmp unpredicted next_seed                   # else, process the next array element

# Set starting point (PC) for each thread
program_counter start start start start start start start start

