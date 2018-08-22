#! /usr/bin/python3

"""
Syntax:
All entries are a single line each
Words are non-whitespace separated by any whitespace, except line-endings
'#' starts a comment, anywhere, until the end of the line
If the first character of a line is a whitespace, that's noted as either a lack of a name
for that memory location, or a terminator for a previous command.
"""

class Line:
    """Line and metadata for debugging assistance"""
    def __init__(self, filename, line_number, raw_line, words):
        self.filename       = filename
        self.line_number    = line_number
        self.raw_line       = raw_line
        self.words          = words

class Preprocessor:
    """Read in raw lines and parse into words"""
    def __init__ (self):
        self.Lines = []

    def recurse_include (self, raw_line):
        """Begin a line with "include <filename>" to recursively include a file. No protection against include loops!"""
        split_line  = raw_line.split()
        if len(split_line) == 0:
            return False
        if split_line[0] == "include":
            self.read_file(split_line[1])
            return True
        return False

    def read_file (self, filename):
        with open(filename) as f:
            raw_lines = f.readlines()
            line_numbers = range(1,len(raw_lines)+1)
            for line_number, raw_line in zip(line_numbers, raw_lines):
                # Don't include the "include <filename>" line when encountered
                if self.recurse_include(raw_line) == False:
                    self.Lines.append(Line(filename, line_number, raw_line, None))

    def strip_comments (self):
        for line in self.Lines:
            stripped_line = line.raw_line.split("#")
            line.words    = stripped_line[0]

    def parse_lines (self):
        for line in self.Lines:
            line.words = line.words.split()
            # Place None as marker that first word was not at start of line
            if line.raw_line[0].isspace():
                line.words.insert(0,None)

    def remove_blanks (self):
        self.Lines = [line for line in self.Lines if len(line.words) > 0]
        self.Lines = [line for line in self.Lines if line.words != [None]]

    def parse_file (self, filename):
        self.read_file(filename)
        self.strip_comments()
        self.parse_lines()
        self.remove_blanks()

if __name__ == "__main__":
    from sys import argv, exit
    from pprint import pprint
    pp = Preprocessor()
    pp.parse_file(argv[1])
    for line in pp.Lines:
        #pprint((line.filename, line.line_number, line.raw_line), width=200)
        pprint((line.filename, line.line_number, line.words), width=200)

