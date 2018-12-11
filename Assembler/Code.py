#! /usr/bin/python3

from sys        import exit
from Debug      import Debug
from Utility    import Utility

class Opcode (Debug):
    """Contains symbolic information to assemble the bit representation of an opcode""" 

    def __init__ (self, label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select, op_addr):
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
        self.addr       = op_addr

    def is_dual (self):
        """Does an opcode use the dual addressing mode (DA/DB instead of D)?"""
        if self.dual == "dual":
            return True
        elif self.dual == "simple":
            return False
        else:
            print("Invalid simple/dual opcode specifier {0} for opcode {1}".format(self.dual, self.label))
            exit(1)

    def is_same_as (self, opcode):
        """Check if the given opcode object encodes the same operation as this opcode, regardless of label or address."""
        for entry in ["split", "shift", "dyadic3", "addsub", "dual", "dyadic2", "dyadic1", "select"]:
            if getattr(self, entry) != getattr(opcode, entry):
                return False
        return True

class Opcode_Manager (Debug):
    """Holds and processes two lists of opcodes, per thread:
       the initial list programmed into the Opcode Decoder memory,
       and the current list which is updated by loads in the source.
       The instruction opcodes must be resolved immediately.
       Both lists are drawn from a larger list of defined opcodes for all threads."""

    def __init__ (self, code, data, configuration):
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
            exit(1)
        new_opcode = Opcode(label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select, op_addr)
        for previous_opcode in self.defined_opcodes.values():
            if new_opcode.is_same_as(previous_opcode):
                print("Opcode {0} performs the same operations as previously defined opcode {1}. Redefinitions not allowed.".format(new_opcode.label, previous_opcode.label))
                exit(1)
        self.defined_opcodes.update({label:new_opcode})

    def preload_thread_opcode (self, opcode_label, thread):
        """Preload an opcode into a threads' Opcode Decoder memory, 
           update the threads' current opcode list, and check consistency.
           All preloads must precede any opcode load, else opcode numbers will be inconsistent."""
        try:
            initial_index = self.initial_opcodes[thread].index(None)
        except ValueError:
            print("Opcode {0} cannot be pre-loaded. No more free slots in Opcode Decoder memory for thread {1}.".format(opcode_label, thread))
            exit(1)
        try:
            current_index = self.current_opcodes[thread].index(None)
        except ValueError:
            print("Opcode {0} cannot be pre-loaded. No more free slots in current opcode list for thread {1}.".format(opcode_label, thread))
            exit(1)
        # This happens if loads and preloads are interleaved, and thus initial and
        # current opcodes end up with different opcode numbers. Don't do that. :)
        if initial_index != current_index:
            print("Mismatched initial ({0}) and current ({1}) opcode numbers for opcode {2} in thread {3} because an opcode load precedes an opcode preload. Please fix that.".format(initial_index, current_index, opcode_label, thread))
            exit(1)
        self.initial_opcodes[thread][initial_index] = opcode_label
        self.current_opcodes[thread][current_index] = opcode_label

    def preload_opcode (self, opcode_label):
        if opcode_label not in self.defined_opcodes:
            print("Unknown opcode {0} for pre-loading.".format(opcode_label))
            exit(1)
        for thread in self.data.current_threads:
            self.preload_thread_opcode(opcode_label, thread)

    def load_thread_opcode (self, new_label, old_label, thread):
        """Load a new opcode, at runtime, either in an empty Opcode Decoder memory entry, or replacing another opcode if given."""
        if old_label is not None:
            index = self.current_opcodes[thread].index(old_label)
        else:
            try:
                index = self.current_opcodes[thread].index(None)
            except ValueError:
                print("Opcode {0} cannot be loaded. No more free slots in current opcode list for thread {1}. Maybe load over an unused older opcode?".format(new_label, thread))
                exit(1)
        self.current_opcodes[thread][index] = new_label
        return index

    def load_opcode (self, label, new_opcode_label, old_opcode_label = None):
        if old_opcode_label is not None and old_opcode_label not in self.defined_opcodes:
            print("Unknown previous opcode {0} when loading new opcode {1}.".format(old_opcode_label, new_opcode_label))
            exit(1)
        if new_opcode_label not in self.defined_opcodes:
            print("Unknown new opcode {0} when loading over previous opcode {1}.".format(new_opcode_label, old_opcode_label))
            exit(1)
        # Load and check for consistency in opcode indices across current threads
        # Opcode loads cannot become divergent and so must always happen before CDFG divergence and after CDFG re-convergence.
        indices = []
        for thread in self.data.current_threads:
            index = self.load_thread_opcode(new_opcode_label, old_opcode_label, thread)
            indices.append(index)
        if len(set(indices)) > 1:
            print("Opcode numbers {0} for new opcode {1} (old opcode {2}) have diverged over threads {3}.".format(indices, new_opcode_label, old_opcode_label, self.data.current_threads))
            exit(1)
        # Now allocate and resolve the init load for that opcode
        load_address = self.configuration.memory_map.od[index]
        init_load    = self.code.allocate_init_load(label, load_address)
        # Let's use shared data as opcode numbers are small, likely reused numbers
        init_data    = init_load.add_shared(index)
        init_load.add_instruction(label, load_address, init_data.address)
        init_load.toggle_memory()

    def resolve_thread_opcode (self, label, thread):
        """Convert opcode label into opcode number. Number depends on the order of the opcode definitions, pre-loads, and loads."""
        try:
            number = self.current_opcodes.index(label)
        except ValueError:
            print("Unknown opcode {0} when resolving in thread {1}.".format(label, thread))
            exit(1)
        return number

    def resolve_opcode (self, label):
        if label not in self.defined_opcodes:
            print("Unknown opcode {0} when resolving to opcode number.".format(label))
            exit(1)
        for thread in self.data.current_threads:
            self.resolve_thread_opcode(label, thread)
            # ECL FIXME add consistency check: same opcode at that number in all current threads


