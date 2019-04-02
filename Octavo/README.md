Octavo
======

*The Octavo project has ended. See: http://fpgacpu.ca/octavo for project outcomes and detailed architectural documentation.*

* Assembler: A basic Octavo assembler written in Python. Does not do resource de-allocation yet.
* Diagrams: Block diagrams of functional modules. (See http://fpgacpu.ca/octavo for their explanation.)
* Issues: An archive of past Github issues for this project. All closed since project end.
* Source: The Octavo Verilog source code. Depends on many little modules in the Parts library (elswhere in this repo). Also contains source for some application-specific accelerators.
* Tests: Some simple test benches and test harnesses for Octavo and some of the more complex parts (e.g. the ALU)

The Octavo soft-CPU architecture aims to maximize the amount of processing
possible on an FPGA without creating fully custom hardware.

It generally reaches 80% of the maximum possible operating frequency of an
FPGA device, while still computing more efficiently than any in-order scalar
RISC processor.

The performance comes at a price though: Octavo won't act as a drop-in
replacement for Nios or other conventional soft-processors. It's not
straightforward to program in assembly. You have to divide the work across 8
independent hardware threads (but they do share all the memory).

On the other hand, each thread sees the equivalent of an ideal, if slow
processor which never stalls, has no instruction dependencies, and executes
every instruction in a single cycle (branches take zero cycles). The direct
memory addressing enables compact loops and parallel updating of multiple
"pointers" or indices, and allows up to 2 I/O reads, an ALU operation, and 2
I/O writes *per cycle*, so you can process streams of data or control external
hardware efficiently.

