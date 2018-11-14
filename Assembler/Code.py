
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
        self.data = data
        # keep any init instructions added later in order,
        # so add list of init instructions to global list
        code.instructions.append(self.instructions)

    def __str__ (self):
        output = "\nInit Load:\n"
        output += "Label: " + str(self.label) + "\n"
        output += "Dest: " + str(self.destination) + "\n"
        output += self.list_str(self.instructions)
        output += self.list_str(self.init_data)
        return output

    def add_private (self, label):
        """Adds data for an initialization load. Order not important. Referenced by label."""
        new_init_data = self.data.allocate_private(label)
        self.init_data.append(new_init_data)

    def add_shared (self, label):
        """Adds data for an initialization load. Order not important. 
           Referenced by label for previously defined shared variable,
           else reference by a literal value."""
        # Check if we gave a literal number, which becomes an unnnamed shared variable
        label = self.try_int(label)
        if type(label) == int:
            new_init_data = self.data.resolve_shared_value(label, Initialization_Load.memory)
            self.init_data.append(new_init_data)
            return new_init_data
        if type(label) == str:
            new_init_data = self.data.lookup_variable_name(label, self.data.shared)
            if new_init_data is None:
                new_init_data = self.data.allocate_shared(label)
            self.init_data.append(new_init_data)
            return new_init_data

    def add_instruction (self, label, branch_destination, data_label):
        """Adds an instruction to initialization load. Remains in sequence added."""
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
    """Keeps track of used resources such as Branch Detectors"""

    def init_flags (self, entries):
        return [False for entry in range(len(entries))]

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
            self.mask_in_use[operand] = self.init_flags(self.configuration.memory_map.mask[operand])

        self.bc_in_use = self.init_flags(self.configuration.memory_map.bc)
        self.bd_in_use = self.init_flags(self.configuration.memory_map.bd)
        self.od_in_use = self.init_flags(self.configuration.memory_map.od)
        
    def allocate_next (self, resource, usage_flags):
        try:
            index = usage_flags.index(False)
        except ValueError:
            print("No more free slots for {0}.".format(usage_flags))
            exit(1)
        usage_flags[index] = True
        address = resource[index]
        return address

    def allocate_bd (self):
        return self.allocate_next(self.configuration.memory_map.bd, self.bd_in_use)

    def allocate_po (self, operand):
        return self.allocate_next(self.configuration.memory_map.po[operand], self.po_in_use[operand])

    def allocate_sentinel_mask (self, operand):
        # Allocate together to make sure the allocate_next() internal indexes always match
        sentinel_addr = self.allocate_next(self.configuration.memory_map.sentinel[operand], self.sentinel_in_use[operand])
        mask_addr = self.allocate_next(self.configuration.memory_map.mask[operand], self.mask_in_use[operand])
        return (sentinel_addr, mask_addr)

    def allocate_bc (self):
        return self.allocate_next(self.configuration.memory_map.bc, self.bc_in_use)

    def allocate_od (self):
        return self.allocate_next(self.configuration.memory_map.od, self.od_in_use)


