#! /usr/bin/python3

from bitstring import BitArray

class Memory:
    """A basic Memory capable of assembling literals, naming locations, and dumping its contents into a format Verilog $readmemh can use."""

    def __init__(self, file_name, depth = 0, width = 0, write_offset = 0):
        self.file_name    = file_name
        self.depth        = depth
        self.width        = width
        self.write_offset = write_offset
        self.mem          = BitArray(self.width * self.depth)
        self.read_names   = {}
        # Write names must be globaly unique, across all memories. Check in higher level class.
        self.write_names  = {}
        # Pre-increment before storing numbers at 'here'.
        self.here         = -1
        # Keep track of first free sequential location
        self.last         = self.here + 1
        # Lifted from Modelsim's output of $writememh
        self.file_header  = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""

# ---------------------------------------------------------------------
# File dump format

    def dump_format(self):
        """Numbers must be represented as zero-padded whole hex numbers"""
        characters = self.width // 4
        remainder = self.width % 4
        characters += min(1, remainder)
        format_string = "{:0" + str(characters) + "x}"
        return format_string

    def file_dump(self, begin = 0, end = 0, file_name = ""):
        """Dump to Verilog loadable format. Allows dumping a width-slice of memory."""
        assert begin >= 0, "ERROR: Out of bounds range begin {0} in {1}".format(begin, self.__class__.__name__)
        assert end <= self.depth, "ERROR: Out of bounds range end {0} in {1}".format(end, self.__class__.__name__)
        if end == 0:
            end = self.depth - 1
        if file_name == "":
            file_name = self.file_name
        # Convert from word index to bit index
        begin = self.width * begin
        end   = (self.width * end) + self.width
        with open(file_name, 'w') as f:
            f.write(self.file_header + "\n")
            format_string = self.dump_format()
            for entry in self.mem.cut(self.width, begin, end):
                output = format_string.format(entry.uint)
                f.write(output + "\n")

# ---------------------------------------------------------------------
# Location naming and lookup

    def loc(self, name, read_addr = None, write_addr = None):
        """Name a given location. May have only a read or write address, or both.
           If neither addresses are given, then name the current location, 
           after 'here' was incremented by another operation."""
        if read_addr is not None:
            assert read_addr >= 0 and read_addr <= self.depth-1, "ERROR: Out of bounds loc read address ({0}) assignment in {1}".format(read_addr, self.__class__.__name__)
            self.read_names.update({name:read_addr})
        if write_addr is None and read_addr is not None:
            # No assert here as write address can be over a different range, depending on where Memory is mapped.
            write_addr = read_addr + self.write_offset
        if write_addr is not None:
            self.write_names.update({name:write_addr})
        if write_addr is None and read_addr is None:
            assert self.here >= 0 and self.here <= self.depth-1, "ERROR: Out of bounds loc ({0}) in {1}".format(self.here, self.__class__.__name__)
            self.loc(name, self.here)

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

    def lookup(self, name, offset = 0):
        """Get the binary word refered by a read address, assumed to have been 'here'."""
        if type(name) == str:
            addr = self.read_addr(name)
        else:
            addr = name
        addr  += offset
        start = addr * self.width
        end   = start + self.width
        val   = self.mem[start:end]
        return val

# ---------------------------------------------------------------------
# Compile literals at locations (basic assembler mechanism and state)

    def align(self, addr):
        """Continue assembling at new address. Assumes pre-incrementing 'here'"""
        if type(addr) == str:
            addr = self.read_addr(addr)
        assert addr >= 0 and addr <= (self.depth-1), "ERROR: Out of bounds align ({0}) in {1}".format(self.here, self.__class__.__name__)
        if addr > self.last:
            self.last = addr
        self.here = addr - 1

    def resume(self):
        """Resume assembling at first free sequential location after an align()."""
        self.here = self.last - 1

    def lit(self, number):
        """Place a literal number 'here'"""
        self.here += 1
        assert self.here >= 0 and self.here <= self.depth-1, "ERROR: Out of bounds lit ({0}) in {1}".format(self.here, self.__class__.__name__)
        if self.here >= self.last:
            self.last = self.here + 1
        number = BitArray(uint=number, length=self.width)
        pos = self.here * self.width
        self.mem.overwrite(number, pos)

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


if __name__ == "__main__":
    test = Memory("foobar.mem", depth = 1024, width = 36, write_offset = 512)
    test.align(321)
    numbers = [1,2,3,5,8,13,21]
    test.data(numbers,"fib")
    read_addr = test.read_addr("fib")
    print("read addr: {0}".format(read_addr));
    write_addr = test.write_addr("fib")
    print("write addr: {0}".format(write_addr));
    for offset in range(0,len(numbers)+1):
        print(test.lookup("fib", offset).uint)
    # Check the line numbers: 321 to 327, account for header
    # cat foobar.mem | nl -v -1 | less
    test.file_dump() 

    

