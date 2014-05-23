#! /usr/bin/python

"""
Generates a dict of all Verilog parameters for a specific Scalar instance.
Many parameters are calculated from others.
"""

import string
import math

from Misc import misc, parameters_misc

def generate_pipeline_depths(parameters = {}):
    EXTRA_STAGES = parameters.get("EXTRA_STAGES", 0)
    assert EXTRA_STAGES % 2 == 0, "Asked for {d} EXTRA_STAGES. Must be a multiple of 2.".format(EXTRA_STAGES)
    pipeline_depths = {
        ## How many extra stages to add for > 8 (ALWAYS A MULTIPLE OF 2!)
        "EXTRA_STAGES"            : EXTRA_STAGES,
        ## Optional stage to put before I_mem to try and improve timing under P&R variation
        ## Alter I_TAP and TAP_AB to add up to 8 stages at minimum.
        ## XXX FIXME Keep at 0, else it introduces TWO zero reads at startup. Need to remove this option.
        "PC_PIPELINE_DEPTH"         : 0 + EXTRA_STAGES,
        ## How many stages between I and instruction tap to DataPath. Min. 1 for good Fmax: gets retimed into I mem BRAM.
        "I_TAP_PIPELINE_DEPTH"      : 1,
        ## How many stages between instruction tap and A/B memories. Should add up to 3 with above, minus any PC_PIPELINE_DEPTH.
        "TAP_AB_PIPELINE_DEPTH"     : 2,
        ## Delay between ControlPath and DataPath. Not used for Scalar.
        "CONTROL_INPUT_PIPELINE_DEPTH" : 0,
        ## Takes 2 cycles to read/write the A/B data memories
        "AB_READ_PIPELINE_DEPTH"    : 2,
        ## A/B read (2 cycles) + ALU (4 cycles (nominally)) + A/B write (2 cycles)
        "AB_ALU_PIPELINE_DEPTH"   : (2 + (4 + EXTRA_STAGES) + 2) }
    parameters_misc.override(pipeline_depths, parameters)
    control_pipeline_depth = sum([pipeline_depths["PC_PIPELINE_DEPTH"], 
                                  pipeline_depths["I_TAP_PIPELINE_DEPTH"], 
                                  pipeline_depths["TAP_AB_PIPELINE_DEPTH"], 
                                  pipeline_depths["AB_READ_PIPELINE_DEPTH"], 
                                  1, 2]) ## I_mem and Controller stages
    assert control_pipeline_depth == pipeline_depths["AB_ALU_PIPELINE_DEPTH"], "Control pipeline depth {0} does not match AB_ALU pipeline depth {1}".format(control_pipeline_depth, pipeline_depths["AB_ALU_PIPELINE_DEPTH"])
    return pipeline_depths

