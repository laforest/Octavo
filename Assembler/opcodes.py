#! /usr/bin/python

# Opcodes, assigned their integer values, carefully chosen.
# XOR must always be 0, since XOR, O, O, O makes a useful NOP

# XOR, AND, OR, SUB, ADD, UND1, UND2, UND3, MHS, MLS, MHU, JMP, JZE, JNZ, JPO, JNE = range(16)

# Jumps no longer exist as opcodes, see branching_flags.py

XOR, AND, OR, SUB, ADD, UND1, UND2, UND3, MHS, MLS, MHU, UND4, UND5, UND6, UND7, UND8 = range(16)

