#! /usr/bin/python3

"""Convert integer values into machine-specific encodings (usually BitArrays).
   See Configuration for hardcoded/parameter values/strings."""

from bitstring      import pack, BitArray
from sys            import exit
from Debug          import Debug
from Data           import Private_Variable

# ---------------------------------------------------------------------------

class Base_Memory (Debug):
    """A generic list of BitArrays, dumpable to a file for loading into Verilog."""

    def create_memory(self, depth, width):
        self.mem = []
        for entry in range(depth):
            self.mem.append(BitArray(width))

    def __init__(self, depth, width, filename):
        self.create_memory(depth, width)
        self.filename   = filename
        self.depth      = depth
        self.width      = width
        
    def dump_format(self, width):
        """Numbers must be represented as zero-padded whole hex numbers"""
        characters = width // 4
        remainder = width % 4
        characters += min(1, remainder)
        format_string = "{:0" + str(characters) + "x}"
        return format_string

    def file_dump(self):
        """Dump to Verilog loadable format for readmemh()."""
        file_header  = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""
        with open(self.filename, 'w') as f:
            f.write(file_header + "\n")
            # We assume all memory values are the same width
            format_string = self.dump_format(self.width)
            for entry in self.mem:
                output = format_string.format(entry.uint)
                f.write(output + "\n")

    def write_bits (self, address, value):
        # Oh, this is ugly. BitArray left-justifies the bits!?!, so shift it back.
        position = self.width - value.length
        self.mem[address].overwrite(value,position)

# ---------------------------------------------------------------------------

class Data_Memory (Base_Memory):
    """Create the contents of a Data Memory referenced by an instruction read/write operands.
       This is essentially part of the combined register file/memory.
       Replicates private variables for each thread."""

    def write_variables (self, variables, offset = 0, thread = None):
        """Place the variable values in memory, with optional thread offset, and handling lists of values (arrays)."""
        for variable in variables:
            address = variable.address + offset
            if thread is None:
                value = variable.value
            else:
                value = variable.value[thread]
            if type(value) is list:
                for entry in value:
                    if type(value) != type(BitArray()):
                        entry = BitArray(uint=entry, length=self.width)
                    self.write_bits(address, entry)
                    address += 1
            else:
                # ECL FIXME
                # This should never happen, but let's allow it for now until
                # we have the final variable resolutions done. (init data for init loads)
                if value is None:
                    value = 0xDEADBEEF
                if type(value) != type(BitArray()):
                    value  = BitArray(uint=value, length=self.width)
                self.write_bits(address, value)

    def __init__(self, filename, memory, data, code, configuration):
        self.depth = configuration.memory_depth_words
        self.width = configuration.memory_width_bits
        Base_Memory.__init__(self, self.depth, self.width, filename)
        # Gather all variables for the given memory
        shared_variables  = [entry for entry in data.shared  if entry.memory == memory]
        private_variables = [entry for entry in data.private if entry.memory == memory]
        # Dump the shared variables once
        self.write_variables(shared_variables)
        # Dump the private variables, once per assigned thread, at their default offset
        for private_variable in private_variables:
            threads = private_variable.threads()
            offsets = configuration.default_offset.offsets
            for thread in threads:
                offset = offsets[thread]
                self.write_variables([private_variable], offset = offset, thread = thread)

# ---------------------------------------------------------------------------

class Default_Offset (Base_Memory):
    """Create the DO memory to set the Default Offsets of each thread. Not usually altered at runtime."""

    def __init__ (self, filename, configuration):
        offsets = configuration.default_offset.offsets
        width   = configuration.default_offset_width
        depth   = len(offsets)
        Base_Memory.__init__(self, depth, width, filename)
        for entry in range(depth):
            self.mem[entry] = BitArray(uint=offsets[entry], length=width)

# ---------------------------------------------------------------------------

