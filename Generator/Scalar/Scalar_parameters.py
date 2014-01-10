#! /usr/bin/python

"""
Generates a dict of all Verilog parameters for a specific Scalar instance.
Many parameters are calculated from others.
"""

import string

from Misc import misc, parameters_misc

def generate_pipeline_depths(parameters = {}):
    EXTRA_STAGES = parameters.get("EXTRA_STAGES", 0)
    assert EXTRA_STAGES % 2 == 0, "Asked for {d} EXTRA_STAGES. Must be a multiple of 2.".format(EXTRA_STAGES)
    pipeline_depths = {
        ## How many extra stages to add for > 8 (ALWAYS A MULTIPLE OF 2!)
        "EXTRA_STAGES"            : EXTRA_STAGES,
        ## Optional stage to put before I_mem to try and improve timing under P&R variation
        ## Alter I_TAP and TAP_AB to add up to 8 stages at minimum.
        ## Set to 0 to keep all stages on IAB path to lower SIMD lane instruction lag
        "PC_PIPELINE_DEPTH"         : 0 + EXTRA_STAGES,
        ## How many stages between I and instruction tap to DataPath. Min. 1 for good Fmax: gets retimed into I mem BRAM.
        "I_TAP_PIPELINE_DEPTH"      : 1,
        ## How many stages between instruction tap and A/B memories. Should add up to 3 with above, minus any PC_PIPELINE_DEPTH.
        "TAP_AB_PIPELINE_DEPTH"     : 2,
        ## How many stages between instruction in and out. Used only in datapaths. See SIMD version too. 
        ## Set to 1 if there are SIMD lanes.
        "I_PASSTHRU_PIPELINE_DEPTH" : 0,
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
        "DEVICE"          : "EP4SE230F29C2",
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

def generate_thread_parameters(pipeline_depths, parameters = {}):
    thread_count = pipeline_depths["AB_ALU_PIPELINE_DEPTH"]
    thread_parameters = {
        "THREAD_COUNT"      :   thread_count,
        "THREAD_ADDR_WIDTH" :   misc.log2(thread_count)}
    parameters_misc.override(thread_parameters, parameters)
    return thread_parameters

def generate_addressing_parameters(common_values, parameters = {}):
    addressing_parameters = {
        "OFFSETS_H_ADDR_BASE"   : common_values["H_WRITE_ADDR_OFFSET"], # ECL adjust later, when deciding H mem map
        "OFFSETS_WRITE_DELAY"       : 2,                                    # ECL guess. needs adjusting
        "OFFSETS_COUNT"             : 64,                                   # MLAB 64x10
        "OFFSETS_RAMTYLE"           : '"MLAB,no_rw_check"',
        "OFFSETS_INIT_FILE"         : '"' + common_values["MEM_INIT_FILE"] + '"',
        "OFFSETS_INITIAL_THREAD"    : 2                                     # ECL needs adjusting
    }
    parameters_misc.override(addressing_parameters, parameters)
    return addressing_parameters


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

def all_parameters(parameters = {}):
    pipeline_depths = generate_pipeline_depths(parameters)
    common_values   = generate_common_values(parameters)
    common_values.update(pipeline_depths)
    all_parameters  = {}
    all_parameters.update(pipeline_depths)
    all_parameters.update(common_values)
    all_parameters.update(generate_main_parameters(common_values, parameters))
    all_parameters.update(generate_thread_parameters(pipeline_depths, parameters))
    all_parameters.update(generate_addressing_parameters(common_values, parameters))
    all_parameters.update(generate_resource_diversity_options(parameters))
    all_parameters.update(generate_partition_options(parameters))
    all_parameters.update(generate_quartus_options(parameters))
    all_parameters.update(generate_logiclock_parameters(parameters))
    all_parameters.update(generate_cpu_name(all_parameters))
    return all_parameters

if __name__ == "__main__":
    import pprint
    pprint.pprint(all_parameters()) 
    ## pprint.pprint(all_parameters(parameters = {"PORTS_COUNT":5, "WORD_WIDTH":23})) 