def generate_common_values(parameters = {}):
    common_values = { 
        "FAMILY"          : "Stratix IV",
        #"DEVICE"          : "EP4SE230F29C2",
        "DEVICE"          : "EP4SGX230KF40C2", # DE4-230

        "CPU_NAME"        : "Scalar",
        # This normally NEVER changes. If you do change it, update the ALU and decoders to match.
        "OPCODE_WIDTH"    : 4,

        "WORD_WIDTH"      : 36,
        "MEM_DEPTH"       : 1024, 
        "PORTS_COUNT"     : 1,
        ## Note that the final Verilog output must include double quotes
        "MEM_INIT_FILE"   : "no_init_file.mem",        

        ## Special case, since never refered again here, so re-quote here
        "PC_INIT_FILE"    : '"no_init_file.pc"',

        ## M144Ks are not suitable, and going away in Stratix V.
        "MEM_RAMSTYLE"    : '"M9K"',
        ## Thread PC read and write addresses never collide
        "PC_RAMSTYLE"     : '"MLAB,no_rw_check"'
    }
    parameters_misc.override(common_values, parameters) 

    opcode_width = common_values["OPCODE_WIDTH"]
    assert opcode_width == 4, "WARNING: You asked for OPCODE_WIDTH of {d}. Do you know what you are doing?".format(opcode_width)

    ## Address space for each of 3 operands after bits for opcode subtracted. 
    addr_width = ((common_values["WORD_WIDTH"] - common_values["OPCODE_WIDTH"]) // 3)

    ## Extra 2 bits then used to extend D operand address space.
    ## Because of this, having 0 or 1 spare bits is an error.
    spare_addr_bits = common_values["WORD_WIDTH"] - (common_values["OPCODE_WIDTH"] + (addr_width * 3))
    assert spare_addr_bits == 2, "You need 2 spare addr bits to extend D. You only have %d." % spare_addr_bits

    ## By default, include all the memory you can address, unless less specified
    max_mem_depth  = 2**addr_width
    if "WORD_WIDTH" in parameters and "MEM_DEPTH" not in parameters:
        common_values.update({"MEM_DEPTH":max_mem_depth})

    assert common_values["MEM_DEPTH"] <= max_mem_depth, "WARNING: You asked for a MEM_DEPTH of {0}, but you can only address up to {1}".format(common_values["MEM_DEPTH"], max_mem_depth)

    ## Lay out memories consecutively in D write address space
    A_offset, B_offset, I_offset, H_offset = (x*max_mem_depth for x in range(2**spare_addr_bits))

    common_values.update({
        ## Bitwise logic uses 3 LSB of opcode               
        "LOGIC_OPCODE_WIDTH" : (common_values["OPCODE_WIDTH"] - 1),
        "MEM_ADDR_WIDTH"     : addr_width,
        "D_MEM_ADDR_WIDTH"   : addr_width + spare_addr_bits,
        "A_WRITE_ADDR_OFFSET": A_offset,
        "B_WRITE_ADDR_OFFSET": B_offset,
        "I_WRITE_ADDR_OFFSET": I_offset,
        "H_WRITE_ADDR_OFFSET": H_offset,
        "PORTS_BASE_ADDR"    : (common_values["MEM_DEPTH"] -
                                common_values["PORTS_COUNT"]),
        ## Artificially limit minimum I/O address widths to 1 bit. The Verilog uses the port count to handle the discrepancy.
        "PORTS_ADDR_WIDTH"   : max(1, misc.log2(common_values["PORTS_COUNT"])) })

    return common_values

def generate_main_parameters(common_values, parameters = {}):
    main_parameters = {
         "ALU_WORD_WIDTH"               :   common_values["WORD_WIDTH"],

         "A_WRITE_ADDR_OFFSET"          :   common_values["A_WRITE_ADDR_OFFSET"],
         "A_WORD_WIDTH"                 :   common_values["WORD_WIDTH"],
         "A_ADDR_WIDTH"                 :   common_values["MEM_ADDR_WIDTH"],
         "A_DEPTH"                      :   common_values["MEM_DEPTH"],
         "A_RAMSTYLE"                   :   common_values["MEM_RAMSTYLE"],
         "A_INIT_FILE"                  :   '"' + common_values["MEM_INIT_FILE"] + '"',
         "A_IO_READ_PORT_COUNT"         :   common_values["PORTS_COUNT"],
         "A_IO_READ_PORT_BASE_ADDR"     :  (common_values["PORTS_BASE_ADDR"]),
         "A_IO_READ_PORT_ADDR_WIDTH"    :   common_values["PORTS_ADDR_WIDTH"],
         "A_IO_WRITE_PORT_COUNT"        :   common_values["PORTS_COUNT"],
         "A_IO_WRITE_PORT_BASE_ADDR"    :  (common_values["PORTS_BASE_ADDR"] + common_values["A_WRITE_ADDR_OFFSET"]),
         "A_IO_WRITE_PORT_ADDR_WIDTH"   :   common_values["PORTS_ADDR_WIDTH"],

         "B_WRITE_ADDR_OFFSET"          :   common_values["B_WRITE_ADDR_OFFSET"],
         "B_WORD_WIDTH"                 :   common_values["WORD_WIDTH"],
         "B_ADDR_WIDTH"                 :   common_values["MEM_ADDR_WIDTH"],
         "B_DEPTH"                      :   common_values["MEM_DEPTH"],
         "B_RAMSTYLE"                   :   common_values["MEM_RAMSTYLE"],
         "B_INIT_FILE"                  :   '"' + common_values["MEM_INIT_FILE"] + '"',
         "B_IO_READ_PORT_COUNT"         :   common_values["PORTS_COUNT"],
         "B_IO_READ_PORT_BASE_ADDR"     :   common_values["PORTS_BASE_ADDR"],
         "B_IO_READ_PORT_ADDR_WIDTH"    :   common_values["PORTS_ADDR_WIDTH"],
         "B_IO_WRITE_PORT_COUNT"        :   common_values["PORTS_COUNT"],
         "B_IO_WRITE_PORT_BASE_ADDR"    :   (common_values["PORTS_BASE_ADDR"] + common_values["B_WRITE_ADDR_OFFSET"]),
         "B_IO_WRITE_PORT_ADDR_WIDTH"   :   common_values["PORTS_ADDR_WIDTH"],

         "I_WRITE_ADDR_OFFSET"          :   common_values["I_WRITE_ADDR_OFFSET"],
         "I_WORD_WIDTH"                 :   common_values["WORD_WIDTH"],
         "I_ADDR_WIDTH"                 :   common_values["MEM_ADDR_WIDTH"],
         "I_DEPTH"                      :   common_values["MEM_DEPTH"],
         "I_RAMSTYLE"                   :   common_values["MEM_RAMSTYLE"],
         "I_INIT_FILE"                  :   '"' + common_values["MEM_INIT_FILE"] + '"',

         "H_WRITE_ADDR_OFFSET"          :   common_values["H_WRITE_ADDR_OFFSET"],
         "H_WORD_WIDTH"                 :   common_values["WORD_WIDTH"],
         "H_ADDR_WIDTH"                 :   common_values["MEM_ADDR_WIDTH"],
         "H_DEPTH"                      :   common_values["MEM_DEPTH"],

         "D_OPERAND_WIDTH"              :   common_values["D_MEM_ADDR_WIDTH"],
         "A_OPERAND_WIDTH"              :   common_values["MEM_ADDR_WIDTH"],
         "B_OPERAND_WIDTH"              :   common_values["MEM_ADDR_WIDTH"],
    }
    parameters_misc.override(main_parameters, parameters)
    main_parameters.update({"INSTR_WIDTH" : (common_values["OPCODE_WIDTH"] +
                                             main_parameters["D_OPERAND_WIDTH"] + 
                                             main_parameters["A_OPERAND_WIDTH"] + 
                                             main_parameters["B_OPERAND_WIDTH"])})
    assert main_parameters["INSTR_WIDTH"] <= common_values["WORD_WIDTH"], "ERROR: instruction width %d larger than word width %d" % (main_parameters["INSTR_WIDTH"], main_parameters["WORD_WIDTH"])
    return main_parameters

def generate_thread_parameters(common_values, parameters = {}):
    thread_count = common_values["AB_ALU_PIPELINE_DEPTH"]
    thread_parameters = {
        "THREAD_COUNT"      :   thread_count,
        "THREAD_ADDR_WIDTH" :   misc.log2(thread_count)}
    parameters_misc.override(common_values, parameters)
    return thread_parameters

# ECL XXX We're going to need some centralized memory map base address
# generation to keep it all straight

def generate_addressing_parameters(common_values, parameters = {}):

    base_addr = common_values["H_WRITE_ADDR_OFFSET"]
    mem_init  = '"' + common_values["MEM_INIT_FILE"] + '"'
    mem_style = '"MLAB,no_rw_check"'

    def generate_actual_parameters(prefix, parameters):
        new_parameters = {}
        for key,value in parameters.items():
            new_parameters[prefix+key] = value
        return new_parameters

    def generate_all_actual_parameters(parameters):
        memories = ["D", "A", "B"]
        new_parameters = []
        for memory in memories:
            new_parameters.append(generate_actual_parameters(memory, parameters))
        return new_parameters

    default_DO_parameters = {
        "_DEFAULT_OFFSET_WRITE_WORD_OFFSET" : None,
        "_DEFAULT_OFFSET_WRITE_ADDR_OFFSET" : base_addr + 1, # ECL not a round number to test address translation
        "_DEFAULT_OFFSET_WORD_WIDTH"        : 10,
        "_DEFAULT_OFFSET_ADDR_WIDTH"        : 3,
        "_DEFAULT_OFFSET_DEPTH"             : 8, # ECL XXX hardcoded...one per thread
        "_DEFAULT_OFFSET_RAMSTYLE"          : mem_style,
        "_DEFAULT_OFFSET_INIT_FILE"         : mem_init
    }

    D_DO_parameters, A_DO_parameters, B_DO_parameters = generate_all_actual_parameters(default_DO_parameters)
    D_DO_parameters["D_DEFAULT_OFFSET_WORD_WIDTH"] = 12
    # Lay them in the same memory word, just as the instruction operand they modify
    D_DO_parameters["D_DEFAULT_OFFSET_WRITE_WORD_OFFSET"] = 20
    A_DO_parameters["A_DEFAULT_OFFSET_WRITE_WORD_OFFSET"] = 10
    B_DO_parameters["B_DEFAULT_OFFSET_WRITE_WORD_OFFSET"] = 0

    default_PO_INC_parameters = {
        "_PO_INC_READ_BASE_ADDR"   : None,
        "_PO_INC_COUNT"            : 2,
        "_PO_INC_COUNT_ADDR_WIDTH" : 1
    }

    D_PO_INC_parameters, A_PO_INC_parameters, B_PO_INC_parameters = generate_all_actual_parameters(default_PO_INC_parameters)
    # Place the write offsets just before the end of High Memory
    D_PO_INC_parameters["D_PO_INC_READ_BASE_ADDR"] = common_values["H_WRITE_ADDR_OFFSET"] + common_values["H_DEPTH"] - D_PO_INC_parameters["D_PO_INC_COUNT"] - 1
    # Place the read offsets just before the I/O read ports.
    A_PO_INC_parameters["A_PO_INC_READ_BASE_ADDR"] = common_values["A_IO_READ_PORT_BASE_ADDR"] - A_PO_INC_parameters["A_PO_INC_COUNT"]
    B_PO_INC_parameters["B_PO_INC_READ_BASE_ADDR"] = common_values["B_IO_READ_PORT_BASE_ADDR"] - B_PO_INC_parameters["B_PO_INC_COUNT"]

    default_PO_parameters = {
        "_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET" : None,
        "_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET" : base_addr + 3, # ECL test of address transl.
        "_PROGRAMMED_OFFSETS_WORD_WIDTH"        : 10,
        "_PROGRAMMED_OFFSETS_ADDR_WIDTH"        : 3,
        "_PROGRAMMED_OFFSETS_DEPTH"             : 8,
        "_PROGRAMMED_OFFSETS_RAMSTYLE"          : mem_style,
        "_PROGRAMMED_OFFSETS_INIT_FILE"         : mem_init
    }

    D_PO_parameters, A_PO_parameters, B_PO_parameters = generate_all_actual_parameters(default_PO_parameters)
    D_PO_parameters["D_PROGRAMMED_OFFSETS_WORD_WIDTH"] = 12
    # Lay them in the same memory word, just as the instruction operand they modify
    D_PO_parameters["D_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET"] = 20
    A_PO_parameters["A_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET"] = 10
    B_PO_parameters["B_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET"] = 0

    default_INC_parameters = {
        "_INCREMENTS_WRITE_WORD_OFFSET" : None,
        "_INCREMENTS_WRITE_ADDR_OFFSET" : base_addr + 3, # ECL test of address transl.
        "_INCREMENTS_WORD_WIDTH"        : 1,
        "_INCREMENTS_ADDR_WIDTH"        : 3,
        "_INCREMENTS_DEPTH"             : 8,
        "_INCREMENTS_RAMSTYLE"          : mem_style,
        "_INCREMENTS_INIT_FILE"         : mem_init
    }

    D_INC_parameters, A_INC_parameters, B_INC_parameters = generate_all_actual_parameters(default_INC_parameters)
    # Lay them in the same memory word, just past the offsets, in the same order
    D_INC_parameters["D_INCREMENTS_WRITE_WORD_OFFSET"] = 34
    A_INC_parameters["A_INCREMENTS_WRITE_WORD_OFFSET"] = 33
    B_INC_parameters["B_INCREMENTS_WRITE_WORD_OFFSET"] = 32

    addressing_parameters = {
        # So write thread is 4, and read thread is 0, see Addressing_Thread_Number.v
        "ADDRESS_TRANSLATION_INITIAL_THREAD" : 3
    }

    for entry in [D_DO_parameters,      A_DO_parameters,      B_DO_parameters, 
                  D_PO_INC_parameters,  A_PO_INC_parameters,  B_PO_INC_parameters, 
                  D_PO_parameters,      A_PO_parameters,      B_PO_parameters, 
                  D_INC_parameters,     A_INC_parameters,     B_INC_parameters]:
        addressing_parameters.update(entry)

    parameters_misc.override(addressing_parameters, parameters)
    return addressing_parameters

def generate_branching_parameters(common_values, parameters = {}):

    base_addr = common_values["H_WRITE_ADDR_OFFSET"] + 10 # ECL XXX Hardcoded
    mem_init  = '"' + common_values["MEM_INIT_FILE"] + '"'
    mem_style = '"MLAB,no_rw_check"'

    branching_parameters = {
        "ORIGIN_WRITE_WORD_OFFSET"      : 0,
        "ORIGIN_WRITE_ADDR_OFFSET"      : base_addr,
        "ORIGIN_WORD_WIDTH"             : 10,
        "ORIGIN_ADDR_WIDTH"             : 3,
        "ORIGIN_DEPTH"                  : 8,
        "ORIGIN_RAMSTYLE"               : mem_style,
        "ORIGIN_INIT_FILE"              : mem_init,

        "BRANCH_COUNT"                  : 4,

        "DESTINATION_WRITE_WORD_OFFSET" : 10,
        "DESTINATION_WRITE_ADDR_OFFSET" : base_addr,
        "DESTINATION_WORD_WIDTH"        : 10,
        "DESTINATION_ADDR_WIDTH"        : 3,
        "DESTINATION_DEPTH"             : 8,
        "DESTINATION_RAMSTYLE"          : mem_style,
        "DESTINATION_INIT_FILE"         : mem_init,

        "CONDITION_WRITE_WORD_OFFSET"   : 20,
        "CONDITION_WRITE_ADDR_OFFSET"   : base_addr,
        "CONDITION_WORD_WIDTH"          : 3,
        "CONDITION_ADDR_WIDTH"          : 3,
        "CONDITION_DEPTH"               : 8,
        "CONDITION_RAMSTYLE"            : mem_style,
        "CONDITION_INIT_FILE"           : mem_init,

        "PREDICTION_WRITE_WORD_OFFSET"        : 23,
        "PREDICTION_WRITE_ADDR_OFFSET"        : base_addr,
        "PREDICTION_WORD_WIDTH"               : 1,
        "PREDICTION_ADDR_WIDTH"               : 3,
        "PREDICTION_DEPTH"                    : 8,
        "PREDICTION_RAMSTYLE"                 : mem_style,
        "PREDICTION_INIT_FILE"                : mem_init,

        "PREDICTION_ENABLE_WRITE_WORD_OFFSET" : 24,
        "PREDICTION_ENABLE_WRITE_ADDR_OFFSET" : base_addr,
        "PREDICTION_ENABLE_WORD_WIDTH"        : 1,
        "PREDICTION_ENABLE_ADDR_WIDTH"        : 3,
        "PREDICTION_ENABLE_DEPTH"             : 8,
        "PREDICTION_ENABLE_RAMSTYLE"          : mem_style,
        "PREDICTION_ENABLE_INIT_FILE"         : mem_init,

        "FLAGS_WORD_WIDTH"              : 8,
        "FLAGS_ADDR_WIDTH"              : 3,
    }
    parameters_misc.override(branching_parameters, parameters)
    return branching_parameters

def generate_resource_diversity_options(parameters = {}):
    resource_diversity_options = { 
        "ADDSUB_CARRY_SELECT" : "`FALSE",
        "MULT_DOUBLE_PIPE"    : "`TRUE",
        "MULT_HETEROGENEOUS"  : "`FALSE",
        "MULT_USE_DSP"        : "`TRUE"
    }
    parameters_misc.override(resource_diversity_options, parameters)
    return resource_diversity_options

def generate_partition_options(parameters = {}):
    # Partition datapaths by default: always better performance, no CAD time increase.
    partition_options = {
        "PARTITION_SCALAR" : True}
    parameters_misc.override(partition_options, parameters)
    return partition_options

def generate_quartus_options(parameters = {}):
    quartus_options = {
        # There is a bug which causes memory to not be released
        # during quartus_map if only one core (thread) used.
        "QUARTUS_NUM_PARALLEL_PROCESSORS" : 2
    }
    parameters_misc.override(quartus_options, parameters)
    return quartus_options

def generate_cpu_name(all_parameters):
    """You can do fancy naming here by refering to parameter names in the template: e.g. ${WORD_WIDTH}"""
    name_template = string.Template("${CPU_NAME}x${WORD_WIDTH}_A${A_IO_READ_PORT_COUNT}i${A_IO_WRITE_PORT_COUNT}o_B${B_IO_READ_PORT_COUNT}i${B_IO_WRITE_PORT_COUNT}o")
    name = name_template.substitute(all_parameters)
    return {"CPU_NAME":name}

def generate_logiclock_parameters(parameters = {}):
    logiclock_options = {
        "LL_ENABLED"   : "OFF",
        "LL_ORIGIN"    : "X66_Y46", # Some value chosen to fit well on DE4 230
        "LL_HEIGHT"    : "20",      # Not useful, but sure to fit a single Scalar Octavo
        "LL_WIDTH"     : "20",
        "LL_RESERVED"  : "OFF",
        "LL_AUTO_SIZE" : "OFF",
    }
    parameters_misc.override(logiclock_options, parameters)
    return logiclock_options

# ECL XXX Ugh, hacky....

def all_parameters(parameters = {}):
    common_values = generate_common_values(parameters)
    common_values.update(generate_pipeline_depths(parameters))
    common_values.update(generate_resource_diversity_options(parameters))
    common_values.update(generate_partition_options(parameters))
    common_values.update(generate_quartus_options(parameters))
    common_values.update(generate_logiclock_parameters(parameters))
    common_values.update(generate_main_parameters(common_values, parameters))
    common_values.update(generate_thread_parameters(common_values, parameters))
    common_values.update(generate_addressing_parameters(common_values, parameters))
    common_values.update(generate_branching_parameters(common_values, parameters))
    common_values.update(generate_cpu_name(common_values))
    return common_values

if __name__ == "__main__":
    import pprint
    pprint.pprint(all_parameters()) 
    ## pprint.pprint(all_parameters(parameters = {"PORTS_COUNT":5, "WORD_WIDTH":23})) 