class Opcode_Decoder (Base_Memory):
    """Construct the memory to translate from opcode to ALU control bits."""

    def load (self, thread_offset, thread):
        """Place the control bits for each opcode at the thread-offset location
           corresponding to the opcode number used in the instructions."""
        for opcode_number in range(self.opcode_count):
            opcode                                  = self.code.opcodes.lookup_thread_opcode(opcode_number, thread) 
            self.mem[opcode_number + thread_offset] = opcode.binary

    def __init__(self, filename, operators, code, configuration):
        self.code       = code
        self.opcode_count = configuration.opcode_count
        self.dyadic     = operators.dyadic
        self.triadic    = operators.triadic
        width           = self.triadic.control_width
        depth           = self.opcode_count * configuration.thread_count
        Base_Memory.__init__(self, depth, width, filename)
        for thread_number in range(configuration.thread_count):
            thread_offset = thread_number * self.opcode_count
            self.load(thread_offset, thread_number)
        # Kept for future Debug output
        # self.alu_control_format = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5},uint:{6},uint:{7}'.format(self.triadic.split_width, self.triadic.shift_width, self.triadic.dyadic3_width, self.triadic.addsub_width, self.triadic.dual_width, self.triadic.dyadic2_width, self.triadic.dyadic1_width, self.triadic.select_width)

    
# ---------------------------------------------------------------------------

class Instruction_Memory (Base_Memory):
    """Construct the instruction memory.
       Pretty simple, as all the work was done during resolution."""

    def to_binary(self, instruction):
        """Assemble a simple or dual instruction into binary."""
        # We assume the D/DA/DB operands were already error-checked.
        # If D is not none, it's a simple instruction and DA/DB must be None
        # the reverse means it's a dual instruction, else it's invalid
        if instruction.D is not None:
            instr_format = self.simple_instr_format
        else:
            instr_format = self.dual_instr_format
        return pack(instr_format, instruction.opcode, instruction.D, instruction.A, instruction.B)

    def __init__(self, filename, code, configuration):
        depth = configuration.memory_depth_words
        width = configuration.memory_width_bits
        Base_Memory.__init__(self, depth, width, filename)
        self.simple_instr_format = "uint:{0},uint:{1},uint:{2},uint:{3}".format(configuration.instr_OP_width, configuration.instr_D_width, configuration.instr_A_width, configuration.instr_B_width)
        self.dual_instr_format   = "uint:{0},uint:{1},uint:{2},uint:{3},uint:{4}".format(configuration.instr_OP_width, configuration.instr_DA_width, configuration.instr_DB_width, configuration.instr_A_width, configuration.instr_B_width)
        address = 0
        for instruction in code.all_instructions():
            self.write_bits(address, self.to_binary(instruction))
            address += 1

# ---------------------------------------------------------------------------

class Program_Counter (Base_Memory):
    """Load the Program Counter with the addresses of the given start instructions."""

    def __init__(self, filename, code, configuration):
        depth           = configuration.thread_count
        width           = configuration.pc_width
        Base_Memory.__init__(self, depth, width, filename)
        pc_format = "uint:{0}".format(configuration.pc_width)
        for thread_number in range(depth):
            pc = code.initial_pc[thread_number]
            pc = pack(pc_format, pc)
            self.write_bits(thread_number, pc)

# ---------------------------------------------------------------------------

