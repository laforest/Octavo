
// This file holds values which remain true and constant everywhere.
// Not all such values are here. Most are in module-specific include (.vh) files.

// --------------------------------------------------------------------

// There are always 8 threads in Octavo.  Use this number to help sync
// operations along the pipeline to within one thread, such that the previous
// value meets the next operation in the same thread.

`define OCTAVO_THREAD_COUNT         8
`define OCTAVO_THREAD_COUNT_WIDTH   3

// Opcodes are always 4 bits. 
// The operand field widths may change though.

`define OPCODE_COUNT    16
`define OPCODE_WIDTH    4

// The Flow Control module needs to know how much to delay some internal
// signals to sync with the output of the Instruction Memory.

`define INSTR_FETCH_PIPE_DEPTH  4

// How many memory words are used to configure each Branch Module
// See Branch_Module_Mapped.v for details

`define BRANCH_CONFIG_ENTRIES   6

