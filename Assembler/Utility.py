#! /usr/bin/python3

class Utility:
    """Common utility functions for all other classes."""

    def __init__ (self):
        pass

    def try_int (self, value):
        """Wrapper around int() to deal with non-numeric strings and provide debug info."""
        if value is None:
            return None
        if type(value) == int:
            return value
        try:
            value = int(value, 0)
        except ValueError:
            # Assume it's a string. Leave it alone until resolution.
            pass
        except TypeError:
            print("\nInvalid type for int() conversion. Input {0} of type {1}.\n".format(value, type(value)))
            raise TypeError
        return value

