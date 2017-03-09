#! /usr/bin/python

# Generate an "empty" memory init file, suitable for $readmemh()
# Default fill pattern is zero, but can be specified

from sys import argv

# Lifted from Modelsim's output of $writememh
file_header = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""

def dump_format(width):
    """Numbers must be represented as zero-padded whole hex numbers"""
    characters = width // 4
    remainder  = width % 4
    characters += min(1, remainder)
    format_string = "{:0" + str(characters) + "x}"
    return format_string

def file_dump(width, depth, file_name, fill=0):
    """Allows dumping a slice of memory."""
    with open(file_name, 'w') as f:
        f.write(file_header + "\n")
        format_string = dump_format(width)
        for i in xrange(depth):
            output = format_string.format(fill)
            f.write(output + "\n")

if __name__ == "__main__":
    if len(argv) != 4:
        print("3 arguments: width, depth, filename\n")
        exit
    width       = int(argv[1])
    depth       = int(argv[2])
    file_name   = argv[3]
    file_dump(width, depth, file_name)

