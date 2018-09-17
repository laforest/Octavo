
#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Instruction:
    """Contains symbolic information to assemble the bit representation of an instruction""" 

    def __init__ (self, label = None, address = None, opcode = None, D = None, DA = None, DB = None, A = None, B = None):
        self.label      = label
        self.address    = address
        self.opcode     = opcode
        self.D          = D
        self.DA         = DA
        self.DB         = DB
        self.A          = A
        self.B          = B

class Initialization_Load:
    """Contains info necessary to generate an initialization load instruction and data.
       The instruction is always an 'Add to Zero', so must exist in the system.
       The destination is a code or data label."""

    def __init__ (self, front_end_data, label = None, destination = None,):
        self.label          = label
        self.destination    = destination
        self.instruction    = Instruction(label = label, opcode = "add")
        self.init_data      = front_end_data.allocate_variable(label)

class Front_End_Code:
    """Parses the code, which drives the resolution of unknowns about the data."""

    def __init__ (self, back_end, front_end_data):
        self.back_end       = back_end
        self.front_end_data = front_end_data
        self.branch_loads   = []
        self.pointer_loads  = []
        self.instructions   = []

    def set_current_threads (self, thread_list):
        self.back_end.T.current = thread_list

    def allocate_branch_load (self, label, destination_label):
        new_branch_load = Initialization_Load(self.front_end_data, label = label, destination = destination_label)
        self.branch_loads.append(new_branch_load)
        self.instructions.append(new_branch_load.instruction)
        return new_branch_load

    def allocate_pointer_load (self, label, destination_label):
        new_pointer_load = Initialization_Load(self.front_end_data, label = label, destination = destination_label)
        self.pointer_loads.append(new_pointer_load)
        self.instructions.append(new_pointer_load.instruction)
        return new_pointer_load
