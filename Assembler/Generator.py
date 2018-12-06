#! /usr/bin/python3

"""Machine-specific knowledge, such as bit widths, goes here, not in Configuration."""

from bitstring      import pack, BitArray
from sys            import exit
from Debug          import Debug
from Configuration  import Configuration

# ---------------------------------------------------------------------------

class Dyadic_Operators (Debug):
    """Common definition of dyadic operations.
       Treat them as mux data inputs, LSB
       on the right, with a/b as the MSB/LSB selectors."""

    def __init__ (self):
        self.operator_width = 4

        self.always_zero    = BitArray("0b0000")
        self.a_and_b        = BitArray("0b1000")
        self.a_and_not_b    = BitArray("0b0100")
        self.a              = BitArray("0b1100")
        self.not_a_and_b    = BitArray("0b0010")
        self.b              = BitArray("0b1010")
        self.a_xor_b        = BitArray("0b0110")
        self.a_or_b         = BitArray("0b1110")
        self.a_nor_b        = BitArray("0b0001")
        self.a_xnor_b       = BitArray("0b1001")
        self.not_b          = BitArray("0b0101")
        self.a_or_not_b     = BitArray("0b1101")
        self.not_a          = BitArray("0b0011")
        self.not_a_or_b     = BitArray("0b1011")
        self.a_nand_b       = BitArray("0b0111")
        self.always_one     = BitArray("0b1111")

# ---------------------------------------------------------------------------

class Triadic_ALU_Operators (Debug):
    """Control bit fields for the Triadic ALU"""

    def __init__ (self, dyadic_obj):
        self.dyadic = dyadic_obj

        # From Verilog code
        self.control_width          = 20

        self.select_r               = BitArray("0b00")
        self.select_r_zero          = BitArray("0b01")
        self.select_r_neg           = BitArray("0b10")
        self.select_s               = BitArray("0b11")
        self.simple                 = BitArray("0b0")
        self.dual                   = BitArray("0b1")
        self.addsub_a_plus_b        = BitArray("0b00")
        self.addsub_minus_a_plus_b  = BitArray("0b01")
        self.addsub_a_minus_b       = BitArray("0b10")
        self.addsub_minus_a_minus_b = BitArray("0b11")
        self.shift_none             = BitArray("0b00")
        self.shift_right            = BitArray("0b01")
        self.shift_right_signed     = BitArray("0b10")
        self.shift_left             = BitArray("0b11")
        self.split_no               = BitArray("0b0")
        self.split_yes              = BitArray("0b1")

        self.select_width           = 2
        self.dyadic1_width          = self.dyadic.operator_width
        self.dyadic2_width          = self.dyadic.operator_width
        self.dual_width             = 1
        self.addsub_width           = 2
        self.dyadic3_width          = self.dyadic.operator_width
        self.shift_width            = 2
        self.split_width            = 1

        assert (self.select_width + self.dyadic1_width + self.dyadic2_width + self.dual_width + self.addsub_width + self.dyadic3_width + self.shift_width + self.split_width) == self.control_width, "ERROR: ALU control word width and sum of control bits widths do not agree"


# ---------------------------------------------------------------------------

class Branch_Detector_Operators (Debug):
    """Control bit fields for the Flow Control Branch Detector"""

    def __init__ (self, dyadic_obj):
        self.dyadic = dyadic_obj

        # From Verilog code
        self.control_width          = 31

        self.origin_enabled         = BitArray("0b1")
        self.origin_disabled        = BitArray("0b0")
        self.predict_taken          = BitArray("0b1")
        self.predict_not_taken      = BitArray("0b0")
        self.predict_enabled        = BitArray("0b1")
        self.predict_disabled       = BitArray("0b0")
        self.a_negative             = BitArray("0b00")
        self.a_carryout             = BitArray("0b01")
        self.a_sentinel             = BitArray("0b10")
        self.a_external             = BitArray("0b11")
        self.b_lessthan             = BitArray("0b00")
        self.b_counter              = BitArray("0b01")
        self.b_sentinel             = BitArray("0b10")
        self.b_external             = BitArray("0b11")

        self.origin_width           = 10
        self.origin_enable_width    = 1
        self.destination_width      = 10
        self.predict_taken_width    = 1
        self.predict_enable_width   = 1
        self.a_width                = 2
        self.b_width                = 2
        self.ab_operator_width      = self.dyadic.operator_width
        self.condition_width        = self.a_width + self.b_width + self.ab_operator_width

        assert (self.origin_width + self.origin_enable_width + self.destination_width + self.predict_taken_width + self.predict_enable_width + self.condition_width) == self.control_width, "ERROR: Branch Detector control word width and sum of control bits widths do not agree"

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
        # Must match Verilog code, currently 10 or 12 bits, so same output either way
        width   = 12
        depth   = len(offsets)
        Base_Memory.__init__(self, depth, width, filename)
        for entry in range(depth):
            self.mem[entry] = BitArray(uint=offsets[entry], length=width)

