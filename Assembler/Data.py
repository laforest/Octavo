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

class Pointer (Variable):
    """Describes pointer initialization data and which indirect memory slot it refers to"""

    def __init__ (self, label = None, address = None, value = None, memory = None, read_base = None, read_incr = None, write_base = None, write_incr = None, slot = None):
        Variable.__init__(self, label = label, address = address, value = value, memory = memory)
        self.read_base  = read_base
        self.read_incr  = read_incr
        self.write_base = write_base
        self.write_incr = write_incr
        self.slot       = slot

class Port (Variable):
    """Describes an I/O port. Derive address from port number. Has no value (set to 0)."""

    def __init__ (self, label = None, address = None, memory = None, number = None):
        Variable.__init__(self, label = label, address = address, value = 0, memory = memory)
        self.number = number

class Data:
    """Contains descriptions of data and resolves locations, etc... before passing to back-end for memory image generation"""

    def __init__ (self, configuration):
        self.private    = []
        self.shared     = []
        self.pointers   = []
        self.ports      = []
        self.configuration = configuration

    def create_variable (self, label, initial_values = None):
        if initial_values is not None:
            if type(initial_values) == list:
                initial_values = [int(entry, 0) for entry in initial_values]
            elif type(initial_values) == str:
                initial_values = [int(initial_values, 0)]
            elif type(initial_values) == int:
                initial_values = [initial_values]
            else:
                print("Unusable initial value {0} for variable {1}".format(label, initial_values))
                exit(1)
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

    def allocate_port (self, label, memory, number):
        number      = int(number, 0)
        new_port    = Port(label = label, number = number, memory = memory)
        self.ports.append(new_port)
        return new_port

    def lookup_shared_value (self, value):
        for entry in self.shared:
            if entry.value == value:
                return entry
        return None

    def lookup_variable (self, label):
        for memory_list in [self.shared, self.private, self.pointers, self.ports]:
            for entry in memory_list:
                if entry.label == label:
                    return (memory_list, entry)
        return (None, None)

    def next_variable_address (self, variables):
        # No variable at address zero, ever. (Zero Register)
        # Add the length of the data of the max-addressed variable
        # so we return the next address just past its value(s)
        max_address     = 0
        max_data_length = 1
        for variable in variables:
            address = variable.address
            if address is not None:
                if address > max_address:
                    max_address     = address
                    max_data_length = len(variable.value)
        return max_address + max_data_length

    def next_pointer_slot (self, pointers):
        # Pointer slots start at zero
        max_slot = -1
        for pointer in pointers:
            slot = pointer.slot
            if slot is not None:
                max_slot = max(slot, max_slot)
        return max_slot + 1

    def resolve_shared (self, value, memory):
        entry = self.lookup_shared_value(value)
        if entry is None:
            entry = self.allocate_shared(None, initial_values = value)
        if entry.address is None:
            entry.address = self.next_variable_address(self.shared)
        if entry.memory != memory and entry.memory is not None:
            print("Conflicting memory allocation for shared value {0}. Was {1}, now {2}".format(value, entry.memory, memory))
            exit(1)
        entry.memory = memory 
        return entry.address

    def resolve_named (self, name, memory):
        memory_list, entry = self.lookup_variable(name)

        if memory_list is None:
            print("Unknown label {0}".format(name))
            exit(1)

        if memory_list == self.shared:
            value = entry.value
            address = self.resolve_shared(value, memory)
            return address

        if memory_list == self.private:
            if entry.address is None:
                entry.address = self.next_variable_address(self.private)
            if entry.memory != memory and entry.memory is not None:
                print("Conflicting memory allocation for private variable {0}. Was {1}, now {2}".format(name, entry.memory, memory))
                exit(1)
            entry.memory = memory 
            return entry.address

        if memory_list == self.ports:
            if entry.address is None:
                entry.address = self.configuration.memory_map.io[entry.number]
            if entry.memory != memory:
                print("Conflicting memory allocation for I/O port {0}. Was {1}, now {2}".format(name, entry.memory, memory))
                exit(1)
            return entry.address
            
        if memory_list == self.pointers:
            if entry.slot is None:
                entry.slot = self.next_pointer_slot(self.pointers)
            if entry.address is None:
                entry.address = self.configuration.memory_map.indirect[entry.slot]
            if entry.memory != memory and entry.memory is not None:
                print("Conflicting memory allocation for I/O port {0}. Was {1}, now {2}".format(name, entry.memory, memory))
                exit(1)
            entry.memory = memory 
            return entry.address
            
        
