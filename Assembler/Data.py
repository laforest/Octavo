#! /usr/bin/python3

from sys        import exit
from Utility    import Utility
from Debug      import Debug

class Variable (Debug, Utility):
    """Base class to describe a variable and what we know about it so far.
       Has no value. Have the derived class create the kind of value it should hold."""

    def parse_value (self, label, initial_values):
        """Deal with ints, lists, and strings. Convert to int where possible."""
        if type(initial_values) == list:
            if len(initial_values) == 0:
                print("Empty list of values passed to variable {0}.".format(label))
                exit(1)
            if len(initial_values) > 1:
                initial_values = [self.try_int(entry) for entry in initial_values]
            else:
                initial_values = self.try_int(initial_values[0])
        elif type(initial_values) == str:
            initial_values = self.try_int(initial_values)
        elif type(initial_values) == int:
            pass
        elif type(initial_values) == type(None):
            pass
        else:
            print("Unusable initial value {0} for variable {1}".format(label, initial_values))
            exit(1)
        return initial_values

    def __init__ (self, label = None, address = None, memory = None):
        Debug.__init__(self)
        self.label   = label
        self.address = address
        self.memory  = memory

class Shared_Variable (Variable):
    """Shared variables exist as a unique value identically addressed by all threads."""

    def __init__ (self, label = None, address = None, memory = None, value = None):
        Variable.__init__(self, label = label, address = address, memory = memory)
        self.value = self.parse_value(self.label, value)

class Private_Variable (Variable):
    """Private variables can have multiple values, one per thread. The CPU adds a per-thread
       offset to the common address so as to access the per-thread value."""

    def __init__ (self, label = None, address = None, memory = None, value = None, threads = None):
        Variable.__init__(self, label = label, address = address, memory = memory)
        self.value = {} # {thread:value}
        value = self.parse_value(value)
        # If created in multiple threads at a time
        for thread in threads:
            self.value[thread] = value

    def add_value (self, value, threads):
        """Add a new per-thread value. Disallow changing initial values once not None. Disallow duplicate threads.
           New value must be of same length as all previous values to keep this and other private variable instances
           at the same address across all threads."""
        # Check existing value length consistency and get length if consistent
        value_lengths = [len(entry) for entry in self.value.values()]
        value_lengths = set(value_lengths)
        if len(value_lengths) > 1:
            print("There are values of different lengths in private variable {0}: {1}. All values must be of same length.".format(self.label, self.value))
            exit(1)
        value = self.parse_value(value)
        if len(value) != value_lengths[0]:
            print("Private variable {0}: added value {1} for thread(s) {2} not of same length as existing values {3}.".format(self.label, value, threads, self.values))
            exit(1)
        for thread in threads:
            old_value = self.value.get(thread)
            if old_value is not None:
                print("Thread {0} already has a value {1} in private variable {2}. Tried to assign {3}.".format(thread, self.value[thread], self.label, value))
                exit(1)
            self.value[thread] = value

    def threads (self):
        """Don't expose the value implementation outside this class. Return the thread number associated with each value."""
        return self.value.keys()

class Pointer_Variable (Variable):
    """Describes pointer initialization data, which indirect memory slot it refers to, and in which threads is it used. Has no value."""

    def __init__ (self, label = None, address = None, memory = None, read_base = None, read_incr = None, write_base = None, write_incr = None, slot = None, threads = None):
        Variable.__init__(self, label = label, address = address, memory = memory)
        self.read_base  = read_base
        self.read_incr  = read_incr
        self.write_base = write_base
        self.write_incr = write_incr
        # The slot indexes into the access address list and the configuration address list
        self.slot       = slot
        # Set at Resolution, as the code and data haven't been generated yet!
        self.init_load  = None
        self.threads    = threads

    def add_threads (self, threads):
        """Add new threads in which this pointer is used. Disallow duplicate thread addition."""
        for thread in threads:
            if thread in self.threads:
                print("Pointer was already declared in thread {0}. Threads: {1}".format(thread, self.threads))
                exit(1)
            self.threads.extend(thread)
        self.threads.sort()

