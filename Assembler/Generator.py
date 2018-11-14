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

# ---------------------------------------------------------------------------

class Data_Memory (Base_Memory):
    """Create the contents of a Data Memory referenced by an instruction read/write operands.        This is essentially part of the combined register file/memory.
       Replicates private variables for each thread."""

    def write_bits (self, address, value):
        # Oh, this is ugly. BitArray left-justifies the bits!?!, so shift it back.
        position = self.width - value.length
        self.mem[address].overwrite(value,position)

    def write_variables (self, variables, offset = 0):
        """Place the variable values in memory, with optional thread offset, and handling lists of values (arrays)."""
        for variable in variables:
            address = variable.address + offset
            value   = variable.value
            if type(value) is list:
                for entry in value:
                    entry = BitArray(uint=entry, length=self.width)
                    self.write_bits(address, entry)
                    address += 1
            else:
                # ECL FIXME
                # This should never happen, but let's allow it for now until
                # we have the final variable resolutions done. (init data for init loads)
                if value is None:
                    value = 0xDEADBEEF
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
        # Dump the private variables once per thread at its default offset
        threads = code.threads
        offsets = configuration.default_offset.offsets
        for thread in threads:
            offset = offsets[thread]
            self.write_variables(private_variables, offset)

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

class Programmed_Offset (Base_Memory):
    """Calculates the run-time offset applied by the CPU to accesses at indirect memory locations.
       The offset is applied, then incremented by some constant."""

    # Contrary to Default Offset, the offset length matters here, since other
    # data follows it in the upper bits.
    po_offset_bits_A        = 10
    po_offset_bits_B        = 10
    po_offset_bits_DA       = 12
    po_offset_bits_DB       = 12

    # These must match the Verilog parameters
    po_entries              = 4
    po_increment_bits       = 4
    po_increment_sign_bits  = 1

    def __init__(self, filename, target_mem_obj, offset_width, memmap_obj, thread_obj):
        self.memmap_obj     = memmap_obj
        self.target_mem_obj = target_mem_obj
        self.offset_width   = offset_width
        self.total_width    = self.po_increment_sign_bits + self.po_increment_bits + self.offset_width
        depth               = thread_obj.count * self.po_entries
        Base_Memory.__init__(self, depth, self.total_width, filename)

    def gen_po(self, po_entry, target_address, increment):
        po_address      = self.memmap_obj.indirect[po_entry]
        offset          = target_address - po_address
        if increment >= 0:
            sign = 0
        else:
            sign = 1
        sign        = BitArray(uint=sign,      length=self.po_increment_sign_bits)
        increment   = BitArray(uint=increment, length=self.po_increment_bits)
        offset      = BitArray(uint=offset,    length=self.offset_width)
        po          = BitArray()
        for field in [sign, increment, offset]:
            po.append(field)
        # A programmed offset is only correct in a given PO entry
        return (po_entry, po)

    def gen_read_po(self, po_entry, target_name, increment):
        target_address  = self.target_mem_obj.lookup_read(target_name)
        return self.gen_po(po_entry, target_address, increment)

    def gen_write_po(self, po_entry, target_name, increment):
        target_address  = self.target_mem_obj.lookup_write(target_name)
        return self.gen_po(po_entry, target_address, increment)

    def load (self, thread, po_entry, po):
        if po_entry not in range(self.po_entries):
            print("Out of bounds PO entry: {0}".format(entry))
            sys.exit(1)
        address = po_entry + (thread * self.po_entries)
        self.mem[address] = po;

# ---------------------------------------------------------------------------
# Opcode Decoder Memory: translate opcode into ALU control bits

