#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Resolver:
    """Takes the allocated intermediate structures and resolves names, addresses, and code. The final result gets used for binary image generation."""

    def __init__ (self, data, code, configuration):
        self.data           = data
        self.code           = code
        self.configuration  = configuration

    def try_int (self, value):
        if value is None:
            return None
        if type(value) == int:
            return value
        try:
            value = int(value, 0)
        except ValueError:
            # Assume it's a string. Leave it alone until resolution.
            pass
        except TypeError:
            print("\nInvalid type for int() conversion. Input {0} of type {1}.\n".format(value, type(value)))
            raise TypeError
        return value

    def resolve (self):
        self.resolve_read_operands()
        self.resolve_write_operands()

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

    def resolve_write_operand_case (self, instruction, operand):
        value = getattr(instruction, operand)
        print(instruction.opcode, value)
        # Source is all strings, convert to int if possible
        value = self.try_int(value)
        # Literal ints as destination denote an absolute (thread) address
        if type(value) == int:
            print(operand, value)
            setattr(instruction, operand, value);
            return
        # If it's a string, look it up, and replace with its write address
        if type(value) == str:
            dummy, variable = self.data.lookup_variable(value)
            memory          = variable.memory
            address         = self.data.resolve_named(value, memory)
            address         = self.configuration.memory_map.read_to_write_address(address, memory)
            print(operand, value, address)
            setattr(instruction, operand, address)
            return


