
#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Front_End_Code:
    """Parses the code, which drives the resolution of unknowns about the data."""

    def __init__ (self, back_end, front_end_data):
        self.back_end       = back_end
        self.front_end_data = front_end_data

    def threads (self, thread_list):
        self.back_end.T.current = thread_list

