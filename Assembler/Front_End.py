#! /usr/bin/python3

from sys import exit

class Front_End:
    """Parses the assembly language commands into intermediate structures and various dependency resolutions. Drives the back end for code generation."""

    def __init__ (self, back_end):
        self.back_end = back_end

    def parse_command (self, command, arguments):
        front_end_command   = getattr(self, command, None)
        if front_end_command is None:
            # pass to back end if not found
            print("Command {0} not found!".format(command))
            exit(1)
        front_end_command(arguments)

    def opcode (self, arguments):
        print("reached opcode!")
        self.back_end.OD.define(*arguments) 
        
    def condition (self, arguments):
        print("reached branch condition!")
        self.back_end.BD.condition(*arguments) 
 
