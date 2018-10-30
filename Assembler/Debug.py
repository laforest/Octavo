#! /usr/bin/python3

from pprint import pformat

class Debug:
    """Common debug code."""

    def __init__ (self):
        pass

    def __str__ (self):
        """Debug information formatter."""
        return self.__class__.__name__ + ": " + pformat(self.__dict__, width=160)

