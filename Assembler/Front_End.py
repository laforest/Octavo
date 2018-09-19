#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Front_End:
    """Parses the assembly language commands into intermediate structures and various dependency resolutions. Drives the back end for code generation."""

    def __init__ (self, back_end, front_end_data, front_end_code):
        self.back_end       = back_end
        self.front_end_data = front_end_data
        self.front_end_code = front_end_code

    def search_command(self, command):
        assembler   = getattr(self, command, None) is not None
        opcode      = command in [opcode.label for opcode in self.front_end_code.opcodes]
        condition   = command in [condition.label for condition in self.front_end_code.conditions] 
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
            self.front_end_code.allocate_instruction(command, arguments)
            return
        if condition is True:
            self.front_end_code.allocate_branch(command, *arguments)
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
            print("Unknown front-end command: {0}".format(command))
            exit(1)

        self.execute_command(command, arguments)

    # These are the assembler commands.

    def opcode (self, arguments):
        self.front_end_code.allocate_opcode(*arguments)

    def condition (self, arguments):
        self.front_end_code.allocate_condition(*arguments)

    def variable (self, arguments):
        self.front_end_data.allocate_variable(*arguments)

    def array (self, arguments):
        label   = arguments[0]
        values  = arguments[1:]
        self.front_end_data.allocate_array(label, values)

    def pointer (self, arguments):
        self.front_end_data.allocate_pointer(*arguments)

    def constant (self, arguments):
        self.front_end_data.allocate_constant(*arguments)

    def port (self, arguments):
        self.front_end_data.allocate_port(*arguments)

    def threads (self, arguments):
        # Discard any label, pass remaining list
        thread_list = arguments[1:]
        self.front_end_code.set_current_threads(thread_list)

    def load_branch (self, arguments):
        self.front_end_code.allocate_branch_load(*arguments)

    def load_pointer (self, arguments):
        self.front_end_code.allocate_pointer_load(*arguments)

