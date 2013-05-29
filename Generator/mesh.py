#! /usr/bin/python

import os

import misc
import parameters_misc
import mesh_parameters 
import mesh_definition
import mesh_test_harness
import mesh_quartus_project

def mesh(parameters = {}):
    all_parameters = mesh_parameters.all_parameters(parameters)
    definition     = mesh_definition.definition(all_parameters)
    name           = all_parameters["NAME"]
    mesh_dir       = os.path.join(os.getcwd(), name)
    misc.write_file(mesh_dir, name + ".v", definition)
    parameters_misc.write_parameter_file(mesh_dir, 
                                         name, 
                                         all_parameters)
    
    test_harness_name = name + "_" + misc.harness_name
    test_harness      = mesh_test_harness.test_harness(all_parameters)
    test_harness_dir  = os.path.join(mesh_dir, misc.harness_name)
    misc.write_file(test_harness_dir, test_harness_name + ".v", test_harness)
    parameters_misc.update_parameter_file(mesh_dir, 
                                          name, 
                                          {"PROJECT_NAME":test_harness_name})
    all_parameters = parameters_misc.read_parameter_file(mesh_dir, name)
    mesh_quartus_project.project(all_parameters, test_harness_dir)

if __name__ == "__main__":
    mesh(parameters = {"BASE_CPU":"Octavo_A2i2o_B2i2o_1dp",
                       "COLUMNS":3,
                       "ROWS":3,
                       "TOPOLOGY":"SQUARE"})
