
#! /usr/bin/python3

from sys import exit
from pprint import pprint

class Opcode:
    """Contains symbolic information to assemble the bit representation of an opcode""" 

    def __init__ (self, label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        self.label      = label
        self.split      = split
        self.shift      = shift
        self.dyadic3    = dyadic3
        self.addsub     = addsub
        self.dual       = dual
        self.dyadic2    = dyadic2
        self.dyadic1    = dyadic1
        self.select     = select

    def is_dual (self):
        if self.dual == "dual":
            return True
        elif self.dual == "simple":
            return False
        else:
            print("Invalid simple/dual opcode specifier {0} for opcode {1}".format(self.dual, self.label))
            exit(1)

class Condition:
    """Contains symbolic information to assemble the bit representation of a branch condition""" 

    def __init__ (self, label, a, b, ab_operator):
        self.label          = label
        self.a              = a
        self.b              = b
        self.ab_operator    = ab_operator


class Instruction:
    """Contains symbolic information to assemble the bit representation of an instruction""" 

    def __init__ (self, label = None, address = None, opcode = None, D = None, DA = None, DB = None, A = None, B = None):
        self.label      = label
        self.address    = address
        self.opcode     = opcode
        self.D          = D
        self.DA         = DA
        self.DB         = DB
        self.A          = A
        self.B          = B

class Initialization_Load:
    """Contains info necessary to generate an initialization load instructions and data.
       The instruction is always an 'Add to Zero', so must exist in the system.
       The destination is a code or data label identifying the pointer or branch."""

    def __init__ (self, data, code, label = None, destination = None,):
        self.label          = label
        self.destination    = destination
        self.instructions   = []
        self.init_data      = []
        self.data = data
        # keep any init instructions added later in order, so add list of init instructions
        code.instructions.append(self.instructions)
        # variable locations are resolved based on where they are read first.
        # keep a toggle here to evenly distribute init data between A and B memories.
        self.memory = "A"

    def toggle_memory (self):
        if self.memory == "A":
            self.memory = "B"
        elif self.memory == "B":
            self.memory == "A"
        else:
            print("Invalid memory {0} for initialization loads.".format(self.memory))
            exit(1)

    def add_private (self, label):
        """Adds data for an initialization load. Order not important. Referenced by label."""
        new_init_data = self.data.allocate_private(label)
        self.init_data.append(new_init_data)

    def add_shared (self, label):
        """Adds data for an initialization load. Order not important. Referenced by label."""
        new_init_data = self.data.allocate_shared(label)
        self.init_data.append(new_init_data)

    def add_instruction (self, label, branch_destination, data_label):
        """Adds an instruction to initialization load. Remains in sequence added."""
        if self.memory == "A":
            A = data_label
            B = 0
        elif self.memory == "B":
            A = 0
            B = data_label
        else:
            print("Invalid memory {0} as branch init data {1} location".format(self.memory, data_label))
        new_instruction = Instruction(label = label, opcode = "add", D = branch_destination, A = A, B = B)
        self.instructions.append(new_instruction)

class Branch:
    """Holds the possible parameters to create a branch initialization load(s)."""

    def __init__ (self, code, condition_label, branch_parameters):
        self.condition = code.lookup_condition(condition_label)

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

class Usage:
    """Keeps track of used resources such as Branch Detectors"""

    def init_flags (self, entries):
        return [False for entry in range(len(entries))]

    def __init__ (self, configuration):
        self.configuration = configuration

        self.bd_in_use = self.init_flags(self.configuration.memory_map.bd)

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
            exit(-1)
        usage_flags[index] = True
        address = resource[index]
        return address


class Code:
    """Parses the code, which drives the resolution of unknowns about the data."""

    thread_count = 8

    def __init__ (self, data, configuration):
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

    def set_current_threads (self, thread_list):
        self.threads = thread_list

    def allocate_init_load (self, label, destination):
        new_init_load = Initialization_Load(self.data, self, label = label, destination = destination)
        self.init_loads.append(new_init_load)

    def allocate_opcode (self, label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        new_opcode = Opcode(label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select)
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
        branch = Branch(self, condition_label, branch_parameters)
        self.branches.append(branch)
        destination = branch.destination
        init_load   = self.lookup_init_load(destination)

        # Since init is identical across threads, the data is shared
        # There is always a label, which identifies the branch in question later.
        # Since the init data is shared, but resolved to its value later,
        # we have to give them temporary unique values

        # First, the instruction/data to init the branch detector entry
        data_label  = destination + "_init"
        init_load.add_shared(data_label)
        bd_addr = self.next_free_bd()
        init_load.add_instruction(init_load.label, bd_addr, data_label)
        init_load.toggle_memory()

        # Then add any instr/data to init other hardware if necessary
        if branch.sentinel_a is not None:
            data_label  = destination + "_init_sentinel_a"
            init_load.add_shared(data_label)
            init_load.add_instruction(None, destination, data_label)
            data_label  = branch.destination + "_init_mask_a"
            init_load.add_shared(data_label)
            init_load.add_instruction(None, destination, data_label)
            init_load.toggle_memory()

        if branch.sentinel_b is not None:
            data_label  = destination + "_init_sentinel_b"
            init_load.add_shared(data_label)
            init_load.add_instruction(None, destination, data_label)
            data_label  = branch.destination + "_init_mask_b"
            init_load.add_shared(data_label)
            init_load.add_instruction(None, destination, data_label)
            init_load.toggle_memory()

        if branch.counter is not None:
            data_label  = branch.destination + "_init_counter"
            init_load.add_shared(data_label)
            init_load.add_instruction(None, destination, data_label)
            init_load.toggle_memory()

        pprint(init_load.__dict__)
        
    def set_pc (self, label, pc_list):
        pc_count = len(pc_list)
        if pc_count != self.thread_count:
            print("ERROR: You must provide an initial PC for each of the {0} threads, but you provided {1}: {2}".format(self.thread_count, pc_count, pc_list))
            exit(1)
        self.initial_pc = pc_list

    def all_instructions (self):
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
 
