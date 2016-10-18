
// This file holds values which remain true and constant everywhere.
// Not all such values are here. Most are in module-specific include (.vh) files.

// --------------------------------------------------------------------

// There are always 8 threads in Octavo.  Use this number to help sync
// operations along the pipeline to within one thread, such that the previous
// value meets the next operation in the same thread.

`define OCTAVO_THREAD_COUNT         8
`define OCTAVO_THREAD_COUNT_WIDTH   3