class Opcode_Decoder(Base_Memory):

    def __init__(self, filename, dyadic_obj, triadic_obj, thread_obj):
        self.opcode_count = 16
        self.dyadic     = dyadic_obj
        self.triadic    = triadic_obj
        width           = self.triadic.control_width
        depth           = self.opcode_count * thread_obj.count
        Base_Memory.__init__(self, depth, width, filename)
        self.opcodes    = {} # {name:bits}
        self.opcodes_here = [-1 for thread in thread_obj.all]
        self.alu_control_format = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5},uint:{6},uint:{7}'.format(self.triadic.split_width, self.triadic.shift_width, self.triadic.dyadic3_width, self.triadic.addsub_width, self.triadic.dual_width, self.triadic.dyadic2_width, self.triadic.dyadic1_width, self.triadic.select_width)


    def define (self, label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        """Assembles and names the control bits of an instruction. Shared amongst all threads."""
        control_bits = BitArray()
        for entry in [split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select]:
            field_bits = getattr(self.dyadic, entry, None)
            field_bits = getattr(self.triadic, entry, field_bits)
            if field_bits is None:
                print("Unknown opcode field value: {0}".format(entry))
                exit(1)
            control_bits.append(field_bits)
        self.opcodes.update({label:control_bits})

    def load (self, thread, name, opcode = None):
        """Assigne a per-thread opcode to a previously defined instruction.
           The opcode indexes into the opcode decoder memory, separately for each thread."""
        if opcode is None:
            self.opcode_here[thread] += 1
            opcode = self.opcode_here[thread]
        if opcode not in range(self.opcode_count):
            print("Opcode {0} load out of range in thread {1}".format(name, thread))
            sys.exit(-1)
        address = (thread * self.opcode_count) + opcode
        self.mem[address] = self.opcodes[name]

    def lookup_control (self, name):
        return self.opcodes[name]

    def lookup_opcode (self, thread, name):
        """Returns the per-thread opcode matching that name."""
        control_bits = self.lookup_control(name)
        op_zero = (thread * self.opcode_count)
        for opcode in range(op_zero, op_zero + self.opcode_count):
            if self.mem[opcode] == control_bits:
                return opcode - op_zero
        print("Could not find opcode named {0} in thread {1}".format(name, thread))
        sys.exit(1)
    
# ---------------------------------------------------------------------------

class Instruction_Memory(Base_Memory):

    simple_instr_format = 'uint:4,uint:12,uint:10,uint:10'
    dual_instr_format   = 'uint:4,uint:6,uint:6,uint:10,uint:10'

    def __init__(self, depth, width, filename, A_mem_obj, B_mem_obj, opcode_obj):
        Base_Memory.__init__(self, depth, width, filename)
        self.A_mem_obj      = A_mem_obj
        self.B_mem_obj      = B_mem_obj
        self.opcode_obj     = opcode_obj
        self.write_mem_list = [self.A_mem_obj, self.B_mem_obj, self]
        self.here           = -1
        self.names          = {}

    def literal_instruction (self, instruction, name = None):
        """Place an instruction in the next Instruction Memory location."""
        if type(instruction) != type(BitArray()):
            printf("Instruction not a BitArray: {0}".format(instruction))
            sys.exit(1)
        self.here += 1
        address = self.here
        if address not in range(self.depth):
            print("ERROR: Out of bounds instruction memory address ({0}) assignment in {1}".format(address, self.__name__))
            sys.exit(1)
        if name is not None:
            self.names.update({name:address})
        # Oh, this is ugly. BitArray's LSB is our MSB...
        self.mem[address].overwrite(instruction,(self.width-instruction.length))

    def lookup(self, name):
        if type(name) == type(int):
            return name
        address = self.names.get(name, None)
        return address

    def lookup_write(self, name):
        """Lookup the write address of a name across the listed writable memories."""
        if type(name) == type(int):
            return name
        addresses = []
        for entry in self.write_mem_list:
            address = entry.lookup_write(name)
            if address is not None:
                addresses.append(address)
        if len(addresses) > 1:
            print("ERROR: Cannot resolve multiple identical write names {0} with addresses {1}".format(name, addresses))
            sys.exit(1)
        if len(addresses) == 0:
            print("ERROR: No write name {0} found.".format(name))
            sys.exit(1)
        return addresses[0]

    def simple(self, op_name, dest, src1, src2, name = None):
        """Assemble a simple instruction"""
        op = self.opcode_obj.lookup_opcode(op_name)
        D_operand = self.lookup_write(dest)
        A_operand = self.A_mem_obj.lookup_read(src1)
        B_operand = self.B_mem_obj.lookup_read(src2)
        print([op, D_operand, A_operand, B_operand])
        instr = pack(self.simple_instr_format, op, D_operand, A_operand, B_operand)
        self.literal_instruction(instr, name)

    def dual(self, op_name, dest1, dest2, src1, src2, name = None):
        """Assemble a dual instruction (split addressing mode)
           The CPU re-adds the correct write offset after it decodes the instruction
           It's a power-of-2 alignment, so it just prepends the right value"""
        op = self.opcode_obj.lookup_opcode(op_name)
        DA_operand = self.A_mem_obj.lookup_write(dest1) - self.A_mem_obj.write_base
        DB_operand = self.B_mem_obj.lookup_write(dest2) - self.B_mem_obj.write_base
        A_operand  = self.A_mem_obj.lookup_read(src1)
        B_operand  = self.B_mem_obj.lookup_read(src2)
        instr = pack(self.dual_instr_format, op, DA_operand, DB_operand, A_operand, B_operand)
        self.literal_instruction(instr, name)

# ---------------------------------------------------------------------------

class Branch_Detector:

    def __init__(self, a_mem_obj, b_mem_obj, instr_mem_obj, branch_detect_obj, dyadic_obj):
        self.conditions          = {} # {name:bits}
        self.unresolved_branches = [] # list of parameters to br()
        self.a_mem_obj           = a_mem_obj
        self.b_mem_obj           = b_mem_obj
        self.instr_mem_obj       = instr_mem_obj
        self.branch_detect_obj   = branch_detect_obj
        self.dyadic_obj          = dyadic_obj
        branch_count             = 4
        condition_format         = 'uint:{0},uint:{1},uint:{2}'.format(self.branch_detect_obj.a_width, self.branch_detect_obj.b_width, self.branch_detect_obj.ab_operator_width)
        branch_format            = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5}'.format(self.branch_detect_obj.origin_width, self.branch_detect_obj.origin_enable_width, self.branch_detect_obj.destination_width, self.branch_detect_obj.predict_taken_width, self.branch_detect_obj.predict_enable_width, self.branch_detect_obj.condition_width)


    def condition (self, label, a, b, ab_operator):
        condition_bits = BitArray()
        for entry in [a, b, ab_operator]:
            field_bits = getattr(self.dyadic_obj, entry, None)
            field_bits = getattr(self.branch_detect_obj, entry, field_bits)
            if field_bits is None:
                print("Unknown branch field value: {0}".format(entry))
                exit(1)
            condition_bits.append(field_bits)
        self.conditions.update({label:condition_bits}) 

    def assemble_branch(self, origin, origin_enable, destination, predict_taken, predict_enable, condition_name):
        condition_bits      = self.conditions[condition_name]
        origin_bits         = BitArray(uint=origin, length=self.branch_detect_obj.origin_width)
        destination_bits    = BitArray(uint=destination, length=self.branch_detect_obj.destination_width)
        config = BitArray()
        for entry in [origin_bits, origin_enable, destination_bits, predict_taken, predict_enable, condition_bits]:
            config.append(entry)
        return config