# ---------------------------------------------------------------------------

class Opcode_Decoder (Base_Memory):
    """Construct the memory to translate from opcode to ALU control bits."""

    def to_binary (self, opcode):
        """Converts the fields of the control bits of an instruction opcode, 
           looked-up from symbolic names, to binary encoding. 
           Field values are strings naming the same field in the dyadic/triadic
           operations objects."""
        control_bits = BitArray()
        for entry in [opcode.split, opcode.shift, opcode.dyadic3, opcode.addsub, opcode.dual, opcode.dyadic2, opcode.dyadic1, opcode.select]:
            field_bits = getattr(self.dyadic, entry, None)
            field_bits = getattr(self.triadic, entry, field_bits)
            if field_bits is None:
                print("Unknown opcode field value: {0}".format(entry))
                exit(1)
            control_bits.append(field_bits)
        return control_bits

    def load (self, opcodes, thread_offset):
        """Place the control bits for each opcode at the thread-offset location
           corresponding to the opcode number used in the instructions."""
        for opcode_number in range(len(opcodes)):
            opcode                                  = opcodes[opcode_number]
            control_bits                            = self.to_binary(opcode)
            self.mem[opcode_number + thread_offset] = control_bits

    def __init__(self, filename, dyadic_obj, triadic_obj, code, configuration):
        self.opcode_count = 16
        self.dyadic     = dyadic_obj
        self.triadic    = triadic_obj
        width           = self.triadic.control_width
        depth           = self.opcode_count * configuration.thread_count
        Base_Memory.__init__(self, depth, width, filename)
        for thread_number in range(configuration.thread_count):
            thread_offset = thread_number * self.opcode_count
            self.load(code.opcodes, thread_offset)
        # Kept for future Debug output
        # self.alu_control_format = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5},uint:{6},uint:{7}'.format(self.triadic.split_width, self.triadic.shift_width, self.triadic.dyadic3_width, self.triadic.addsub_width, self.triadic.dual_width, self.triadic.dyadic2_width, self.triadic.dyadic1_width, self.triadic.select_width)

    
# ---------------------------------------------------------------------------

class Instruction_Memory (Base_Memory):
    """Construct the instruction memory.
       Pretty simple, as all the work was done during resolution."""

    simple_instr_format = 'uint:4,uint:12,uint:10,uint:10'
    dual_instr_format   = 'uint:4,uint:6,uint:6,uint:10,uint:10'

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
        address = 0
        for instruction in code.all_instructions():
            self.write_bits(address, self.to_binary(instruction))
            address += 1

# ---------------------------------------------------------------------------

