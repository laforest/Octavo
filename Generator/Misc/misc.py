#! /usr/bin/python

"""
Misc. utilities
"""

import os
import stat
import string
import math

# Use these in the generators
bench_name          = "test_bench"
harness_name        = "test_harness"
quartus_base_path   = "$QUARTUS_BASE"

def base_install_path():
    """Returns the base path of the installation. Adjust to match installation."""
    depth_from_base = 2
    raw_path = os.path.dirname(os.path.realpath(__file__))
    return os.path.join(os.sep, *raw_path.split(os.sep)[:-depth_from_base])

def log2(num):
    """Returns the integer ceiling of the base-2 log. Useful to calculate
    address widths."""
    return int(math.ceil(math.log(num, 2)))

#def chop_lines(block, lines = 1):
#    return "\n".join(block.split('\n')[:-lines])

def indent(block, levels = 1):
    tab_depth = 4
    return "\n".join((levels * tab_depth * " ") + line
                     for line in block.splitlines())

def write_file(path, filename, contents):
    filepath  = os.path.join(path, filename)
    try:
        os.mkdir(path)
    except OSError:
        pass
    with open(filepath, 'w') as this_file:
        this_file.write(contents)

def read_file(path, filename):
    filepath  = os.path.join(path, filename)
    with open(filepath, 'r') as this_file:
        contents = this_file.read()
    return contents

def make_file_executable(path, filename):
    filepath = os.path.join(path, filename)
    os.chmod(filepath, os.stat(filepath).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    return

# ECL I think this is no longer used.

#def wire_name(port, part, column, row):
#    return "{0}_{1}[{2}][{3}]".format(port, part, column, row)
#
#def port_name(port, part):
#    return "{0}_{1}".format(port, part)
#
#def port_string(port, wire):
#    return ".{0}    ({1}),\n".format(port, wire)
#
#def all_port_strings(column, row):
#    all_ports = []
#    ports = ["A", "B"]
#    parts = ["in", "out", "wren"]
#    for port in ports:
#        for part in parts:
#            wire = wire_name(port, part, column, row)
#            this_port = port_name(port, part)
#            this_port = port_string(this_port, wire)
#            all_ports.append(this_port)
#    all_ports = "".join(all_ports)
#    return all_ports.rstrip(',')
    
