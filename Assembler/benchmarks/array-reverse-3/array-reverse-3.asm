
# Reverse-3, per thread.
# A -> tmp, B -> A, tmp -> B

# Common library of definitions
include ../common/opcodes.asm
include ../common/conditions.asm

# Shared variables

# N-1 for N loops
array_half_len  shared  49

output          port    A 0

# Thread-private variables

threads 0 1 2 3 4 5 6 7

array private 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100

top_ptr_rd pointer array  1 0
top_ptr_wr pointer array  1 0
bot_ptr_rd pointer array -1 99
bot_ptr_wr pointer array -1 99

temp private 0

# Code

preload add

start   init next

loop    add     output          0           -1
        init loop
        init top_ptr_rd
        init top_ptr_wr
        init bot_ptr_rd
        init bot_ptr_wr

next    add     temp            top_ptr_rd  0
        add     top_ptr_wr      bot_ptr_rd  0
        add     bot_ptr_wr      0           temp
        ctz     unpredicted     array_half_len  loop
        jmp     unpredicted     next

# Set starting point (PC) for each thread
program_counter start start start start start start start start

