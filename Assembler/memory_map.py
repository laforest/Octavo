#! /usr/bin/python

"Serves as repository and documentation of the memory map of Octavo. Use the names as file extensions."

mem_map = {
    # Main memory areas
    # ECL XXX Make I/O and literal pool agree after programmed offsets work
    "A":    {"Origin":0,    "Depth":1024, "IO_base":1023, "IO_count":1},
    "B":    {"Origin":1024, "Depth":1024, "IO_base":1023, "IO_count":1},
    "I":    {"Origin":2048, "Depth":1024},
    # H ("High") memory is write only. Place controls there.
    "H":    {"Origin":3072, "Depth":1024},

    # Default Offsets, alongside in same words at operand positions
    "ADO":  {"Origin":3072, "Depth":8},
    "BDO":  {"Origin":3072, "Depth":8},
    "DDO":  {"Origin":3072, "Depth":8},
    # Programmed Offsets, alongside in same words at operand positions
    "APO":  {"Origin":3080, "Depth":128},
    "BPO":  {"Origin":3080, "Depth":128},
    "DPO":  {"Origin":3080, "Depth":128},
    # Offset Control, alongside in same words at operand positions
    "AOC":  {"Origin":3208, "Depth":128},
    "BOC":  {"Origin":3208, "Depth":128},
    "DOC":  {"Origin":3208, "Depth":128},
    # Addressing Basic Block Counter, alongside in same words at operand positions
    "ABC":  {"Origin":3336, "Depth":8},
    "BBC":  {"Origin":3336, "Depth":8},
    "DBC":  {"Origin":3336, "Depth":8},

    # Flow Control Structures here after

    # Memory ends at 4095
}

