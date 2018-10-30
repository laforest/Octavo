#! /usr/bin/python3

from sys import exit
from pprint import pprint
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

        # Print simple code/data dump to check if we have resolved everything
        print("\nCurrent shared variables:")
        for variable in self.data.shared:
            print(variable)
        print("\nCurrent private variables:")
        for variable in self.data.private:
            print(variable)
        print("\nCurrent pointer variables:")
        for variable in self.data.pointers:
            print(variable)
        print("\nCurrent port variables:")
        for variable in self.data.ports:
            print(variable)
        print("\nCurrent branches:")
        for branch in self.code.branches:
            print(branch)

    def resolve_read_operands (self):
        for instruction in self.code.all_instructions():
            self.resolve_read_operand(instruction, "A")
            self.resolve_read_operand(instruction, "B")

    def resolve_read_operand (self, instruction, operand):
        value = getattr(instruction, operand)
        # Source is all strings, convert to int if possible
        value = self.try_int(value)
        # Zero has address zero, so nothing to do then.
        if type(value) == int and value == 0:
            setattr(instruction, operand, 0)
            print(operand, value, 0)
            return
        # If it's a non-zero number, add it to the shared memory pool
        if type(value) == int:
            address = self.data.resolve_shared(value, operand)
            setattr(instruction, operand, address)
            print(operand, value, address)
            return
        # If it's a string, look it up and add it to whichever memory area it belongs to
        if type(value) == str:
            address = self.data.resolve_named(value, operand)
            print(operand, value, address)
            setattr(instruction, operand, address)
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
        print(instruction.opcode, instruction.D, instruction.A, instruction.B)

    def resolve_write_operand_case (self, instruction, operand):
        value = getattr(instruction, operand)
        # Source is all strings, convert to int if possible
        value = self.try_int(value)
        # Literal ints as destination denote an absolute (thread) address
        if type(value) == int:
            setattr(instruction, operand, value);
            return
        # If it's a string, look it up, and replace with its write address
        if type(value) == str:
            dummy, variable = self.data.lookup_variable(value)
            memory          = variable.memory
            address         = self.data.resolve_named(value, memory)
            address         = self.configuration.memory_map.read_to_write_address(address, memory)
            setattr(instruction, operand, address)
            return

    def resolve_pointers (self):
        for pointer in self.data.pointers:
            self.resolve_pointer(pointer)

    def resolve_pointer (self, pointer):
        read_variable_list, read_variable   = self.data.lookup_variable(pointer.read_base)
        write_variable_list, write_variable = self.data.lookup_variable(pointer.write_base)
        read_variable.memory    = pointer.memory
        write_variable.memory   = pointer.memory
        read_variable.address   = self.data.next_variable_address(read_variable_list,  read_variable.memory)
        # Don't allocate twice if read/write are the same variable
        if write_variable != read_variable:
            write_variable.address  = self.data.next_variable_address(write_variable_list, write_variable.memory)
        pointer.read_base       = read_variable.address
        pointer.write_base      = write_variable.address