class Program_Counter (Base_Memory):
    """Load the Program Counter with the addresses of the given start instructions."""

    pc_width = 10
    pc_format = 'uint:{0}'.format(pc_width)

    def __init__(self, filename, code, configuration):
        depth           = configuration.thread_count
        width           = self.pc_width
        Base_Memory.__init__(self, depth, width, filename)
        for thread_number in range(depth):
            pc = code.initial_pc[thread_number]
            pc = pack(self.pc_format, pc)
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
                exit(1)
            condition_bits.append(field_bits)
        return condition_bits

    def branch_to_binary (self, bdo, branch):
        # Processed here instead of in Resolver since it depends on binary values.
        if branch.prediction == "not_taken":
            predict         = bdo.predict_not_taken
            predict_enable  = bdo.predict_enabled
        elif branch.prediction == "taken":
            predict         = bdo.predict_taken
            predict_enable  = bdo.predict_enabled
        elif branch.prediction == "unpredicted":
            predict         = bdo.predict_not_taken
            predict_enable  = bdo.predict_disabled
        else:
            print("Invalid branch prediction setting {0} on branch {1}.".format(branch.prediction, branch))
            sys.exit(1)
        # ECL FIXME We don't have a way to disable branch origin yet in the assembly source. See DESIGN_NOTES TODO.
        origin_enable = bdo.origin_enabled
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
            exit(1)
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
            exit(1)
        # Check that it's not already resolved (it shouldn't, that's what we're doing here)
        if init_data.value is not None:
            print("Init data {0} is already resolved in init load {1}".format(init_data, branch.init_load))
            exit(1)
        return init_data

    def __init__(self, branch_detector_ops, code, configuration):
        branch_count        = 4
        self.bdo            = branch_detector_ops
        for branch in code.branches:
            init_data    = self.find_branch_init_data(branch, configuration)
            bd_init_data = self.branch_to_binary(self.bdo, branch)
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

    # Contrary to Default Offset, the offset length matters here, since other
    # data follows it in the upper bits.
    read_offset_bit_width   = 10
    write_offset_bit_width  = 12

    # These must match the Verilog parameters
    entries              = 4
    increment_bits       = 4
    increment_sign_bits  = 1

    def to_sign_bit (self, value):
        """Return the signed magnitude sign bit for a given signed int"""
        if value >= 0:
            return 0
        else:
            return 1

    def pointer_to_binary (self, pointer, configuration, thread = None):
        """Convert a Pointer object to the binary init load values 
           for a read/write pair of Programmed Offset entries."""
        # Add the Default Offset for each thread, so we point to the correct per-thread instance of the pointed-to variable
        # None thread means a shared variable holds the init data, or other unique location identical to all threads.
        if thread is not None:
            default_offset = configuration.default_offset.offsets[thread]
        else:
            default_offset = 0
        # Addresses wrap around when the offset is added, 
        # so express negative values as the modular sum value
        read_offset  = (pointer.read_base  - pointer.address + default_offset) % configuration.memory_depth_words
        write_offset = (pointer.write_base - pointer.address + default_offset) % configuration.memory_depth_words_write
        read_offset  = BitArray(uint=read_offset,  length=self.read_offset_bit_width) 
        write_offset = BitArray(uint=write_offset, length=self.write_offset_bit_width) 
        # The increments are signed magnitude numbers
        read_increment  = BitArray(uint=pointer.read_incr,  length=self.increment_bits)
        write_increment = BitArray(uint=pointer.write_incr, length=self.increment_bits)
        # And the sign bit...
        read_increment_sign  = self.to_sign_bit(pointer.read_incr)
        write_increment_sign = self.to_sign_bit(pointer.write_incr)
        read_increment_sign  = BitArray(uint=read_increment_sign,  length=self.increment_sign_bits)
        write_increment_sign = BitArray(uint=write_increment_sign, length=self.increment_sign_bits)
        # Now pack them into the Programmed Offset entry binary configurations
        read_pointer_bits = BitArray()
        for entry in [read_increment_sign, read_increment, read_offset]:
            read_pointer_bits.append(entry)
        write_pointer_bits = BitArray()
        for entry in [write_increment_sign, write_increment, write_offset]:
            write_pointer_bits.append(entry)
        return (read_pointer_bits, write_pointer_bits)

    def load_init_data (self, pointer, configuration):
        # Assumes creation order for init data: read, then write. FIXME need a better way.
        read_init_data_variable  = pointer.init_load.init_data[0]
        write_init_data_variable = pointer.init_load.init_data[1]
        if type(read_init_data_variable) != type(write_init_data_variable):
            print("Mismatched pointer init data variable types. Read: {0}, Write: {1}".format(read_init_data_variable, write_init_data_variable))
            exit(1)
        # ECL FIXME we assume a Private Variable type holding init data per thread.
        # Not sure what holding init data in a shared variable means yet.
        if pointer.threads != read_init_data_variable.threads() or pointer.threads != write_init_data_variable.threads():
            print("Pointer {0} and its init data variables don't all exist in the same threads".format(pointer.label))
            exit(1)
        for thread in pointer.threads:
            read_pointer_bits, write_pointer_bits  = self.pointer_to_binary(pointer, configuration, thread)
            read_init_data_variable.value[thread]  = read_pointer_bits
            write_init_data_variable.value[thread] = write_pointer_bits

    def __init__(self, data, configuration):
        for pointer in data.pointers:
            self.load_init_data(pointer, configuration)


# ---------------------------------------------------------------------------

class Generator (Debug):
    """Converts the resolved code/data/branch/etc... information into binary machine code."""

    def __init__ (self, data, code, configuration):

        self.Dyadic  = Dyadic_Operators()
        self.Triadic = Triadic_ALU_Operators(self.Dyadic)
        self.BDO     = Branch_Detector_Operators(self.Dyadic)

        self.init_mems = []

        # Do all these first. Instructions and data depend on them

        self.OD = Opcode_Decoder("OD.mem", self.Dyadic, self.Triadic, code, configuration)
        self.init_mems.append(self.OD)

        self.PC      = Program_Counter("PC.mem", code, configuration)
        self.PC_prev = Program_Counter("PC_prev.mem", code, configuration)
        self.init_mems.append(self.PC)
        self.init_mems.append(self.PC_prev)

        self.DO = Default_Offset("DO.mem", configuration)
        self.init_mems.append(self.DO)

        self.BD = Branch_Detector(self.BDO, code, configuration)
        self.PO = Programmed_Offset(data, configuration)

        # Now all Code and Data have been resolved and generated
        # We can now create the Data and Instruction Memories

        self.A = Data_Memory("A.mem", "A", data, code, configuration)
        self.B = Data_Memory("B.mem", "B", data, code, configuration)
        self.init_mems.append(self.A)
        self.init_mems.append(self.B)

        self.I = Instruction_Memory("I.mem", code, configuration)
        self.init_mems.append(self.I)

    def generate (self, mem_obj_list = None):
        if mem_obj_list is None:
            mem_obj_list = self.init_mems
        for mem in mem_obj_list:
            mem.file_dump()

