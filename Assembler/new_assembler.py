#! /usr/bin/python3

import Parser, Front_End, Back_End

from sys import argv

if __name__ == "__main__":
    back_end    = Back_End.Back_End()
    front_end   = Front_End.Front_End(back_end)
    parser      = Parser.Parser(front_end)
    parser.parse_file(argv[1])
    print("OK")