class Branch_Detector:
    """Generate the binary values for the initialization loads of future branches.
       Contrary to most Generator classes, this does not output a memory file,
       but updates the resolved initialization loads."""

    def condition_to_binary (self, bdo, branch):
        condition = branch.condition
        dyadic    = bdo.dyadic
        condition_bits = BitArray()
        for entry in [condition.a, condition.b, condition.ab_operator]:
            field_bits = getattr(dyadic, entry, None)
            field_bits = getattr(bdo, entry, field_bits)
            if field_bits is None:
                print("Unknown branch field value: {0}".format(entry))
                self.ask_for_debugger()
            condition_bits.append(field_bits)
        return condition_bits

    def branch_to_binary (self, bdo, branch, configuration):
        # Processed here instead of in Resolver since it depends on binary values.
        # Predict not taken, cancel instruction if taken
        if branch.prediction == configuration.branch_label_not_taken:
            predict         = bdo.predict_not_taken
            predict_enable  = bdo.predict_enabled
            origin_enable   = bdo.origin_enabled
        # Predict taken, cancel instruction if not taken
        elif branch.prediction == configuration.branch_label_taken:
            predict         = bdo.predict_taken
            predict_enable  = bdo.predict_enabled
            origin_enable   = bdo.origin_enabled
        # No prediction, instruction never cancelled
        elif branch.prediction == configuration.branch_label_none:
            predict         = bdo.predict_not_taken
            predict_enable  = bdo.predict_disabled
            origin_enable   = bdo.origin_enabled
        # No prediction, trigger on previous instruction result anywhere, current instruction never cancelled
        elif branch.prediction == configuration.branch_label_anywhere:
            predict         = bdo.predict_not_taken
            predict_enable  = bdo.predict_disabled
            origin_enable   = bdo.origin_disabled
        # Predict not taken, trigger on previous instruction result anywhere, cancel current instruction
        elif branch.prediction == configuration.branch_label_anywhere_cancel:
            predict         = bdo.predict_not_taken
            predict_enable  = bdo.predict_enabled
            origin_enable   = bdo.origin_disabled
        else:
            print("Invalid branch prediction setting {0} on branch {1}.".format(branch.prediction, branch))
            self.ask_for_debugger()
        origin        = BitArray(uint=branch.origin,      length=bdo.origin_width)
        destination   = BitArray(uint=branch.destination, length=bdo.destination_width)
        condition     = self.condition_to_binary(bdo, branch)
        branch_bits   = BitArray()
        # Field order must match hardware
        for entry in [origin, origin_enable, destination, predict, predict_enable, condition]:
            branch_bits.append(entry)
        return branch_bits

    def find_branch_init_data (self, branch, configuration):
        """Find the init load instruction in a branch, check if the destination is a branch detector, 
           find the init data variable and fill it with the branch detector initialization binary data."""

        # Branch resolution always adds the BD init load first
        init_instr = branch.init_load.instructions[0]
        # But check anyway...
        if init_instr.D not in configuration.memory_map.bd:
            print("First init load destination of branch {1} is not to BD entry!".format(branch))
            self.ask_for_debugger()
        # Find which operand references the init data variable (the other is zero)
        if init_instr.A == 0:
            init_data_addr = init_instr.B
        else:
            init_data_addr = init_instr.A
        # Find the matching init data variable in the init load
        init_data = None
        for variable in branch.init_load.init_data:
            if variable.address == init_data_addr:
                init_data = variable
                break
        if init_data is None:
            print("Init data at address {0} not found for init load {1}".format(init_data_addr, branch.init_load))
            self.ask_for_debugger()
        # Check that it's not already resolved (it shouldn't, that's what we're doing here)
        if init_data.value is not None:
            print("Init data {0} is already resolved in init load {1}".format(init_data, branch.init_load))
            self.ask_for_debugger()
        return init_data

    def __init__(self, branch_detector_ops, code, configuration):
        self.bdo            = branch_detector_ops
        for branch in code.branches:
            init_data    = self.find_branch_init_data(branch, configuration)
            bd_init_data = self.branch_to_binary(self.bdo, branch, configuration)
            init_data.value = bd_init_data

        # Saved for future Debug output
        # condition_format         = 'uint:{0},uint:{1},uint:{2}'.format(self.branch_detect_obj.a_width, self.branch_detect_obj.b_width, self.branch_detect_obj.ab_operator_width)
        # branch_format            = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5}'.format(self.branch_detect_obj.origin_width, self.branch_detect_obj.origin_enable_width, self.branch_detect_obj.destination_width, self.branch_detect_obj.predict_taken_width, self.branch_detect_obj.predict_enable_width, self.branch_detect_obj.condition_width)


# ---------------------------------------------------------------------------

