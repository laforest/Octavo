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
        try:
            value = int(value, 0)
        except ValueError:
            pass
        return value

    def resolve (self):
        self.resolve_read_operands()
        self.resolve_write_operands()
        self.resolve_branches()

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

    def resolve_branches (self):
        for branch in self.code.branches:
            self.resolve_branch(branch)

    def resolve_branch (self, branch):
        init_load           = self.code.lookup_init_load(branch.destination)
        instruction_label   = init_load.label
        # First, the instruction/data to init the branch detector entry
        init_load.add_instruction(label = instruction_label)
        init_load.add_shared(label = branch.destination + "_init")
        # Then add any instr/data to init other hardware if necessary
        # Since init is identical across threads, the data is shared
        if branch.sentinel_a is not None:
            init_load.add_instruction()
            init_load.add_shared(label = branch.destination + "_init_sentinel_a")
            init_load.add_instruction()
            init_load.add_shared(label = branch.destination + "_init_mask_a")
        if branch.sentinel_b is not None:
            init_load.add_instruction()
            init_load.add_shared(label = branch.destination + "_init_sentinel_b")
            init_load.add_instruction()
            init_load.add_shared(label = branch.destination + "_init_mask_b")
        if branch.counter is not None:
            init_load.add_instruction()
            init_load.add_shared(label = branch.destination + "_init_counter")
        pprint(init_load.__dict__)
