#! /usr/bin/python3

from sys            import exit
from Debug          import Debug
from Utility        import Utility
from Opcode_Manager import Opcode_Manager
from bitstring      import BitArray


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
            return
        if Initialization_Load.memory == "B":
            Initialization_Load.memory = "A"
            return
        print("Invalid memory {0} for initialization loads.".format(Initialization_Load.memory))
        self.ask_for_debugger()

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
        # Check if we gave a literal number or BitArray, which becomes an unnnamed shared variable
        label = self.try_int(label)
        if type(label) == int or type(label) == BitArray:
            new_init_data = self.data.resolve_shared_value(label, Initialization_Load.memory)
            self.init_data.append(new_init_data)
            return new_init_data
        if type(label) == str:
            new_init_data = self.data.lookup_variable_name(label)
            if new_init_data is None:
                new_init_data = self.data.allocate_shared(label)
            self.init_data.append(new_init_data)
            return new_init_data
        print("Label {0} has unknown type {1} when adding shared variable to init load.".format(label, type(label)))
        self.ask_for_debugger()

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
        add_opcode = self.code.opcodes.resolve_opcode("add")
        new_instruction = Instruction(label = label, opcode = add_opcode, D = branch_destination, A = A, B = B)
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
            self.ask_for_debugger()

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
            self.ask_for_debugger()

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
                self.ask_for_debugger()
        else:
            if usage_flags[index] is not None:
                print("Label {0}: Allocation conflict for {1} at index {2}.".format(label, usage_flags, index))
                self.ask_for_debugger()
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

    def __init__ (self, data, configuration, operators):
        Debug.__init__(self)
        self.operators      = operators
        self.data           = data
        self.configuration  = configuration
        self.usage          = Usage(configuration)
        self.init_loads     = []
        self.instructions   = []
        self.opcodes        = Opcode_Manager(self, data, configuration, operators)
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
        return self.opcodes.define_opcode(*arguments)

    def preload_opcode (self, opcodes):
        return self.opcodes.preload_opcodes(opcodes)

    def load_opcode (self, label, new_opcode, old_opcode = None):
        self.opcodes.load_opcode(label, new_opcode, old_opcode)

    def allocate_condition (self, label, a, b, ab_operator):
        new_condition = Condition(label, a, b, ab_operator)
        self.conditions.append(new_condition)
        return new_condition

    def lookup_condition(self, label):
        for condition in self.conditions:
            if condition.label == label:
                return condition
        print("Condition {0} not found".format(label))
        self.ask_for_debugger()

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
                self.ask_for_debugger()

    def allocate_instruction_simple (self, opcode_label, instruction_label, D, A, B):
        self.check_duplicate_instruction_label(instruction_label)
        resolved_opcode = self.opcodes.resolve_opcode(opcode_label)
        new_instruction = Instruction(label = instruction_label, opcode = resolved_opcode, D = D, A = A, B = B)
        self.instructions.append(new_instruction)

    def allocate_instruction_dual (self, opcode_label, instruction_label, DA, DB, A, B):
        self.check_duplicate_instruction_label(instruction_label)
        resolved_opcode = self.opcodes.resolve_opcode(opcode_label)
        new_instruction = Instruction(label = instruction_label, opcode = resolved_opcode, DA = DA, DB = DB, A = A, B = B)
        self.instructions.append(new_instruction)

    def allocate_instruction (self, opcode_label, operands):
        opcode_number = self.opcodes.resolve_opcode(opcode_label)
        opcode        = self.opcodes.lookup_opcode(opcode_number)
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
            self.ask_for_debugger()
        self.initial_pc = pc_list

    def is_instruction_dual (self, instruction):
        opcode = self.opcodes.lookup_opcode(instruction.opcode)
        return opcode.is_dual()