class Programmed_Offset (Base_Memory):
    """Calculates the run-time offset applied by the CPU to accesses at 
       indirect memory locations. The offset is applied, then incremented 
       by some constant. Contrary to most Generator classes, this does not 
       output a memory file, but updates the resolved initialization loads."""

    def to_sign_bit (self, value):
        """Return the signed magnitude sign bit for a given signed int"""
        if value >= 0:
            return 0
        else:
            return 1

    def pointer_to_binary (self, pointer, configuration, thread = None):
        """Convert a Pointer object to the binary init load value for a Programmed Offset entry."""
        # Add the Default Offset for each thread, so we point to the correct per-thread instance of the pointed-to variable
        # None thread means a shared variable holds the init data, or other unique location identical to all threads.
        if thread is not None:
            default_offset = configuration.default_offset.offsets[thread]
        else:
            default_offset = 0
        # Addresses wrap around when the offset is added, 
        # so express negative values as the modular sum value
        # Read and write pointers have different address ranges and offset bit widths
        if "D" in pointer.memory:
            # write pointer
            offset = (pointer.base - pointer.address + default_offset) % configuration.memory_depth_words_write
            offset = BitArray(uint=offset, length=configuration.po_write_offset_bit_width) 
        else:
            # read pointer
            offset = (pointer.base - pointer.address + default_offset) % configuration.memory_depth_words
            offset = BitArray(uint=offset,  length=configuration.po_read_offset_bit_width) 
        # The increment is a signed magnitude number (absolute value and sign bit)
        increment      = BitArray(uint=pointer.incr, length=configuration.po_increment_bits)
        increment_sign = self.to_sign_bit(pointer.incr)
        increment_sign = BitArray(uint=increment_sign, length=configuration.po_increment_sign_bits)
        # Now pack them into the Programmed Offset entry binary configurations
        pointer_bits = BitArray()
        for entry in [increment_sign, increment, offset]:
            pointer_bits.append(entry)
        return pointer_bits

    def load_init_data (self, pointer, configuration):
        # Only one data item to init a pointer
        init_data_variable  = pointer.init_load.init_data[0]
        # ECL FIXME we assume a Private Variable type holding init data per thread.
        # Not sure what holding init data in a shared variable means yet.
        if type(init_data_variable) is not Private_Variable:
            print("init data variable for pointer {0} is not Private: {1}. This is not yet supported.".format(pointer.label, init_data_variable))
            self.ask_for_debugger()
        if pointer.threads != init_data_variable.threads():
            print("Pointer {0} and its init data variable {0} don't exist in all the same threads".format(pointer.label, init_data_variable))
            self.ask_for_debugger()
        for thread in pointer.threads:
            pointer_bits = self.pointer_to_binary(pointer, configuration, thread)
            init_data_variable.value[thread] = pointer_bits

    def __init__(self, data, configuration):
        for pointer in data.pointers:
            self.load_init_data(pointer, configuration)


# ---------------------------------------------------------------------------

class Generator (Debug):
    """Converts the resolved code/data/branch/etc... information into binary machine code."""

    def __init__ (self, data, code, configuration, operators):
        Debug.__init__(self)

        self.operators = operators

        self.init_mems = []

        # Do all these first. Instructions and data depend on them

        self.OD = Opcode_Decoder(configuration.filename_od, self.operators, code, configuration)
        self.init_mems.append(self.OD)

        self.PC      = Program_Counter(configuration.filename_pc, code, configuration)
        self.PC_prev = Program_Counter(configuration.filename_pc_prev, code, configuration)
        self.init_mems.append(self.PC)
        self.init_mems.append(self.PC_prev)

        self.DO = Default_Offset(configuration.filename_do, configuration)
        self.init_mems.append(self.DO)

        self.BD = Branch_Detector(self.operators.branch_detector, code, configuration)
        self.PO = Programmed_Offset(data, configuration)

        # Now all Code and Data have been resolved and generated
        # We can now create the Data and Instruction Memories

        self.A = Data_Memory(configuration.filename_data_A, configuration.data_A_label, data, code, configuration)
        self.B = Data_Memory(configuration.filename_data_B, configuration.data_B_label, data, code, configuration)
        self.init_mems.append(self.A)
        self.init_mems.append(self.B)

        self.I = Instruction_Memory(configuration.filename_I, code, configuration)
        self.init_mems.append(self.I)

    def generate (self, mem_obj_list = None):
        if mem_obj_list is None:
            mem_obj_list = self.init_mems
        for mem in mem_obj_list:
            mem.file_dump()

