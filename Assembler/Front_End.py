#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Front_End:
    """Parses the assembly language commands into intermediate structures and various dependency resolutions. Drives the back end for code generation."""

    def __init__ (self, back_end, front_end_data, front_end_code):
        self.back_end       = back_end
        self.front_end_data = front_end_data
        self.front_end_code = front_end_code

    def parse_command (self, command, arguments):
        label               = None
        front_end_command   = getattr(self, command, None)

        if front_end_command is None:
            label       = command
            command     = arguments[0]
            arguments   = arguments[1:]
            print("Found label: {0} for command {1}".format(label, command))
            front_end_command   = getattr(self, command, None)
            if front_end_command is None:
                print("Unknown front-end command: {0}".format(command))
                exit(1)
        else:
            print("Found command: {0}".format(command))

        arguments.insert(0, label)
        front_end_command(arguments)

    def opcode (self, arguments):
        self.back_end.OD.define(*arguments) 

    def condition (self, arguments):
        self.back_end.BD.condition(*arguments) 

    def variable (self, arguments):
        self.front_end_data.variable(*arguments)

    def array (self, arguments):
        label   = arguments[0]
        values  = arguments[1:]
        self.front_end_data.array(label, values)

    def pointer (self, arguments):
        self.front_end_data.pointer(*arguments)

    def constant (self, arguments):
        self.front_end_data.constant(*arguments)

    def port (self, arguments):
        self.front_end_data.port(*arguments)

    def threads (self, arguments):
        # Discard any label, pass remaining list
        thread_list = arguments[1:]
        self.front_end_code.threads(thread_list)