class Condition (Debug):
    """Contains symbolic information to assemble the bit representation of a branch condition""" 

    def __init__ (self, label, a, b, ab_operator):
        Debug.__init__(self)
        self.label          = label
        self.a              = a
        self.b              = b
        self.ab_operator    = ab_operator

class Instruction (Debug):
    """Contains symbolic information to assemble the bit representation of an instruction""" 

    def __init__ (self, label = None, address = None, opcode = None, D = None, DA = None, DB = None, A = None, B = None):
        Debug.__init__(self)
        self.label      = label
        self.address    = address
        self.opcode     = opcode
        self.D          = D
        self.DA         = DA
        self.DB         = DB
        self.A          = A
        self.B          = B

class Initialization_Load (Debug, Utility):
    """Contains info necessary to generate an initialization load instructions and data.
       The instruction is always an 'Add to Zero', so must exist in the system.
       The destination is a code or data label identifying the pointer or branch."""

    # variable locations are resolved based on which instruction operand reads them first.
    # keep a toggle here to evenly distribute init data between A and B memories.
    memory = "A"

    def toggle_memory (self):
        if Initialization_Load.memory == "A":
            Initialization_Load.memory = "B"
        elif Initialization_Load.memory == "B":
            Initialization_Load.memory == "A"
        else:
            print("Invalid memory {0} for initialization loads.".format(Initialization_Load.memory))
            exit(1)

    def __init__ (self, data, code, label = None, destination = None,):
        Debug.__init__(self)
        self.label          = label
        self.destination    = destination
        self.instructions   = []
        self.init_data      = []
        self.data           = data
        self.code           = code
        # keep any init instructions added later in order,
        # so add list of init instructions to global list
        self.code.instructions.append(self.instructions)

    def __str__ (self):
        output = super().__str__() + "\n"
        output += self.list_str(self.instructions)
        output += self.list_str(self.init_data)
        return output

    def add_private (self, label, threads):
        """Adds data in a private variable for an initialization load. Order not important. Referenced by label."""
        new_init_data = self.data.allocate_private(label, threads = threads)
        self.init_data.append(new_init_data)
        return new_init_data

    def add_shared (self, label):
        """Adds data in a shared variable for an initialization load. Order not important. 
           Referenced by label for previously defined shared variable,
           else reference by a literal value."""
        # Check if we gave a literal number, which becomes an unnnamed shared variable
        label = self.try_int(label)
        if type(label) == int:
            new_init_data = self.data.resolve_shared_value(label, Initialization_Load.memory)
            self.init_data.append(new_init_data)
            return new_init_data
        if type(label) == str:
            new_init_data = self.data.lookup_variable_name(label)
            if new_init_data is None:
                new_init_data = self.data.allocate_shared(label)
            self.init_data.append(new_init_data)
            return new_init_data

    def add_instruction (self, label, branch_destination, data_label):
        """Adds an instruction to initialization load. Remains in sequence added."""
        self.code.check_duplicate_instruction_label(label)
        if Initialization_Load.memory == "A":
            A = data_label
            B = 0
        elif Initialization_Load.memory == "B":
            A = 0
            B = data_label
        else:
            print("Invalid memory {0} as branch init data {1} location".format(Initialization_Load.memory, data_label))
        new_instruction = Instruction(label = label, opcode = "add", D = branch_destination, A = A, B = B)
        self.instructions.append(new_instruction)
        return new_instruction

