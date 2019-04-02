#! /usr/bin/python3

from sys    import exit
from Debug  import Debug

class Commands (Debug):
    """Parses the assembly language commands and calls functions to create intermediate structures for later dependency resolutions."""

    def __init__ (self, data, code):
        Debug.__init__(self)
        self.data = data
        self.code = code

    def search_command(self, command):
        """Look for the command in the built-ins, and previously-defined opcodes and branch conditions."""
        assembler   = getattr(self, command, None) is not None
        opcode      = command in self.code.opcodes.defined_opcodes
        condition   = command in [condition.label for condition in self.code.conditions] 
        return (assembler, opcode, condition)

    def find_command (self, command):
        """Does the command exist in any category?"""
        found_flags = self.search_command(command)
        return True in found_flags

    def execute_command (self, command, arguments):
        """Either execute a built-in assembler command, or take action when we encounter a previously defined opcode or branch condition."""
        assembler, opcode, condition = self.search_command(command)
        if assembler is True:
            assembler_command = getattr(self, command, None)
            assembler_command(arguments)
            return
        if opcode is True:
            self.code.allocate_instruction(command, arguments)
            return
        if condition is True:
            self.code.allocate_branch(command, arguments)
            return

    def parse_command (self, command, arguments):
        label           = None
        command_exists  = self.find_command(command)
        # Expecting: command arguments...
        # If the first word on the line is not a recognized command, it's a label.
        # The next word is then the command, and the rest its arguments: label command arguments...
        if command_exists is False:
            label       = command
            command     = arguments[0]
            arguments   = arguments[1:]
        # label is None if first word was a command (no label given).
        arguments.insert(0, label)
        # Then try again...
        command_exists = self.find_command(command)
        if command_exists is False:
            print("Unknown command: {0}".format(command))
            self.ask_for_debugger()
        self.execute_command(command, arguments)

# These are the assembler commands.

    def opcode (self, arguments):
        """Define an instruction opcode. Called as command later to create an instruction."""
        self.code.allocate_opcode(arguments)

    def preload (self, arguments):
        """Preload one or more opcode definitions into the Opcode Decoder."""
        label   = arguments[0]
        opcodes = arguments[1:]
        if label is not None:
            print("No label ({0}) allowed for opcode preload.".format(label))
            self.ask_for_debugger()
        if len(opcodes) == 0:
            print("No opcode(s) given to preload command.")
            self.ask_for_debugger()
        self.code.preload_opcode(opcodes)

    def load (self, arguments):
        opcode_labels = arguments[1:]
        if len(opcode_labels) < 1:
            print("No opcode to load given.")
            self.ask_for_debugger()
        if len(opcode_labels) > 2:
            print("Too many opcodes given to load: {0}.".format(opcode_labels))
            self.ask_for_debugger()
        self.code.load_opcode(*arguments)

    def condition (self, arguments):
        """Define a branch condition. Called as command later at the point a branch is taken."""
        self.code.allocate_condition(*arguments)

    def private (self, arguments):
        """Declare a private variable. One or more space-delimited integers as arguments. Must be named (have a label)."""
        label   = arguments[0]
        values  = arguments[1:]
        if label is None:
            print("No label found. Private variables MUST be named. Variable value(s) in declaration: {0}".format(values))
            self.ask_for_debugger()
        self.data.allocate_private(label, values)

    def shared (self, arguments):
        """Declare a shared variable. One or more space-delimited integers as arguments. May or may not have a name (label)."""
        label   = arguments[0]
        values  = arguments[1:]
        self.data.allocate_shared(label, values)

    def pointer (self, arguments):
        """Declare a pointer. Must be named."""
        label   = arguments[0]
        values  = arguments[1:]
        if label is None:
            print("No label found. Pointer variables MUST be named. Variable value(s) in declaration: {0}".format(values))
            self.ask_for_debugger()
        self.data.allocate_pointer(label, *values)

    def port (self, arguments):
        """Declare an I/O port. Must be named."""
        label   = arguments[0]
        values  = arguments[1:]
        if label is None:
            print("No label found. Port variables MUST be named. Variable value(s) in declaration: {0}".format(values))
            self.ask_for_debugger()
        self.data.allocate_port(*arguments)

    def threads (self, arguments):
        """Space-delimited list of the thread numbers which will use the code defined afterwards. Cannot be named."""
        label       = arguments[0]
        thread_list = arguments[1:]
        if label is not None:
            print("No label ({0}) allowed for command threads".format(label))
            self.ask_for_debugger()
        self.data.set_current_threads(thread_list)

    def init (self, arguments):
        """Declare a placeholder for the initialization code of a branch or a pointer. Filled-in later."""
        self.code.allocate_init_load(*arguments)

    def program_counter (self, arguments):
        """Set the initial value of each thread program counter. Cannot be named. Must be given code labels."""
        label       = arguments[0]
        pc_list     = arguments[1:]
        if label is not None:
            print("No label ({0}) allowed for command program_counter".format(label))
            self.ask_for_debugger()
        self.code.set_pc(label, pc_list)

