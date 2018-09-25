#! /usr/bin/python3

from Parser     import Parser
from Commands   import Commands
from Data       import Data
from Code       import Code

from sys import argv

if __name__ == "__main__":
    data        = Data()
    code        = Code(data)
    commands    = Commands(data, code)
    parser      = Parser(commands)
    parser.parse_file(argv[1])
    print("OK")

