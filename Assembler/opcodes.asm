
# Define opcodes

        opcodes
nop     common pass 0 a+b simple 0 0 r
add     common pass b a+b simple 0 0 r
sub     common pass b a-b simple 0 0 r
psr     common pass a a+b simple 1 0 r  # Pass R
add*2   common lsl  b a-b simple 0 0 r
add/2   common asr  b a+b simple 0 0 r
add/2u  common lsr  b a+b simple 0 0 r

