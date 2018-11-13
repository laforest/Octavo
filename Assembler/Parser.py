#! /usr/bin/python3

from Debug import Debug

class Parser (Debug):
    """Parses the assembly file lines and passes non-file commands to the command parser"""
    
    def __init__ (self, commands):
        Debug.__init__(self)
        self.commands = commands

    def strip_comments (self, line):
        """Return line without trailing comments. If comment starts a line, return empty line."""
        stripped_line   = line.split("#")
        stripped_line   = stripped_line[0]
        stripped_line   = stripped_line.strip()
        return stripped_line

    def parse_line (self, line):
        """Process each line, converting the command name into a method call to built-in assembler commands (not part of the programming per se)
           or pass it to command parser if unknown. First word is the command, the rest are it's arguments. (but see parse_commands re: labels)"""
        line = self.strip_comments(line)
        if len(line) == 0:
            return
        split_line      = line.split()
        command         = split_line[0]
        arguments       = split_line[1:]
        parser_command  = getattr(self, command, None)
        if parser_command is None:
            self.commands.parse_command(command, arguments)
            return
        parser_command(arguments)

    def parse_file (self, filename):
        with open(filename) as f:
            for raw_line in f.readlines():
                self.parse_line(raw_line)

# These are assembler commands, not related to the programming itself.

    def include (self, arguments):
        """Recurse into included files. No cycle checking!"""
        filename = arguments[0]
        self.parse_file(filename)

