#! /usr/bin/python

import os
import sys

import misc
import parameters_misc
import cpu_parameters 
import cpu_definition
import cpu_test_harness
import cpu_test_bench

def cpu(parameters = {}):
    all_parameters = cpu_parameters.all_parameters(parameters)
    definition     = cpu_definition.definition(all_parameters)
    name           = all_parameters["CPU_NAME"]
    cpu_dir        = os.path.join(os.getcwd(), name)
    misc.write_file(cpu_dir, name + ".v", definition)
    parameters_misc.write_parameter_file(cpu_dir, 
                                         name, 
                                         all_parameters)
    os.chdir(cpu_dir)
    cpu_test_harness.main(all_parameters)
    cpu_test_bench.main(all_parameters)
    return name

if __name__ == "__main__":
    parameters = parameters_misc.parse_cmdline(sys.argv[1:])
    instance = cpu(parameters)
    print instance

