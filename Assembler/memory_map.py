#! /usr/bin/python

"Serves as repository and documentation of the memory map of Octavo. Use the names as file extensions."

mem_map = {
    # Data memory 
    "A":    {"Origin":0, "Depth":1024, 
             "PO_INC_base":1018, "PO_INC_count":2, 
             "IO_base":1020, "IO_count":4},
    "B":    {"Origin":1024, "Depth":1024, 
             "PO_INC_base":1018, "PO_INC_count":2, 
             "IO_base":1020, "IO_count":4},
    # Instruction memory
    "I":    {"Origin":2048, "Depth":1024},

    # High memory is write only. Place controls and write indirections there.
    "H":    {"Origin":3072, "Depth":1024,
             "PO_INC_base":4093, "PO_INC_count":2},
    # Default Offsets, alongside in same words at operand positions
    "DDO":  {"Origin":3073, "Depth":1, "bit_offset":20},
    "ADO":  {"Origin":3073, "Depth":1, "bit_offset":10},
    "BDO":  {"Origin":3073, "Depth":1, "bit_offset":0},
    # Programmed Offsets, alongside in same words at operand positions
    "DPO":  {"Origin":3075, "Depth":1, "bit_offset":20},
    "APO":  {"Origin":3075, "Depth":1, "bit_offset":10},
    "BPO":  {"Origin":3075, "Depth":1, "bit_offset":0},
    # Increments, alongside in same words at operand positions, but shifted above PO
    "DIN":  {"Origin":3075, "Depth":1, "bit_offset":34},
    "AIN":  {"Origin":3075, "Depth":1, "bit_offset":33},
    "BIN":  {"Origin":3075, "Depth":1, "bit_offset":32},

    # Branch Origins
    "BO":   {"Origin":3082, "Depth":1, "bit_offset":0},
    # Branch Destinations
    "BD":   {"Origin":3082, "Depth":1, "bit_offset":10},
    # Branch Conditions
    "BC":   {"Origin":3082, "Depth":1, "bit_offset":20},
    # Branch Predictions
    "BP":   {"Origin":3082, "Depth":1, "bit_offset":23},
    # Branch Prediction Enables
    "BPE":  {"Origin":3082, "Depth":1, "bit_offset":24},

    # Memory ends at 4095
}

