#! /usr/bin/python3

from sys        import exit
from Debug      import Debug
from bitstring  import BitArray

class Opcode (Debug):
    """Contains symbolic information to assemble the bit representation of an opcode""" 

    def __init__ (self, label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select, operators):
        Debug.__init__(self)
        self.label      = label
        self.split      = split
        self.shift      = shift
        self.dyadic3    = dyadic3
        self.addsub     = addsub
        self.dual       = dual
        self.dyadic2    = dyadic2
        self.dyadic1    = dyadic1
        self.select     = select
        self.binary     = self.to_binary(operators)

    def is_dual (self):
        """Does an opcode use the dual addressing mode (DA/DB instead of D)?"""
        if self.dual == "dual":
            return True
        elif self.dual == "simple":
            return False
        else:
            print("Invalid simple/dual opcode specifier {0} for opcode {1}".format(self.dual, self.label))
            self.ask_for_debugger()

    def is_same_as (self, opcode):
        """Check if the given opcode object encodes the same operation as this opcode, regardless of label or address."""
        for entry in ["split", "shift", "dyadic3", "addsub", "dual", "dyadic2", "dyadic1", "select"]:
            if getattr(self, entry) != getattr(opcode, entry):
                return False
        return True

    def to_binary (self, operators):
        """Converts the fields of the control bits of an instruction opcode, 
           looked-up from symbolic names, to binary encoding. 
           Field values are strings naming the same field in the dyadic/triadic
           operations objects."""
        control_bits = BitArray()
        for entry in [self.split, self.shift, self.dyadic3, self.addsub, self.dual, self.dyadic2, self.dyadic1, self.select]:
            field_bits = getattr(operators.dyadic, entry, None)
            field_bits = getattr(operators.triadic, entry, field_bits)
            if field_bits is None:
                print("Unknown opcode field value: {0}".format(entry))
                self.ask_for_debugger()
            control_bits.append(field_bits)
        return control_bits


