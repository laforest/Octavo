#! /usr/bin/python

import os
import sys

from Misc import misc, parameters_misc
import SIMD_parameters 
import SIMD_definition
import SIMD_test_harness
import SIMD_test_bench

def do_build(parameters = {}):
    all_parameters = SIMD_parameters.all_parameters(parameters)
    definition     = SIMD_definition.definition(all_parameters)
    name           = all_parameters["CPU_NAME"]
    cpu_dir        = os.path.join(os.getcwd(), name)
    misc.write_file(cpu_dir, name + ".v", definition)
    parameters_misc.write_parameter_file(cpu_dir, 
                                         name, 
                                         all_parameters)
    os.chdir(cpu_dir)
    SIMD_test_harness.main(all_parameters)
    SIMD_test_bench.main(all_parameters)
    return name

def build():
    parameters = parameters_misc.parse_cmdline(sys.argv[1:])
    instance = do_build(parameters)
    print instance

