#! /usr/bin/python3

import Preprocessor
import Command_Parser

from sys import argv

if __name__ == "__main__":
    pp = Preprocessor.Preprocessor()
    cp = Command_Parser.Command_Parser()
    pp.parse_file(argv[1])
    cp.parse_commands(pp.Lines)
    print("OK")