#    def bt(self, destination):
#        thread = self.thread_obj.current
#        self.instr_mem_obj.loc(destination, write_addr = self.instr_mem_obj.here[thread])

    def load_branch(self, condition_bits, destination, predict, storage, origin_enable = True, origin = None):
        if origin is None:
            origin = self.instr_mem_obj.here
        dest_addr = self.instr_mem_obj.lookup(destination)
        if dest_addr is None:
            self.unresolved_branches.append([condition_bits, destination, predict, storage, origin_enable, origin])    
            return
        if predict is True:
            predict         = self.branch_detect_obj.predict_taken
            predict_enable  = self.branch_detect_obj.predict_enabled
        elif predict is False:
            predict         = self.branch_detect_obj.predict_not_taken
            predict_enable  = self.branch_detect_obj.predict_enabled
        elif predict is None:
            predict         = self.branch_detect_obj.predict_not_taken
            predict_enable  = self.branch_detect_obj.predict_disabled
        else:
            print("Invalid branch prediction setting {0} on branch {1}.".format(predict, storage))
            sys.exit(1)
        if origin_enable is True:
            origin_enable = self.branch_detect_obj.origin_enabled
        elif origin_enabled is False:
            origin_enable = self.branch_detect_obj.origin_disabled
        else:
            print("Invalid branch origin enabled setting {0} on branch{1}.".format(origin_enable, storage))
            sys.exit(1)
        branch_config = self.branch_detect_obj(origin, origin_enable, dest_addr, predict, predict_enable, condition_bits)
        # Works because a loc() usually sets both read/write addresses
        # and the read address is the local, absolute location in memory
        # (write address is offset to the global memory map)
        if (storage in self.a_mem_obj.write_names[thread]):
            address = self.a_mem_obj.read_names[thread][storage]
            offset = self.thread_obj.default_offset[thread]
            self.a_mem_obj.mem[address+offset] = branch_config
        elif (storage in self.b_mem_obj.write_names[thread]):
            address = self.b_mem_obj.read_names[thread][storage]
            offset = self.thread_obj.default_offset[thread]
            self.b_mem_obj.mem[address+offset] = branch_config
        else:
            print("Invalid storage location on branch: {0}.".format(storage))
            sys.exit(1)

    def resolve_forward_branches(self):
        for entry in self.unresolved_branches:
            self.br(*entry)

