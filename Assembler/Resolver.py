#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Resolver:
    """Takes the allocated intermediate structures and resolves names, addresses, and code. The final result gets used for binary image generation."""

    def __init__ (self, data, code, configuration):
        self.data           = data
        self.code           = code
        self.configuration  = configuration
        self.shared_index   = {"A":1, "B":1}

    def try_int (self, value):
        try:
            value = int(value, 0)
        except ValueError:
            pass
        return value

    def resolve (self):
        self.resolve_read_operands()

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
            address = self.data.resolve_named_read(value, operand)
            print(operand, value, address)
            setattr(instruction, operand, address)
            return
            

 
