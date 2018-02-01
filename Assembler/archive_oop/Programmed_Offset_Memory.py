#! /usr/bin/python

from Memory import Memory
from sys import exit

class Programmed_Offset_Memory(Memory):
    """Extends Memory to assemble Programmed Offset Memory entries.
       Not used to dump an initialization memory image,
       but to define and return indirect memory offsets and increment definitions
       to a higher assembler."""

    def __init__(self, file_name, depth = 0, width = 0, write_offset = 0):
        Memory.__init__(self, file_name, depth = depth, width = width, write_offset = write_offset)
        
