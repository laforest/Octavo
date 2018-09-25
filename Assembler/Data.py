#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Variable:
    """Describes a variable and what we know about it so far"""

    def __init__ (self, label = None, address = None, value = None, memory = None):
        self.label   = label
        self.address = address
        self.value   = value
        self.memory  = memory

class Pointer:
    """Describes pointer initialization data and which indirect memory slot it refers to"""

    def __init__ (self, label = None, address = None, value = None, memory = None, read_base = None, read_incr = None, write_base = None, write_incr = None, slot = None):
        self.init_data  = Variable(label = label, address = address, value = value, memory = memory)
        self.read_base  = read_base
        self.read_incr  = read_incr
        self.write_base = write_base
        self.write_incr = write_incr
        self.slot       = slot

class Port:
    """Describes an I/O port. Derive address from port number. Has no value (set to 0)."""

    def __init__ (self, label = None, address = None, memory = None, number = None):
        self.data   = Variable(label = label, address = address, value = 0, memory = memory)
        self.number = number

class Data:
    """Contains descriptions of data and resolves locations, etc... before passing to back-end for memory image generation"""

    def __init__ (self):
        self.private    = []
        self.shared     = []
        self.pointers   = []
        self.ports      = []

    def create_variable (self, label, initial_values = None):
        if initial_values is not None:
            initial_values = [int(entry, 0) for entry in initial_values]
            if len(initial_values) == 1:
                initial_values = initial_values[0]
        new_variable = Variable(label = label, value = initial_values)
        return new_variable

    def allocate_private (self, label, initial_values = None):
        new_variable = self.create_variable(label, initial_values = initial_values)
        self.private.append(new_variable)
        return new_variable

    def allocate_shared (self, label, initial_values = None):
        new_variable = self.create_variable(label, initial_values = initial_values)
        self.shared.append(new_variable)
        return new_variable

    def allocate_pointer (self, label, read_base = None, read_incr = None, write_base = None, write_incr = None):
        # We can't determine the init data value until we know which Data Memory it's read from.
        # This also affects the placement of the referred-to pointer/array.
        # The bases are labels until resolved to addresses
        read_incr   = int(read_incr, 0)
        write_incr  = int(write_incr, 0)
        # assign next consecutive slot (later improve to grant first freed slot)
        slot        = len(self.pointers)
        new_pointer = Pointer(label = label, read_base = read_base, read_incr = read_incr, write_base = write_base, write_incr = write_incr)
        self.pointers.append(new_pointer)
        return new_pointer

    def allocate_port (self, label, number):
        number      = int(number, 0)
        new_port    = Port(label = label, number = number)
        self.ports.append(new_port)
        return new_port