class Opcode_Manager (Debug):
    """Holds and processes two lists of opcodes, per thread:
       the initial list programmed into the Opcode Decoder memory initially,
       and the current list which updates the Opcode Decoder memory by loads in the source.
       Both lists are drawn from a larger list of defined opcodes for all threads.
       The instruction opcodes must be resolved immediately."""

    def __init__ (self, code, data, configuration, operators):
        Debug.__init__(self)
        self.operators          = operators
        self.code               = code
        self.data               = data
        self.configuration      = configuration
        self.defined_opcodes    = {} # {label:opcode_obj}
        # One set of initial/current opcodes per thread
        self.initial_opcodes    = [[None for entry in range(self.configuration.opcode_count)] for thread in range(self.configuration.thread_count)]
        self.current_opcodes    = [[None for entry in range(self.configuration.opcode_count)] for thread in range(self.configuration.thread_count)]

    def define_opcode (self, label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        """Add an opcode to the pool of defined opcodes we can draw from.
           Each opcode must have a unique name and operation across all threads."""
        if label in self.defined_opcodes:
            print("Opcode {0} already defined. Redefinitions not allowed.".format(label))
            self.ask_for_debugger()
        new_opcode = Opcode(label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select, self.operators)
        for previous_opcode in self.defined_opcodes.values():
            if new_opcode.is_same_as(previous_opcode):
                print("Opcode {0} performs the same operations as previously defined opcode {1}. Redefinitions not allowed.".format(new_opcode.label, previous_opcode.label))
                self.ask_for_debugger()
        self.defined_opcodes.update({label:new_opcode})

    def preload_thread_opcode (self, opcode_label, thread):
        """Preload an opcode into a threads' Opcode Decoder memory, 
           update the threads' current opcode list, and check consistency.
           All preloads must precede any opcode load, else opcode numbers will be inconsistent."""
        try:
            initial_index = self.initial_opcodes[thread].index(None)
        except ValueError:
            print("Opcode {0} cannot be pre-loaded. No more free slots in Opcode Decoder memory for thread {1}.".format(opcode_label, thread))
            self.ask_for_debugger()
        try:
            current_index = self.current_opcodes[thread].index(None)
        except ValueError:
            print("Opcode {0} cannot be pre-loaded. No more free slots in current opcode list for thread {1}.".format(opcode_label, thread))
            self.ask_for_debugger()
        # This happens if loads and preloads are interleaved, and thus initial and
        # current opcodes end up with different opcode numbers. Don't do that. :)
        if initial_index != current_index:
            print("Mismatched initial ({0}) and current ({1}) opcode numbers for opcode {2} in thread {3} because an opcode load precedes an opcode preload. Please fix that.".format(initial_index, current_index, opcode_label, thread))
            self.ask_for_debugger()
        self.initial_opcodes[thread][initial_index] = opcode_label
        self.current_opcodes[thread][current_index] = opcode_label

    def preload_opcode (self, opcode_label):
        if opcode_label not in self.defined_opcodes:
            print("Unknown opcode {0} for pre-loading.".format(opcode_label))
            self.ask_for_debugger()
        for thread in self.data.current_threads:
            self.preload_thread_opcode(opcode_label, thread)

    def preload_opcodes (self, opcode_label_list):
        for opcode_label in opcode_label_list:
            self.preload_opcode(opcode_label)

    def load_thread_opcode (self, new_label, old_label, thread):
        """Load a new opcode, at runtime, either in an empty Opcode Decoder memory entry, or replacing another opcode if given."""
        if old_label is not None:
            index = self.current_opcodes[thread].index(old_label)
        else:
            try:
                index = self.current_opcodes[thread].index(None)
            except ValueError:
                print("Opcode {0} cannot be loaded. No more free slots in current opcode list for thread {1}. Maybe load over an unused older opcode?".format(new_label, thread))
                self.ask_for_debugger()
        self.current_opcodes[thread][index] = new_label
        return index

    def load_opcode (self, label, new_opcode_label, old_opcode_label = None):
        """
        Load a new opcode at runtime, either replacing an old one (taking its number) or using up a new number.
        The new opcode number must always be the same, so future instructions don't incorrectly execute another opcode.
        Thus, the execution of opcode loads cannot diverge: all possible paths through the program must result in the
        same sequence of opcode loads. This consistency is checked in all threads the code is expected to execute
        since each thread has its own Opcode Decoder memory, which must all be consistent with eachother else it's
        no longer the same code running in all the current threads.
        In data-flow graph analysis parlance: an opcode init load must dominate all later uses of that opcode,
        and must happen in the same order relative to the other init loads.

        """
        if old_opcode_label is not None and old_opcode_label not in self.defined_opcodes:
            print("Unknown previous opcode {0} when loading new opcode {1}.".format(old_opcode_label, new_opcode_label))
            self.ask_for_debugger()
        if new_opcode_label not in self.defined_opcodes:
            print("Unknown new opcode {0} when loading over previous opcode {1}.".format(new_opcode_label, old_opcode_label))
            self.ask_for_debugger()
        # Load and check for consistency in opcode indices across current threads
        # Not sure if this is necessary or correct, but if wrong, it'll fail here instead of at runtime.
        indices = []
        for thread in self.data.current_threads:
            index = self.load_thread_opcode(new_opcode_label, old_opcode_label, thread)
            indices.append(index)
        if len(set(indices)) > 1:
            print("Opcode numbers {0} for new opcode {1} (old opcode {2}) have diverged over threads {3}.".format(indices, new_opcode_label, old_opcode_label, self.data.current_threads))
            self.ask_for_debugger()
        # Now allocate and resolve the init load for that opcode
        load_address = self.configuration.memory_map.od[index]
        init_load    = self.code.allocate_init_load(label, load_address)
        # Let's use shared data as opcodes are common to all threads
        opcode       = self.code.opcodes.lookup_opcode(index)
        init_data    = init_load.add_shared(opcode.binary)
        init_data.label = opcode.label + "_init"
        init_load.add_instruction(label, load_address, init_data.label)
        init_load.toggle_memory()

    def resolve_thread_opcode (self, label, thread):
        """Convert opcode label into opcode number. Number depends on the order of the opcode definitions, pre-loads, and loads."""
        try:
            number = self.current_opcodes[thread].index(label)
        except ValueError:
            print("Unknown opcode {0} when resolving in thread {1}.".format(label, thread))
            self.ask_for_debugger()
        return number

    def resolve_opcode (self, label):
        if label not in self.defined_opcodes:
            print("Undefined opcode {0} when resolving to opcode number.".format(label))
            self.ask_for_debugger()
        numbers = []
        for thread in self.data.current_threads:
            number = self.resolve_thread_opcode(label, thread)
            numbers.append(number)
        if len(set(numbers)) > 1:
            print("Opcode numbers {0} for opcode {1} have resolved to different values over threads {2}.".format(numbers, label, self.data.current_threads))
            self.ask_for_debugger()
        return number

    def lookup_thread_opcode (self, opcode_number, thread):
        opcode_label = self.current_opcodes[thread][opcode_number]
        # ECL FIXME quick hack for when not all opcodes are used.
        if opcode_label is None:
            opcode_label = "nop"
        if opcode_label not in self.defined_opcodes:
            print("Unknown opcode {0} during lookup in thread {1}.".format(opcode_label, thread))
        opcode       = self.defined_opcodes[opcode_label]
        return opcode

    def lookup_opcode (self, opcode_number):
        opcodes = []
        for thread in self.data.current_threads:
            opcode = self.lookup_thread_opcode(opcode_number, thread)
            opcodes.append(opcode)
        if len(set(opcodes)) > 1:
            print("Conflicting opcodes {0} with number {1} in threads {2}.".format(opcodes, opcode_number, self.data.current_threads))
            self.ask_for_debugger()
        return opcode

