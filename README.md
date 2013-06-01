Octavo
======

Octavo defines a *family* of high-speed soft-processors for FPGAs which aim to maximize the amount of processing, hopefully approaching the full potential of the FPGA without fully custom hardware. You can alter the number of threads, the word width, or memory depth, and easily tack on any custom hardware you want. 

On an Altera Stratix IV 230, a single "vanilla" core runs at up to 550 MHz, the highest speed achievable (the M9K Block RAMs won't go any faster), while using around 640 to 720 ALMs, 2 DSP half-blocks, and 12 M9K BRAMs. This gives you a 36-bit word width, 1024 words of Instruction Memory, and 1024 words each of A and B Data Memory.

The instruction set has all the basics: AND, OR, XOR, ADD, SUB, full-word signed/unsigned multiply with high and low-word results (which also acts as a full barrel shifter), and the usual complement of jumps: JMP, JMP on negative/positive, JMP on zero/not-zero. There is no CALL/RET: it wasn't in the original plan, can be done using self-modifying code, and is in the works as an option. 

This repository contains the entire Verilog-2001 source and comes with Quartus project generators and Modelsim scripts. There's a very simple test bench provided.

You can go read the original paper and slides from FPGA'2012 here:
http://www.eecg.utoronto.ca/~laforest/octavo/

All work under BSD 2-Clause License. See LICENSE. (Summary: just go ahead and use it, but give credit.)
