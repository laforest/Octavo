#! /usr/bin/python

import os
import sys

from Misc import misc, parameters_misc
import Scalar_parameters 
import Scalar_definition
import Scalar_test_harness
import Scalar_test_bench

def do_build(parameters = {}):
    all_parameters = Scalar_parameters.all_parameters(parameters)
    definition     = Scalar_definition.definition(all_parameters)
    name           = all_parameters["CPU_NAME"]
    Scalar_dir     = os.path.join(os.getcwd(), name)
    misc.write_file(Scalar_dir, name + ".v", definition)
    parameters_misc.write_parameter_file(Scalar_dir, 
                                         name, 
                                         all_parameters)
    os.chdir(Scalar_dir)
    Scalar_test_harness.main(all_parameters)
    Scalar_test_bench.main(all_parameters)
    return name

def build():
    parameters = parameters_misc.parse_cmdline(sys.argv[1:])
    instance = do_build(parameters)
    print instance

