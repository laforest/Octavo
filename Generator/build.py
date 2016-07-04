#! /usr/bin/python

import sys

from Scalar import Scalar

module = sys.argv[1]
# Eat the argument, as later code assumes they start at argv[1]
del sys.argv[1]
eval(module + ".build()")