class Port_Variable (Variable):
    """Describes an I/O port. Derive address from port number. Has no value. Identical in all threads."""

    def __init__ (self, label = None, address = None, memory = None, number = None):
        Variable.__init__(self, label = label, address = address, memory = memory)
        self.number = number

class Data (Utility, Debug):
    """Contains descriptions of data and resolves locations, etc... before passing to back-end for memory image generation"""

    def __init__ (self, configuration):
        Utility.__init__(self)
        Debug.__init__(self)
        # Used for private and pointer variables
        self.current_threads = []
        # Variable type lists
        self.shared     = []
        self.private    = []
        self.pointers   = []
        self.ports      = []
        self.variables  = [self.shared, self.private, self.pointers, self.ports]
        self.configuration = configuration
        # Location Zero is a special case always equal to zero.
        # It must exist before any other shared variable.
        self.shared.append(Shared_Variable(label = None, address = 0, value = 0, memory = "A"))
        self.shared.append(Shared_Variable(label = None, address = 0, value = 0, memory = "B"))

    def __str__ (self):
        output = "\nData:\n"
        output += "\nCurrent Threads: " + str(self.current_threads) + "\n"  
        output += "\nPrivate Variables:\n"
        output += self.list_str(self.private)
        output += "\nShared Variables:\n"
        output += self.list_str(self.shared) + "\n"
        output += self.list_str(self.pointers) + "\n"
        output += self.list_str(self.ports) + "\n"
        return output

    def set_current_threads (self, thread_list):
        self.current_threads = [self.try_int(thread) for thread in thread_list]
        # Type check
        for thread in self.current_threads:
            if type(thread) is not int:
                print("Thread values must be literal integers: {0}".format(self.current_threads))
                exit(1)
        # Range check
        min_thread = 0
        max_thread = self.configuration.thread_count - 1
        for thread in self.current_threads:
            if thread < min_thread or thread > max_thread:
                print("Out of range thread: {0}. Min: {1}, Max: {2}".format(self.thread, min_thread, max_thread))
                exit(1)
        # Duplication test
        if len(self.current_threads) > len(set(self.current_threads)):
            print("Duplicate thread numbers not allowed: {0}".format(current_threads))
            exit(1)

    def lookup_variable_name (self, name):
        """Locate variable by name if it exists. Checks for duplicate entries."""
        if name is None:
            print("Variable name lookup cannot have a None name!")
            exit(1)
        variables = []
        for variable_type_list in self.variables:
            for variable in variable_type_list:
                if variable.label == name:
                    variables.append(variable)
        if len(variables) == 0:
            return None
        if len(variables) > 1:
            print("Duplicate variable names found: {0}".format(variables))
            exit(1)
        return variables[0]

    def lookup_shared_variable_value (self, value, memory):
        """Locate unnamed shared variable by value if it exists in the given memory.
           Search exhaustively for duplicates, which should not exist within a memory.
           (Value duplicates across memories are OK.)"""
        variables = []
        for variable in self.shared:
            if variable.label == None and variable.value == value and variable.memory == memory:
                variables.append(variable)
        if len(variables) == 0:
            return None
        if len(variables) > 1:
            print("Unnamed shared variable of value {0} found more than once in memory {1}.".format(value, memory))
            exit(1)
        return variables[0]

    def allocate_private (self, label, value = None):
        """Allocate a private variable. Must be named (label not None).
           If the variable already exists, check the type, and add the values and threads."""
        if label is None:
            print("Private variable label/name cannot be None! Initial value: {0}".format(value))
            exit(1)
        variable = self.lookup_variable_name(label)
        if variable is not None and type(variable) is not Private_Variable:
            print("A non-private variable named {0} of type {1} already exists!".format(label, type(variable)))
            exit(1)
        if variable is None:
            variable = Private_Variable(label = label, value = value, threads = self.current_threads)
            self.private.append(variable)
        else:
            variable.add_value(value, self.current_threads)
        return variable

    def allocate_shared (self, label, value = None):
        """Allocate a shared variable. Disallow redefinition or duplicate names. None name is allowed (literal constant)."""
        variable = self.lookup_variable_name(label)
        if variable is not None:
            print("Variable {0} of type {1} already exists.".format(label, type(variable)))
            exit(1)
        variable = Shared_Variable(label = label, value = value)
        self.shared.append(variable)
        return variable

    def next_pointer_slot (self, set_pointer):
        """Find the highest used slot in all pointers in the same memory, and return the next one."""
        max_slot = -1
        for pointer in self.pointers:
            if pointer.memory != set_pointer.memory:
                continue
            slot     = pointer.slot
            if slot is None:
                slot = -1
            max_slot = max(slot, max_slot)
        return max_slot + 1

    def allocate_pointer (self, label, read_base = None, read_incr = None, write_base = None, write_incr = None):
        """Allocate a pointer. If it already exists, and the type and initial parameters matches, only add the threads."""
        # We can't determine the init data value until we know which Data Memory it's read from.
        # This also affects the placement of the referred-to pointer/array.
        # The bases are labels until resolved to addresses
        if label is None:
            print("Pointer cannot have a None name! Read/Write bases: {0}, {1}".format(read_base, write_base))
            exit(1)
        read_incr   = self.try_int(read_incr)
        write_incr  = self.try_int(write_incr)
        pointer = self.lookup_variable_name(label)
        if pointer is not None:
            if type(pointer) is not Pointer_Variable:
                print("A non-pointer variable named {0} of type {1} already exists!".format(label, type(pointer))
                exit(1)
            if pointer.read_incr != read_incr or pointer.write_incr != write_incr or pointer.read_base != read base or pointer.write_base != write_base:
                print("A pointer named {0} already exists, but with a different configuration. This is not allowed.".format(label))
                exit(1)
            pointer.add_threads(self.current_threads)
        else:
            # Can't set slot here, as we don't know which Data Memory we will end up in. This is done at Resolution.
            pointer = Pointer_Variable(label = label, read_base = read_base, read_incr = read_incr, write_base = write_base, write_incr = write_incr, threads = self.current_threads)
            self.pointers.append(pointer)
        return pointer

    def allocate_port (self, label, memory, number):
        """Allocate a port, giving it a name and number. Disallow duplicate definition or redefinition."""
        if label is None:
            print("Port cannot have a None name! Memory: {0}, Number: {1}".format(memory, number))
            exit(1)
        port = self.lookup_variable_name(label)
        if port is not None:
            print("A variable named {0} of type {1} already exists when trying to allocate a port.".format(label, type(port)))
            exit(1)
        number      = int(number, 0)
        new_port    = Port_Variable(label = label, memory = memory, number = number)
        self.ports.append(new_port)
        return new_port

    def get_variable_type_list (self, variable):
        """Returns the list of all variables of the same type as the given variable."""
        if type(variable) is Variable:
            print("Found variable {0} of base type Variable. This should never happen.".format(variable.label))
            exit(1)
        if type(variable) is Shared_Variable:
            return self.shared
        if type(variable) is Private_Variable:
            return self.private
        if type(variable) is Pointer_Variable:
            return self.pointers
        if type(variable) is Port_Variable:
            return self.ports
        # A variable not in a type list, or a non-existent variable, should never happen.
        print("Variable {0} does not belong to any type! This is impossible.".format(variable.label))
        exit(1)

    def next_variable_address (self, new_variable, memory):
        """Given a variable, return the next unallocated memory address for that type of variable for the given memory."""
        # No variable created at address zero. (Zero Register)
        # Add the length of the data of the max-addressed variable
        # so we return the next address just past its value(s)
        # Find in the same memory only, of course
        max_address     = 0
        max_data_length = 1
        # Find the higest set address amongst all variables of the given variable type in the given memory
        variables = self.get_variable_type_list(new_variable)
        for variable in variables:
            address = variable.address
            if address is not None and variable.memory == memory:
                if address > max_address:
                    max_address = address
                    # All private variable values are of same length, so just use the first one
                    if   type(variable) is Private_Variable:
                        value = variable.value.values()[0]
                    elif type(variable) is Shared_Variable:
                        value = variable.value
                    else:
                        print("Non-private or non-shared variable cannot be allocated an address. Variable: {0}".format(new_variable))
                        exit(1)
                    if type(value) == list:
                        max_data_length = len(value)
                    else:
                        max_data_length = 1
        next_address =  max_address + max_data_length
        # Limit the address to the given range of the variables (shared, private, etc...)
        # We assume shared starts at zero
        if type(new_variable) is Shared_Variable and next_address not in self.configuration.memory_map.shared:
            print("Out of bounds address {0} for shared variable {1}. Limit is {2}.".format(next_address, new_variable.label, self.configuration.memory_map.shared[-1]))
            exit(1)
        if type(new_variable) is Private_Variable and next_address not in self.configuration.memory_map.private:
            # Catch the first private variable given an address and put it at the start of the private area, the rest will follow.
            if next_address < self.configuration.memory_map.private[0]:
                next_address = self.configuration.memory_map.private[0]
            # Have we run out of room? 
            if next_address > self.configuration.memory_map.private[-1]:
                print("Out of bounds address {0} for private variable {1}. Limit is {2}".format(next_address, new_variable.label, self.configuration.memory_map.private[-1]))
                exit(1)
        return next_address

    def resolve_shared_value (self, value, memory):
        """Resolve a literal value to a shared variable in the same memory, assigning it a memory and address, creating the shared variable if necessary."""
        variable = self.lookup_shared_variable_value(value, memory)
        if variable is None:
            variable = self.allocate_shared(None, value = value)
            variable.memory = memory
        if variable.address is None:
            variable.address = self.next_variable_address(variable, memory)
        return variable

    def resolve_named (self, name, memory):
        """Lookup a variable by name and allocate it an address and a memory if not already set.
           The variable must be pre-existing."""

        variable = self.lookup_variable_name(name)

        if variable is None:
            print("No variable by name {0}.".format(name))
            exit(1)

        if type(variable) is Shared_Variable or type(variable) is Private_Variable:
            if variable.address is None:
                variable.address = self.next_variable_address(variable, memory)
            if variable.memory is not None and variable.memory != memory:
                print("Conflicting memory allocation for {0} variable {1}. Was {2}, now {3}".format(variable, name, variable.memory, memory))
                exit(1)
            variable.memory = memory 
            return variable

        # Ports are located in the shared address space, and have an address set by the port number in the source code.
        # There is no allocation of addresses for ports.
        if type(variable) is Port_Variable:
            if variable.address is None:
                variable.address = self.configuration.memory_map.io[variable.number]
            # Memory always set at port definition, so never None
            if variable.memory != memory:
                print("Conflicting memory allocation for I/O port {0}. Was {1}, now {2}".format(name, variable.memory, memory))
                exit(1)
            return variable

        # Pointers are located in the shared address space, but are initialized per-thread.
        if type(variable) is Pointer_Variable:
            if variable.memory is not None and variable.memory != memory:
                print("Conflicting memory allocation for pointer {0}. Was {1}, now {2}".format(name, variable.memory, memory))
                exit(1)
            variable.memory = memory 
            if variable.slot is None:
                variable.slot = self.next_pointer_slot(variable)
            if variable.address is None:
                variable.address = self.configuration.memory_map.indirect[variable.slot]
            return variable


