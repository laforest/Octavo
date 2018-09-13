#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Variable:
    """Describes a variable and what we know about it so far"""

    def __init__ (self):
        self.label   = None
        self.address = None
        self.value   = None
        self.memory  = None

class Pointer (Variable):
    """Describes pointer initialization data and which indirect memory slot it refers to"""

    def __init__ (self):
        Variable.__init__(self)
        self.read_base  = None
        self.read_incr  = None
        self.write_base = None
        self.write_incr = None
        self.slot       = None

class Port (Variable):
    """Describes an I/O port. Derive address from port number."""

    def __init__ (self):
        Variable.__init__(self)
        self.number = None

class Front_End_Data:
    """Contains descriptions of data and resolves locations, etc... before passing to back-end for memory image generation"""

    def __init__ (self):
        self.variables  = []
        self.pointers   = []
        self.constants  = []
        self.ports      = []

    def variable (self, label, initial_value):
        new_variable        = Variable()
        new_variable.label  = label
        new_variable.value  = int(initial_value, 0)
        self.variables.append(new_variable)

    def array (self, label, initial_values):
        new_array       = Variable()
        new_array.label = label
        new_array.value = [int(value, 0) for value in initial_values]
        self.variables.append(new_array)

    def pointer (self, label, read_base, read_incr, write_base, write_incr):
        new_pointer             = Pointer()
        new_pointer.label       = label
        # The bases are labels until resolved to addresses
        new_pointer.read_base   = read_base
        new_pointer.read_incr   = int(read_incr, 0)
        new_pointer.write_base  = write_base
        new_pointer.write_incr  = int(write_incr, 0)
        new_pointer.slot        = len(self.pointers)
        # We can't determine the init value until we know which Data Memory it's read from.
        # This also affects the placement of the referred-to pointer/array
        new_pointer.value       = None
        self.pointers.append(new_pointer)

    def constant (self, label, value):
        new_constant        = Variable()
        new_constant.label  = label
        new_constant.value  = int(value, 0)
        self.constants.append(new_constant)

    def port (self, label, number):
        new_port        = Port()
        new_port.label  = label
        new_port.number = int(number, 0)
        self.ports.append(new_port)

