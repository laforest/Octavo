#! /usr/bin/python3

from sys    import exit
from pprint import pprint
from Debug  import Debug

class Commands (Debug):
    """Parses the assembly language commands into intermediate structures for later dependency resolutions."""

    def __init__ (self, data, code):
        Debug.__init__(self)
        self.data = data
        self.code = code

    def search_command(self, command):
        assembler   = getattr(self, command, None) is not None
        opcode      = command in [opcode.label for opcode in self.code.opcodes]
        condition   = command in [condition.label for condition in self.code.conditions] 
        return (assembler, opcode, condition)

    def find_command (self, command):
        found_flags = self.search_command(command)
        return True in found_flags

    def execute_command (self, command, arguments):
        assembler, opcode, condition = self.search_command(command)
        if assembler is True:
            assembler_command = getattr(self, command, None)
            assembler_command(arguments)
            return
        if opcode is True:
            self.code.allocate_instruction(command, arguments)
            return
        if condition is True:
            self.code.allocate_branch(command, arguments)
            return

    def parse_command (self, command, arguments):
        label               = None
        command_exists = self.find_command(command)

        if command_exists is False:
            label       = command
            command     = arguments[0]
            arguments   = arguments[1:]
            print("Found label: {0} for command {1}".format(label, command))
        else:
            print("Found command: {0}".format(command))
        arguments.insert(0, label)

        command_exists = self.find_command(command)

        if command_exists is False:
            print("Unknown command: {0}".format(command))
            exit(1)

        self.execute_command(command, arguments)

    # These are the assembler commands.

    def opcode (self, arguments):
        self.code.allocate_opcode(*arguments)

    def condition (self, arguments):
        self.code.allocate_condition(*arguments)

    def private (self, arguments):
        label   = arguments[0]
        values  = arguments[1:]
        self.data.allocate_private(label, values)

    def shared (self, arguments):
        label   = arguments[0]
        values  = arguments[1:]
        self.data.allocate_shared(label, values)

    def pointer (self, arguments):
        self.data.allocate_pointer(*arguments)

    def port (self, arguments):
        self.data.allocate_port(*arguments)

    def threads (self, arguments):
        label       = arguments[0]
        thread_list = arguments[1:]
        if label is not None:
            print("No label ({0}) allowed for command threads".format(label))
            exit(1)
        self.code.set_current_threads(thread_list)

    def init (self, arguments):
        self.code.allocate_init_load(*arguments)

    def program_counter (self, arguments):
        label       = arguments[0]
        pc_list     = arguments[1:]
        if label is not None:
            print("No label ({0}) allowed for command program_counter".format(label))
            exit(1)
        self.code.set_pc(label, pc_list)

