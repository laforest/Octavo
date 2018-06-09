
# Assembly code for Hailstone benchmark and initial test

# Define opcodes

nop     dop common pass 0 a+b simple 0 0 r
add     dop common pass b a+b simple 0 0 r
sub     dop common pass b a-b simple 0 0 r
psr     dop common pass a a+b simple 1 0 r  # Pass R
add*2   dop common lsl  b a-b simple 0 0 r
add/2   dop common asr  b a+b simple 0 0 r
add/2u  dop common lsr  b a+b simple 0 0 r

# Define branch conditions

jmp     dbc negative lessthan 1             # Jump always
bsa     dbc sentinel lessthan a             # Jump on Branch Sentinel A match
ctz     dbc negative counter  !b            # Jump on Counter reaching Zero (not running)

# Pre-set memory A

            mem     A
            thread  all
            pool    1
seed_ptr    ind     0
seed        lit     0
seeds       lit     11 11 11 11 11 11

# Pre-set memory B

            mem     B
            thread  all
            pool    1
            pool    6
mask        pool    0xFFFFFFFFE             # All but LSB mask
restart_t   pool    0
next_t      pool    0
even_t      pool    0
output_t    pool    0
nextseed    lit     0
seed_ptr_ir lit     apo  0 seeds 1
seed_ptr_iw lit     dapo 0 seeds 1

# Set initial PC for each thread

            pc      0 0 0 0 0 0 0 0
            
# Hailstone program

restart     add     bd0  0 restart_t
            add     bc0  0 6                # literals replaced by pool entry address
            add     bd2  0 even_t
            add     b1s2 0 0
            add     b1m2 0 mask
            add     bd3  0 output_t
            add     apo  0 seed_ptr_ir
            add     dapo 0 seed_ptr_iw
            add     bd1  0 next_t

nextseed    add     seed        seed_ptr    0                                   # Load x

            # Odd case y = (3x+1)/2
            add*2   nextseed    seed        0           bsan even even_t        # y = (x+0)*2
            add     nextseed    seed        nextseed                            # y = (x+y)
            add/2u  nextseed    1           nextseed    jmpt output output_t    # y = (1+y)/2

            # Even case y = x/2
even        add/2u  nextseed    seed        0                                   # y = (x+0)/2
            nop     0           0           0
            nop     0           0           0

            # Store y (replace x)
output      add     seed_ptr    0           nextseed
            add     io0         0           nextseed    ctz restart   restart_t
                                                        jmp next_seed next_t 