class Code (Debug, Utility):
    """Parses the code, which drives the resolution of unknowns about the data."""

    # Not likely to ever change...
    thread_count = 8

    def __init__ (self, data, configuration):
        Debug.__init__(self)
        self.data           = data
        self.configuration  = configuration
        self.usage          = Usage(configuration)
        self.threads        = []
        self.init_loads     = []
        self.instructions   = []
        self.opcodes        = []
        self.conditions     = []
        self.branches       = []
        self.initial_pc     = []

    def __str__ (self):
        output = "\nCode:\n"
        output += "\n" + str(self.usage) + "\n"
        output += "\nThreads: " + str(self.threads) + "\n"  
        output += self.list_str(self.init_loads) + "\n"
        for instruction in self.instructions:
            if type(instruction) == list:
                output += self.list_str(instruction)
            else:
                output += str(instruction) + "\n"
        output += "\n"
        output += self.list_str(self.opcodes) + "\n"
        output += self.list_str(self.conditions) + "\n"
        output += self.list_str(self.branches) + "\n"
        output += str(self.initial_pc) + "\n"
        return output

    def set_current_threads (self, thread_list):
        self.threads = [self.try_int(thread) for thread in thread_list]
        # Type check
        for thread in self.threads:
            if type(thread) is not int:
                print("Thread values must be literal integers: {0}".format(self.threads))
                exit(1)
        # Range check
        min_thread = 0
        max_thread = self.configuration.thread_count - 1
        for thread in self.threads:
            if thread < min_thread or thread > max_thread:
                print("Out of range thread: {0}. Min: {1}, Max: {2}".format(self.thread, min_thread, max_thread))
                exit(1)
        # Duplication test
        if len(self.threads) < len(set(self.threads)):
            print("Duplicate thread numbers not allowed: {0}".format(threads))
            exit(1)

    def allocate_init_load (self, label, destination):
        new_init_load = Initialization_Load(self.data, self, label = label, destination = destination)
        self.init_loads.append(new_init_load)

    def allocate_opcode (self, label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        op_addr = self.usage.allocate_od()
        new_opcode = Opcode(label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select, op_addr)
        self.opcodes.append(new_opcode)
        return new_opcode
        
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

    def allocate_instruction_simple (self, opcode_label, instruction_label, D, A, B):
        new_instruction = Instruction(label = instruction_label, opcode = opcode_label, D = D, A = A, B = B)
        self.instructions.append(new_instruction)

    def allocate_instruction_dual (self, opcode_label, instruction_label, DA, DB, A, B):
        new_instruction = Instruction(label = instruction_label, opcode = opcode_label, DA = DA, DB = DB, A = A, B = B)
        self.instructions.append(new_instruction)

    def allocate_instruction (self, opcode_label, operands):
        opcode = self.lookup_opcode(opcode_label)
        if opcode.is_dual is True:
            self.allocate_instruction_dual(opcode_label, *operands)
        else:
            self.allocate_instruction_simple(opcode_label, *operands)

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
        bd_addr = self.usage.allocate_bd()
        branch.init_load.add_instruction(branch.init_load.label, bd_addr, data_label)

        # Then add any instr/data to init other hardware if necessary

        if branch.sentinel_a is not None:
            (sentinel_addr, mask_addr) = self.usage.allocate_sentinel_mask("A")
            branch.init_load.add_shared(branch.sentinel_a)
            branch.init_load.add_instruction(None, sentinel_addr, branch.sentinel_a)
            branch.init_load.add_shared(branch.mask_a)
            branch.init_load.add_instruction(None, mask_addr, branch.mask_a)

        if branch.sentinel_b is not None:
            (sentinel_addr, mask_addr) = self.usage.allocate_sentinel_mask("B")
            branch.init_load.add_shared(branch.sentinel_b)
            branch.init_load.add_instruction(None, sentinel_addr, branch.sentinel_b)
            branch.init_load.add_shared(branch.mask_b)
            branch.init_load.add_instruction(None, mask_addr, branch.mask_b)

        if branch.counter is not None:
            bc_addr = self.usage.allocate_bc()
            branch.init_load.add_shared(branch.counter)
            branch.init_load.add_instruction(None, bc_addr, branch.counter)

        # Next init code/data will use the other data memory to even out their use
        branch.init_load.toggle_memory()

    def set_pc (self, label, pc_list):
        pc_count = len(pc_list)
        if pc_count != self.thread_count:
            print("ERROR: You must provide an initial PC for each of the {0} threads, but you provided {1}: {2}".format(self.thread_count, pc_count, pc_list))
            exit(1)
        self.initial_pc = pc_list

    def all_instructions (self):
        """Iterate over all instruction, nesting into lists of instructions."""
        for instruction in self.instructions:
            if type(instruction) == list:
                for list_instruction in instruction:
                    yield list_instruction
            else:
                yield instruction
 
    def is_instruction_dual (self, instruction):
        opcode = self.lookup_opcode(instruction.opcode)
        return opcode.is_dual()

    def lookup_init_load (self, destination):
        for init_load in self.init_loads:
            if init_load.destination == destination:
                return init_load
        return None
 
    def lookup_instruction (self, label):
        for instruction in self.all_instructions():
            if instruction.label == label:
                return instruction
        return None
 