class Branch (Debug):
    """Holds the possible parameters to create a branch initialization load(s) later."""

    def __init__ (self, code, condition_label, branch_parameters):
        Debug.__init__(self)
        self.condition = code.lookup_condition(condition_label)
        # The init load was already given, just blank.
        # We will fill it with the necessary code/data when we allocate this branch.
        self.init_load = None

        label = branch_parameters.pop(0)
        if label is not None:
            print("Branches cannot have labels: {0} at {1}".format(label, condition_label))
            exit(1)

        self.prediction = branch_parameters.pop(0)

        self.sentinel_a     = None
        self.mask_a         = None
        self.sentinel_b     = None
        self.mask_b         = None
        self.counter        = None
        self.destination    = None
        self.origin         = None

        if self.condition.a == "a_sentinel":
            self.sentinel_a = branch_parameters.pop(0)
            self.mask_a     = branch_parameters.pop(0)

        if self.condition.b == "b_sentinel":
            self.sentinel_b = branch_parameters.pop(0)
            self.mask_b     = branch_parameters.pop(0)

        if self.condition.b == "b_counter":
            self.counter    = branch_parameters.pop(0)

        self.destination = branch_parameters.pop(0)
        if len(branch_parameters) > 0:
            print("Unparsed branch parameters {0} for branch {1}".format(branch_parameters, condition_label))
            exit(1)

        # A branch definition always follows an instruction, and will execute "in parallel",
        # so we need to know which instruction so we know the branch origin, which will be
        # resolved after all the instructions are resolved and given addresses.
        self.instruction = code.instructions[-1]

class Usage (Debug):
    """Keeps track of used reconfigurable resources, such as opcodes, branch detectors, their counters, etc...
       An entry is None if free, or contains the label of the associated branch, pointer, or opcode if used."""

    def init_flags (self, entries):
        return [None for entry in range(len(entries))]

    def __init__ (self, configuration):
        Debug.__init__(self)
        self.configuration = configuration

        self.po_in_use = dict()
        for operand in ["A", "B", "DA", "DB"]:
            self.po_in_use[operand] = self.init_flags(self.configuration.memory_map.po[operand])

        self.sentinel_in_use = dict()
        self.mask_in_use     = dict()
        for operand in ["A", "B"]:
            self.sentinel_in_use[operand] = self.init_flags(self.configuration.memory_map.sentinel[operand])
            self.mask_in_use[operand]     = self.init_flags(self.configuration.memory_map.mask[operand])

        self.bc_in_use = self.init_flags(self.configuration.memory_map.bc)
        self.bd_in_use = self.init_flags(self.configuration.memory_map.bd)
