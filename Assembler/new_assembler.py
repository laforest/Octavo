#! /usr/bin/python3

import Parser, Front_End, Front_End_Data, Front_End_Code

from sys import argv

if __name__ == "__main__":
    front_end_data  = Front_End_Data.Front_End_Data()
    front_end_code  = Front_End_Code.Front_End_Code(front_end_data)
    front_end       = Front_End.Front_End(front_end_data, front_end_code)
    parser          = Parser.Parser(front_end)
    parser.parse_file(argv[1])
    print("OK")

