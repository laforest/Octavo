Octavo
======

*Octavo is under a complete overhaul for the time being.  
Nothing is ready yet.  
See year branches for past working versions.*

The Octavo soft-CPU architecture aims to maximize the amount of processing
possible on an FPGA without creating fully custom hardware.

It generally reaches 80-90% of the maximum possible operating frequency of an
FPGA device, while still computing more efficiently than any in-order scalar
MIPS-like processor.

The performance comes at a price though: Octavo won't act as a drop-in
replacement for Nios or other conventional soft-processors. It won't run an OS
or access external memory (at least, not yet). You have to divide the work
across 8 independent hardware threads (but they do share all the memory).

On the other hand, each thread sees the equivalent of an ideal, if slow
processor which never stalls, has no instruction dependencies, and executes
every instruction in a single cycle (branches take zero cycles). The direct
memory addressing enables compact loops and parallel updating of multiple
"pointers" or indices, and allows up to 2 I/O reads, an ALU operation, and 1
I/O write *per cycle*, so you can process streams of data or control external
hardware efficiently.

You can find details and publications at http://fpgacpu.ca/octavo/

