Octavo
======

Octavo defines a *family* of high-speed soft-processors for FPGAs which aim to maximize the amount of processing possible, hopefully approaching the full potential of the FPGA without fully custom hardware. You can easily alter the number of threads, the word width, or memory depth, the implementation of the adders and multipliers, the number of datapaths and I/O ports, and tack on any custom hardware you want. 

On an Altera Stratix IV 230, a single "vanilla" core runs at up to 550 MHz, **the highest speed achievable** (the M9K Block RAMs won't go any faster), while using around 640 to 720 ALMs, 2 DSP half-blocks, and 12 M9K BRAMs. This gives you a 36-bit word width, 1024 words of Instruction Memory, and 1024 words each of A and B Data Memory, each with a handful of memory-mapped I/O ports. Octavo executes an instruction from one of 8 threads, round-robin, each cycle.

The instruction set has all the basics: AND, OR, XOR, ADD, SUB, full-word signed/unsigned multiply with high and low-word results (which also acts as a full barrel shifter), and the usual complement of jumps: JMP, JMP on negative/positive, JMP on zero/not-zero. There is no CALL/RET: it wasn't in the original plan, can be done using self-modifying code, and is in the works as an option. Yes, that's a pretty small instruction set, but once you remove the need for loads and stores, and byte and halfword operations, the typical MIPS-like instruction set shrinks down a lot, without reducing capability. See the [Instruction Set Architecture](https://github.com/laforest/Octavo/wiki/Instruction-Set-Architecture) wiki page for details.

The performance comes at a price though: Octavo won't act as a drop-in replacement for Nios or other conventional soft-processors. It won't run an OS  or access external memory (at least, not yet). You have to divide the work across 8 independent hardware threads (but they do share all the memory). There is no memory indirection (thus no shared code between threads).

On the other hand, each thread sees the equivalent of an ideal, 68.75 MHz processor which never stalls, has no instruction dependencies, and executes every instruction in a single cycle. The direct memory addressing enables  compact loops and parallel updating of multiple "pointers" or indices, and allows up to 2 I/O reads, an ALU operation, and 1 I/O write *per cycle*, so you can process streams of data or control external hardware efficiently.

Features
------------

* Entirely configurable via top-level module parameters.
* Written entirely in synthesizable, synchronous Verilog-2001. The same source is used for synthesis and simulation.
* Comes with a project generator for Quartus, already tuned for highest performance. A "vanilla" Octavo core fully compiles in 5 minutes or so.
* High-speed (up to ~600 MHz) word-wide multiplier configurable to use either DSP or logic blocks, in single or ping-pong (dual) pipeline form.
* *Optional SIMD lanes*, which can be configured differently than the main scalar core (e.g.: 18-bit SIMD lanes, controlled by a 36-bit scalar core), and have their own local memory and I/O.

You can go read the original paper and slides from FPGA'2012 here:
http://www.eecg.utoronto.ca/~laforest/octavo/ (The design has evolved since publication.)

This repository contains the entire Verilog-2001 source and comes with Quartus project generators and Modelsim scripts. There's a very simple test bench provided. Check the [Quick Start Guide](https://github.com/laforest/Octavo/wiki/Quick-Start-Guide) to see how to create a ready-to-use Octavo instance.

By default, and unless explicitly specified otherwise, all work falls under the BSD 2-Clause License. See [LICENSE](https://github.com/laforest/Octavo/blob/master/LICENSE) file. (Summary: just go ahead and use it, but give credit.)

If you have any questions, please contact me: eric.laforest@gmail.com
