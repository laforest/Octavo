#! /usr/bin/python3

from pprint import pformat
from sys    import exit

class Debug:
    """Common debug code to give useful, clean object dumps. Use in conjunction with PDB."""

    def __init__ (self):
        pass

    def __str__ (self):
        """Debug information formatter. Override in sub-classes for more complex structures."""
        return self.__class__.__name__ + " ({0}): ".format(hex(id(self))) + pformat(self.__dict__, width=160)

    def list_str (self, items):
        """Convert a list to a string. One item per line."""
        output = ""
        for entry in items:
            output += str(entry) + "\n"
        return output

    def filedump (self, filename, append = False):
        """Dump object __str__ representation to file, with optional append."""
        if append is False:
            mode = 'w'
        elif append is True:
            mode = 'a'
        else:
            print("debug filedump append flag must be True/False, not {0}".format(append))
            exit(1)
        with open(filename, mode) as f:
            print(self, end="", file=f)

