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

    def resolve_read_operand (self, instruction, operand_name):
        operand = getattr(instruction, operand_name)
        # Source is all strings, convert to int if possible
        operand = self.try_int(operand)
        # Zero has address zero, so nothing to do then.
        if type(operand) == int and operand == 0:
            setattr(instruction, operand_name, 0)
            print(operand_name, operand, 0)
            return
        # If it's a non-zero number, add it to the shared memory pool
        if type(operand) == int:
            address = self.data.resolve_shared(operand, operand_name)
            setattr(instruction, operand_name, address)
            print(operand_name, operand, address)
 
