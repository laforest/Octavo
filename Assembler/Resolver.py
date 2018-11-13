#! /usr/bin/python3

from sys import exit
from Utility import Utility
from Debug import Debug

class Resolver (Utility, Debug):
    """Takes the allocated intermediate structures and resolves names, addresses, and code. The final result gets used for binary image generation."""

    def __init__ (self, data, code, configuration):
        Utility.__init__(self)
        Debug.__init__(self)
        self.data           = data
        self.code           = code
        self.configuration  = configuration

    def resolve (self):
        self.resolve_read_operands()
        self.resolve_write_operands()
        self.resolve_pointers()

    def resolve_read_operands (self):
        for instruction in self.code.all_instructions():
            self.resolve_read_operand(instruction, "A")
            self.resolve_read_operand(instruction, "B")

    def resolve_read_operand (self, instruction, operand):
        value = getattr(instruction, operand)
        # Source is all strings, convert to int if possible
        value = self.try_int(value)
        # If it's a literal number, add it to the shared memory pool
        if type(value) == int:
            entry = self.data.resolve_shared_value(value, operand)
        # If it's a string, look it up and add it to whichever memory area it belongs to
        elif type(value) == str:
            entry = self.data.resolve_named(value, operand)
        else:
            print("Read operand value has unexpected type!: {0}".format(value))
            print(instruction)
            exit(1)
        setattr(instruction, operand, entry.address)
        return

    def resolve_write_operands (self):
        for instruction in self.code.all_instructions():
            self.resolve_write_operand(instruction)

    def resolve_write_operand (self, instruction):
        is_dual = self.code.is_instruction_dual(instruction)
        if is_dual is True:
            self.resolve_write_operand_case(instruction, "DA")
            self.resolve_write_operand_case(instruction, "DB")
        else:
            self.resolve_write_operand_case(instruction, "D") 
#        print(instruction.opcode, instruction.D, instruction.A, instruction.B)

    def resolve_write_operand_case (self, instruction, operand):
        value = getattr(instruction, operand)
        # Source is all strings, convert to int if possible
        converted_value = self.try_int(value)
        # If its an int, nothing much to do.
        if type(converted_value) == int:
            setattr(instruction, operand, converted_value)
            return
        # If it's a string, look it up, and replace with its write address
        # The variable must have been used as a read operand before, so its
        # we have already set which memory it must reside in.
        elif type(converted_value) == str:
            variable = self.data.lookup_variable_name(converted_value)
            if variable is None:
                print("Unknown variable {0} used as write operand.".format(converted_value))
                print(instruction)
                exit(1)
            variable      = self.data.resolve_named(converted_value, variable.memory)
            write_address = self.configuration.memory_map.read_to_write_address(variable.address, variable.memory)
            setattr(instruction, operand, write_address)
            return
        else:
            print("Write operand value has unexpected type!: {0}".format(converted_value))
            print(instruction)
            exit(1)

    def resolve_pointers (self):
        for pointer in self.data.pointers:
            self.resolve_pointer(pointer)

    def resolve_pointer (self, pointer):
        read_variable  = self.data.lookup_variable_name(pointer.read_base)
        write_variable = self.data.lookup_variable_name(pointer.write_base)
        # A pointer only refers to locations in the same memory as it.
        # The pointer memory should have already been set by resolving an
        # instruction which reads/writes it.
        if read_variable.memory is not None and read_variable.memory != pointer.memory:
            print("Variable {0} already assigned to memory {1} and does not match read pointer {2}, memory {3}".format(read_variable.label, read_variable.memory, pointer.label, pointer.memory))
            exit(1)
        if write_variable.memory is not None and write_variable.memory != pointer.memory:
            print("Variable {0} already assigned to memory {1} and does not match write pointer {2}, memory {3}".format(write_variable.label, write_variable.memory, pointer.label, pointer.memory))
            exit(1)
        read_variable.memory    = pointer.memory
        write_variable.memory   = pointer.memory
        read_variable_type      = self.data.lookup_variable_type(read_variable)
        write_variable_type     = self.data.lookup_variable_type(write_variable)
        read_variable.address   = self.data.next_variable_address(read_variable_type,  read_variable.memory)
        # Don't allocate twice if read/write are the same variable
        if write_variable != read_variable:
            write_variable.address  = self.data.next_variable_address(write_variable_type, write_variable.memory)
        pointer.read_base       = read_variable.address
        pointer.write_base      = write_variable.address

