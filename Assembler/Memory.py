#! /usr/bin/python

class Memory:
    """A basic Memory capable of assembling literals, naming locations, and dumping its contents into a format Verilog $readmemh can use."""

    def width_mask(self, width):
        return (1 << width) - 1

    def __init__(self, file_name, depth = 0, width = 0, write_offset = 0):
        self.file_name    = file_name
        self.depth        = depth
        self.width        = width
        self.write_offset = write_offset
        self.mask         = self.width_mask(self.width)
        self.data         = [(0 & self.mask)] * self.depth
        self.read_names   = {}
        # Write names must be globaly unique, across all memories. Check in higher level class.
        self.write_names  = {}
        # Pre-increment before storing at 'here'.
        self.here         = -1
        # Lifted from Modelsim's output of $writememh
        self.file_header  = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""

    def dump_format(self):
        """Numbers must be represented as zero-padded whole hex numbers"""
        characters = self.width // 4
        remainder = self.width % 4
        characters += min(1, remainder)
        format_string = "{:0" + str(characters) + "x}"
        return format_string

    def file_dump(self, begin = 0, end = 0, file_name = ""):
        """Dump to Verilog loadable format. Allows dumping a slice of memory."""
        if end == 0:
            end = self.depth
        if file_name == "":
            file_name = self.file_name
        with open(file_name, 'w') as f:
            f.write(self.file_header + "\n")
            format_string = self.dump_format()
            for entry in self.data[begin:end]:
                output = format_string.format(entry)
                f.write(output + "\n")

    def align(self, addr):
        """Continue assembling at new address. Assumes pre-incrementing 'here'"""
        self.here = addr - 1
        assert self.here >= (0-1) and self.here <= (self.depth-1-1), "ERROR: Out of bounds align in {0}".format(self.__class__.__name__)

    def lit(self, number):
        """Place a literal number 'here'"""
        self.here += 1
        assert self.here >= 0 and self.here <= self.depth-1, "ERROR: Out of bounds lit in {0}".format(self.__class__.__name__)
        self.data[self.here] = number & self.mask

    def loc(self, name, read_addr = None, write_addr = None):
        """Name a given location. May have only a read or write address, or both.
           If neither addresses are given, then name the current location, 
           after 'here' was incremented by another operation."""
        if read_addr is not None:
            assert read_addr >= 0 and read_addr <= self.depth-1, "ERROR: Out of bounds loc read address assignment in {0}".format(self.__class__.__name__)
            self.read_names.update({name:read_addr})
        if write_addr is None and read_addr is not None:
            # No assert here as write address can be over a different range, depending on where Memory is mapped.
            write_addr = read_addr + self.write_offset
        if write_addr is not None:
            self.write_names.update({name:write_addr})
        if write_addr is None and read_addr is None:
            assert self.here >= 0 and self.here <= self.depth-1, "ERROR: Out of bounds loc in {0}".format(self.__class__.__name__)
            self.loc(name, self.here, write_addr)

    def data(self, entries, name = None):
        """Place a list of numbers into consecutive locations.
           Optionally name the head of the list."""
        assert len(entries) > 0, "ERROR: Empty data list in {0}".format(self.__class__.__name__)   
        if name is not None:
            head = entries.pop(0)
            self.lit(head)
            self.loc(name)
        for entry in entries:
            self.lit(entry)

    def read_addr(self, name):
        """Lookup name into its READ address."""
        return self.read_names.get(name, None)

    def write_addr(self, name):
        """Lookup local names into its WRITE address."""
        return self.write_names.get(name, None)

    def forget(self, name):
        """Remove a name associated with read and/or write addresses."""
        self.read_names.pop(name, None)
        self.write_names.pop(name, None)
