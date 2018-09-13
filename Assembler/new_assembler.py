#! /usr/bin/python3

import Parser, Front_End, Back_End, Front_End_Data, Front_End_Code

from sys import argv

if __name__ == "__main__":
    back_end        = Back_End.Back_End()
    front_end_data  = Front_End_Data.Front_End_Data()
    front_end_code  = Front_End_Code.Front_End_Code(back_end, front_end_data)
    front_end       = Front_End.Front_End(back_end, front_end_data, front_end_code)
    parser          = Parser.Parser(front_end)
    parser.parse_file(argv[1])
    print("OK")

