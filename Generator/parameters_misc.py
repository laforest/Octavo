#! /usr/bin/python

import pprint
import ast
import os

import misc

filename_extension = "_parameters.py"

def read_parameter_file(path, name):
    try:
        raw = misc.read_file(path, name + filename_extension)
    except IOError:
        raw = "{}"
    cooked  = ast.literal_eval(raw)
    return cooked

def get_parameters(directory, name):
    path = os.path.join(os.pardir, directory, name)
    parameters = read_parameter_file(path, name)
    return parameters

def write_parameter_file(path, name, parameters):
    misc.write_file(path, name + filename_extension, pprint.pformat(parameters))

def update_parameter_file(path, name, new_parameters):
    parameters = read_parameter_file(path, name)
    parameters.update(new_parameters)
    write_parameter_file(path, name, parameters)

def override(original, new):
    """Like update(), but only change entries that already exist. Prevents dict pollution."""
    for key,value in new.items():
        if key in original:
            original.update({key:value})

def parameter_string(name, value):
    return "parameter   {0}   = {1},\n".format(name, value)

def all_parameter_strings(parameters = {}):
    all_parameters = []
    for name, value in parameters.items():
        parameter = parameter_string(name, value)
        all_parameters.append(parameter)
    all_parameters = "".join(all_parameters)
    return all_parameters.rstrip().rstrip(',')

def parse_cmdline(entries):
    parameters = {}
    if len(entries) == 0:
        return parameters
    if entries[0] == "-f" and filename_extension in entries[1]:
        path, name = os.path.split(entries[1])
        name = name.replace(filename_extension, '')
        parameters = read_parameter_file(path, name)
        del entries[0:2]
    for entry in entries:
        parts = entry.split('=')
        assert len(parts) == 2, "Incorrect parameter formating for {0}. Use 'key=value'.".format(entry)
        key, value = tuple(parts)
        try:
            value = ast.literal_eval(value)
        except ValueError:
            if not (value == "ON" or value == "OFF"):
                raise ValueError, value
        parameters.update({key:value})
    return parameters
