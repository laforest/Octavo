#! /usr/bin/python3

from Parser         import Parser
from Commands       import Commands
from Data           import Data
from Code           import Code
from Resolver       import Resolver
from Configuration  import Configuration
from Generator      import Generator

from sys import argv

if __name__ == "__main__":
    configuration   = Configuration()
    data            = Data(configuration)
    code            = Code(data, configuration)
    commands        = Commands(data, code)
    parser          = Parser(commands)
    parser.parse_file(argv[1])
    # Won't need these after Parsing and Allocation.
    # So let's enforce that for our own discipline.
    # State is carried in Code and Data.
    del parser
    del commands
    print("Parsing and Allocation Done")

    # Dump initial state of code and data
    # immediately after Allocation
    configuration.filedump("LOG.allocate")
    data.filedump("LOG.allocate", append = True)
    code.filedump("LOG.allocate", append = True)

    resolver        = Resolver(data, code, configuration)
    resolver.resolve()
    print("Resolution Done")

    # Dump state of code and data after Resolution
    # use gvimdiff (or your tool of choice) to see the differences
    # There should be no remaining strings and unset variables
    # or instruction operands at this point.
    configuration.filedump("LOG.resolve")
    data.filedump("LOG.resolve", append = True)
    code.filedump("LOG.resolve", append = True)

    generator = Generator(data, code, configuration)
    generator.generate()
    print("Generation done")

    configuration.filedump("LOG.generate")
    data.filedump("LOG.generate", append = True)
    code.filedump("LOG.generate", append = True)

    print("OK")

