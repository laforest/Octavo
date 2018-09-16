
#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Instruction:
    """Contains symbolic information to assemble the bit representation of an instruction""" 

    def __init__ (self):
        self.label      = None
        self.address    = None
        self.opcode     = None
        self.D          = None
        self.DA         = None
        self.DB         = None
        self.A          = None
        self.B          = None

class Branch_Load:
    """Contains info necessary to generate the branch load instruction and init data"""

    def __init__ (self):
        self.label          = None
        self.target         = None
        self.instruction    = Instruction()
        self.init_data      = Variable()

class Front_End_Code:
    """Parses the code, which drives the resolution of unknowns about the data."""

    def __init__ (self, back_end, front_end_data):
        self.back_end       = back_end
        self.front_end_data = front_end_data
        self.branch_loads   = []

    def threads (self, thread_list):
        self.back_end.T.current = thread_list

    def load_branch (self, label, branch_label):
        new_branch_load         = Branch_Load()
        new_branch_load.label   = label
        new_branch_load.target  = branch
