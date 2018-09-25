#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Resolver:
    """Takes the allocated intermediate structures and resolves names, addresses, and code. The final result gets used for binary image generation."""

    def __init__ (self, data, code):
        self.data = data
        self.code = code

    def resolve (self):
        print("I'm alive!")