#        self.od_in_use = self.init_flags(self.configuration.memory_map.od)
        
    def allocate_next (self, label, resource, usage_flags, index = None):
        """Return the first free allocation index and resource address, or do so at provided index if available."""
        if index is None:
            try:
                index = usage_flags.index(None)
            except ValueError:
                print("Label {0}: No more free slots in {1}.".format(label, usage_flags))
                exit(1)
        else:
            if usage_flags[index] is not None:
                print("Label {0}: Allocation conflict for {1} at index {2}.".format(label, usage_flags, index))
                exit(1)
        usage_flags[index] = label
        address = resource[index]
        return address, index

    def allocate_bd (self, label):
        address, index = self.allocate_next(label, self.configuration.memory_map.bd, self.bd_in_use)
        return address, index

    def allocate_po (self, label, operand):
        address, index = self.allocate_next(label, self.configuration.memory_map.po[operand], self.po_in_use[operand])
        return address

    def allocate_sentinel_mask (self, label, operand, index):
        # Allocate together to make sure the allocate_next() internal indexes always match
        sentinel_addr, dummy_index = self.allocate_next(label, self.configuration.memory_map.sentinel[operand], self.sentinel_in_use[operand], index)
        mask_addr, dummy_index     = self.allocate_next(label, self.configuration.memory_map.mask[operand],     self.mask_in_use[operand],     index)
        return (sentinel_addr, mask_addr)

    def allocate_bc (self, label, index):
        address, index = self.allocate_next(label, self.configuration.memory_map.bc, self.bc_in_use, index)
        return address

#    def allocate_od (self, label):
#        address, index = self.allocate_next(label, self.configuration.memory_map.od, self.od_in_use)
#        return address

