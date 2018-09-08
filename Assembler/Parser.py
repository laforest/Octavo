#! /usr/bin/python3

class Parser:
    """Parses the assembly file lines and passes non-file commands to the front-end"""
    
    def __init__ (self, front_end):
        self.front_end = front_end

    def strip_comments (self, line):
        """Return line without trailing comments. If comment starts a line, return empty line."""
        stripped_line   = line.split("#")
        stripped_line   = stripped_line[0]
        # Leave leading space, as it's syntactically significant (branch labels vs. opcodes)
        stripped_line   = stripped_line.rstrip()
        return stripped_line

    def parse_line (self, line):
        """Process each line, converting the command name into a method call, or pass it to front end."""
        line = self.strip_comments(line)
        if len(line) == 0:
            return
        split_line      = line.split()
        command         = split_line[0]
        arguments       = split_line[1:]
        parser_command  = getattr(self, command, None)
        if parser_command is None:
            self.front_end.parse_command(command, arguments)
            return
        parser_command(arguments)

    def include (self, arguments):
        """Recurse into included files. No cycle checking!"""
        filename = arguments[0]
        self.parse_file(filename)

    def parse_file (self, filename):
        with open(filename) as f:
            for raw_line in f.readlines():
                self.parse_line(raw_line)

