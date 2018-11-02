#! /usr/bin/python3

from pprint import pformat
from sys    import exit

class Debug:
    """Common debug code."""

    def __init__ (self):
        pass

    def __str__ (self):
        """Debug information formatter."""
        return self.__class__.__name__ + " ({0}): ".format(hex(id(self))) + pformat(self.__dict__, width=160)

    def list_str (self, items):
        output = ""
        for entry in items:
            output += str(entry) + "\n"
        return output

    def filedump (self, filename, append = False):
        if append is False:
            mode = 'w'
        elif append is True:
            mode = 'a'
        else:
            print("debug filedump append flag must be True/False, not {0}".format(append))
            exit(1)
        with open(filename, mode) as f:
            print(self, end="", file=f)