class Code (Debug, Utility):
    """Parses the code, which drives the resolution of unknowns about the data."""

    def __init__ (self, data, configuration):
        Debug.__init__(self)
        self.data           = data
        self.configuration  = configuration
        self.usage          = Usage(configuration)
        self.init_loads     = []
        self.instructions   = []
        self.opcodes        = Opcode_Manager(self, data, configuration)
        self.conditions     = []
        self.branches       = []
        self.initial_pc     = []

    def __str__ (self):
        output = "\nCode:\n"
        output += "\n" + str(self.usage) + "\n"
        output += "\n" + self.list_str(self.init_loads) + "\n"
        for instruction in self.instructions:
            if type(instruction) == list:
                output += self.list_str(instruction)
            else:
                output += str(instruction) + "\n"
        output += "\n"
        output += "\n" + str(self.opcodes) + "\n"
        output += self.list_str(self.conditions) + "\n"
        output += self.list_str(self.branches) + "\n"
        output += "Initial PC: " + str(self.initial_pc) + "\n"
        return output

    def allocate_init_load (self, label, destination):
        new_init_load = Initialization_Load(self.data, self, label = label, destination = destination)
        self.init_loads.append(new_init_load)
        return new_init_load

    def allocate_opcode (self, arguments):
        """Unpack and pass along the opcode source command."""
        return self.code.opcodes.define_opcode(*arguments)

    def allocate_condition (self, label, a, b, ab_operator):
        new_condition = Condition(label, a, b, ab_operator)
        self.conditions.append(new_condition)
        return new_condition

    def lookup_opcode (self, label):
        for opcode in self.opcodes:
            if opcode.label == label:
                return opcode
        print("Opcode {0} not found".format(label))
        exit(1)

    def lookup_condition(self, label):
        for condition in self.conditions:
            if condition.label == label:
                return condition
        print("Condition {0} not found".format(label))
        exit(1)

    def all_instructions (self):
        """Iterate over all instruction, nesting into lists of instructions."""
        for instruction in self.instructions:
            if type(instruction) == list:
                for list_instruction in instruction:
                    yield list_instruction
            else:
                yield instruction
 
    def lookup_instruction (self, label):
        for instruction in self.all_instructions():
            if instruction.label == label:
                return instruction
        return None

    def check_duplicate_instruction_label (self, label):
        if label is not None:
            instruction = self.lookup_instruction(label)
            if instruction is not None:
                print("Label {0} is already in use by instruction {1}.".format(label, instruction))
                exit(1)

    def allocate_instruction_simple (self, opcode_label, instruction_label, D, A, B):
        self.check_duplicate_instruction_label(instruction_label)
        new_instruction = Instruction(label = instruction_label, opcode = opcode_label, D = D, A = A, B = B)
        self.instructions.append(new_instruction)

    def allocate_instruction_dual (self, opcode_label, instruction_label, DA, DB, A, B):
        self.check_duplicate_instruction_label(instruction_label)
        new_instruction = Instruction(label = instruction_label, opcode = opcode_label, DA = DA, DB = DB, A = A, B = B)
        self.instructions.append(new_instruction)

    def allocate_instruction (self, opcode_label, operands):
        opcode = self.lookup_opcode(opcode_label)
        if opcode.is_dual is True:
            self.allocate_instruction_dual(opcode_label, *operands)
        else:
            self.allocate_instruction_simple(opcode_label, *operands)

    def lookup_init_load (self, destination):
        for init_load in self.init_loads:
            if init_load.destination == destination:
                return init_load
        return None
 
    def allocate_branch (self, condition_label, branch_parameters):
        """Parse the branch definition parameters and create the necessary init code/data, which will be filled-in later."""
        # Since init is identical across threads, the data is shared. 
        # There is always a destination label, which identifies the 
        # branch in question later.

        branch = Branch(self, condition_label, branch_parameters)
        branch.init_load = self.lookup_init_load(branch.destination)
        self.branches.append(branch)

        # First, the instruction and data to initialize the branch detector entry
        data_label = branch.destination + "_init"
        branch.init_load.add_shared(data_label)
        bd_addr, bd_index = self.usage.allocate_bd(condition_label)
        branch.init_load.add_instruction(branch.init_load.label, bd_addr, data_label)

        # Then add any instr/data to init other hardware if necessary

        if branch.sentinel_a is not None:
            (sentinel_addr, mask_addr) = self.usage.allocate_sentinel_mask(condition_label, "A", bd_index)
            branch.init_load.add_shared(branch.sentinel_a)
            branch.init_load.add_instruction(None, sentinel_addr, branch.sentinel_a)
            branch.init_load.add_shared(branch.mask_a)
            branch.init_load.add_instruction(None, mask_addr, branch.mask_a)

        if branch.sentinel_b is not None:
            (sentinel_addr, mask_addr) = self.usage.allocate_sentinel_mask(condition_label, "B", bd_index)
            branch.init_load.add_shared(branch.sentinel_b)
            branch.init_load.add_instruction(None, sentinel_addr, branch.sentinel_b)
            branch.init_load.add_shared(branch.mask_b)
            branch.init_load.add_instruction(None, mask_addr, branch.mask_b)

        if branch.counter is not None:
            bc_addr = self.usage.allocate_bc(condition_label, bd_index)
            branch.init_load.add_shared(branch.counter)
            branch.init_load.add_instruction(None, bc_addr, branch.counter)

        # Next init code/data will use the other data memory to even out their use
        branch.init_load.toggle_memory()

    def set_pc (self, label, pc_list):
        pc_count = len(pc_list)
        if pc_count != self.configuration.thread_count:
            print("ERROR: You must provide an initial PC for each of the {0} threads, but you provided {1}: {2}".format(self.configuration.thread_count, pc_count, pc_list))
            exit(1)
        self.initial_pc = pc_list

    def is_instruction_dual (self, instruction):
        opcode = self.lookup_opcode(instruction.opcode)
        return opcode.is_dual()