# ---------------------------------------------------------------------------
# Program Counter, current and previous

class Program_Counter(Base_Memory):

    pc_width = 10
    pc_format = 'uint:{0}'.format(pc_width)

    def __init__(self, filename, thread_obj):
        self.thread_obj = thread_obj
        depth           = self.thread_obj.count
        width           = self.pc_width
        Base_Memory.__init__(self, depth, width, filename)
        self.start      = [None for i in range(self.thread_obj.count)]

    def set (self, pc_value):
        thread = self.thread_obj.current
        self.start[thread]  = pc_value
        self.mem[thread]    = BitArray(uint=self.start[thread], length=self.mem[0].length);

# ---------------------------------------------------------------------------

class Generator (Debug):
    """Converts the resolved code/data/branch/etc... information into binary machine code."""

    def __init__ (self, data, code, configuration):

        self.Dyadic  = Dyadic_Operators()
        self.Triadic = Triadic_ALU_Operators(self.Dyadic)
        self.BDO     = Branch_Detector_Operators(self.Dyadic)

        self.DO = Default_Offset("DO.mem", configuration)

        self.A = Data_Memory("A.mem", "A", data, code, configuration)
        self.B = Data_Memory("B.mem", "B", data, code, configuration)

        # self.OD = Opcode_Decoder("OD.mem", self.Dyadic, self.Triadic, self.T)

        # self.I = Instruction_Memory(self.MM.depth, self.MM.width, "I.mem", self.A, self.B, self.OD)

        # self.BD = Branch_Detector(self.A, self.B, self.I, self.BDO, self.Dyadic)

        # self.PC      = Program_Counter("PC.mem", self.T)
        # self.PC_prev = Program_Counter("PC_prev.mem", self.T)

        # self.PO_A  = Programmed_Offset("PO_A.mem",  self.A, Programmed_Offset.po_offset_bits_A, self.MM, self.T)
        # self.PO_B  = Programmed_Offset("PO_B.mem",  self.B, Programmed_Offset.po_offset_bits_B, self.MM, self.T)
        # self.PO_DA = Programmed_Offset("PO_DA.mem", self.A, Programmed_Offset.po_offset_bits_DA, self.MM, self.T)
        # self.PO_DB = Programmed_Offset("PO_DB.mem", self.B, Programmed_Offset.po_offset_bits_DB, self.MM, self.T)

        # self.initializable_memories = [self.A, self.B, self.I, self.OD, self.DO, self.PO_A, self.PO_B, self.PO_DA, self.PO_DB, self.PC, self.PC_prev]
        self.initializable_memories = [self.DO, self.A, self.B]

    def generate (self, mem_obj_list = None):
        if mem_obj_list is None:
            mem_obj_list = self.initializable_memories
        for mem in mem_obj_list:
            mem.file_dump()


