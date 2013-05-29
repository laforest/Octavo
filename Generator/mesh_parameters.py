#! /usr/bin/python

"""
Generates a dict of all Verilog parameters for a specific Octavo mesh instance.
Parameters are taken from those of the constituent Octavo CPU instances.
"""

import copy
import os

import parameters_misc

def above(distance = 1):
    column = 0
    row = -distance
    return (column, row)

def below(distance = 1):
    column = 0
    row = distance
    return (column, row)

def left(distance = 1):
    column = -distance
    row = 0
    return (column, row)

def right(distance = 1):
    column = distance
    row = 0
    return (column, row)

def sum_movements(vertical, horizontal, distance = 1):
    vertical_column, vertical_row = vertical(distance)
    horizontal_column, horizontal_row = horizontal(distance)
    return (vertical_column + horizontal_column, vertical_row + horizontal_row)

def above_right(distance = 1):
    return sum_movements(above, right, distance)

def above_left(distance = 1):
    return sum_movements(above, left, distance)

def below_right(distance = 1):
    return sum_movements(below, right, distance)

def below_left(distance = 1):
    return sum_movements(below, left, distance)

mesh_topologies = {
    "SQUARE":{"A":{"CONNECTS":[above(), below()],
                   "PIPE":[0, 0]},
              "B":{"CONNECTS":[left(), right()],
                   "PIPE":[0, 0]}},
# NOT SUPPORTING SKIPS: TOO COMPLICATED
#    "SQUARE_SKIP":{"A":{"CONNECTS":[above(), above(2), below(), below(2)],
#                        "PIPE":[0, 0, 0, 0]},
#                   "B":{"CONNECTS":[left(), left(2), right(), right(2)],
#                        "PIPE":[0, 0, 0, 0]}},
    "SQUARE_DOUBLE_A":{"A":{"CONNECTS":[above(), above(), below(), below()],
                            "PIPE":[0, 0, 0, 0]},
                       "B":{"CONNECTS":[left(), right()],
                            "PIPE":[0, 0]}},
    "SQUARE_DOUBLE_B":{"A":{"CONNECTS":[above(), below()],
                            "PIPE":[0, 0, 0, 0]},
                       "B":{"CONNECTS":[left(), left(), right(), right()],
                            "PIPE":[0, 0]}},
    "SQUARE_DOUBLE_AB":{"A":{"CONNECTS":[above(), above(), below(), below()],
                             "PIPE":[0, 0, 0, 0]},
                        "B":{"CONNECTS":[left(), left(), right(), right()],
                             "PIPE":[0, 0, 0, 0]}},
    "TETRAKIS":{"A":{"CONNECTS":[above(), below(), left(), right()],
                     "PIPE":[0, 0, 0, 0]},
                "B":{"CONNECTS":[above_left(), above_right(), below_left(), below_right()],
                     "PIPE":[0, 0, 0, 0]}},
    "TRIANGULAR":{"A":{"CONNECTS":[above_left(), below(), right()],
                       "PIPE":[0, 0, 0]},
                  "B":{"CONNECTS":[below_right(), above(), left()],
                       "PIPE":[0, 0, 0]}},
    }


def mesh_dimensions(parameters):
    width = parameters["COLUMNS"]
    depth = parameters["ROWS"]
    return (width, depth)

def common_values(parameters = {}, mesh_topologies = mesh_topologies):
    common_values = {
        "COLUMNS":None,
        "ROWS":None,
        "TOPOLOGY":None}
    parameters_misc.override(common_values, parameters)
    
    width = common_values["COLUMNS"]
    depth = common_values["ROWS"]
    topology_name = common_values["TOPOLOGY"]
    topology_data = mesh_topologies[topology_name]

    cpu_name = parameters["BASE_CPU"]
    mesh_name = "Mesh_{0}x{1}_{2}_{3}".format(width, depth, topology_name, cpu_name)
    cpu_parameters = parameters_misc.get_parameters(os.getcwd(), cpu_name)
    assert cpu_parameters != {}, "Couldn't find base CPU {0}".format(cpu_name)

    common_values["TOPOLOGY"] = {topology_name:topology_data}
    common_values.update({"NAME":mesh_name})
    common_values.update({"BASE_CPU":cpu_parameters})
    return common_values

def node_mesh(parameters):
    width, depth = mesh_dimensions(parameters)
    default_entry = {"CPU_OVERRIDES":{}}
    mesh = [[[] for column in range(width)] for row in range(depth)]
    for row in range(depth):
        for column in range(width):
            entry = copy.deepcopy(default_entry)
            instance_name = "CPU_{0}_{1}".format(column, row)
            entry.update({"NAME":instance_name})
            mesh[row][column] = entry
    return mesh

def get_node_parameters(column, row, parameters):
    cpu_parameters = parameters["BASE_CPU"]
    cpu_overrides = parameters["NODES"][row][column]["CPU_OVERRIDES"]
    node_parameters = copy.deepcopy(cpu_parameters)
    node_parameters.update(cpu_overrides)
    return node_parameters

def update_node_parameters(column, row, parameters = {}, new_parameters = {}):
    node_parameters = parameters["NODES"][row][column]
    node_parameters.update(new_parameters)

def all_parameters(parameters = {}):
    all_parameters = common_values(parameters)
    mesh = node_mesh(all_parameters)
    all_parameters.update({"NODES":mesh})
    return all_parameters

if __name__ == "__main__":
    import pprint
    parameters = all_parameters(parameters = {"BASE_CPU":"Octavo_A2i2o_B2i2o_1dp",
                                              "COLUMNS":3,
                                              "ROWS":3,
                                              "TOPOLOGY":"SQUARE"})
    pprint.pprint(parameters)
