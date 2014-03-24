#! /usr/bin/python

from opcodes import *
from branching_flags import *

class Memory:
    """A basic Memory capable of assembling literals, naming locations, and dumping its contents into a format $readmemh can use."""

    def width_mask(self, width):
        return (1 << width) - 1

    def dump_format(self):
        """Numbers must be represented as zero-padded whole hex numbers"""
        characters = self.width // 4
        remainder = self.width % 4
        characters += min(1, remainder)
        format_string = "{:0" + str(characters) + "x}"
        return format_string

    #def find_unresolved(self, names):
    #    unresolved = [key for key, value in self.names.items() if value is None]
    #    assert len(unresolved) == 0,  "ERROR: Unresolved references in {0}?: {1}".format(self.__class__.__name__, unresolved)   

    def file_dump(self, begin = 0, end = 0, file_name = "", file_ext = ""):
        """Allows dumping a slice of memory."""
        if end == 0:
            end = self.depth
        if file_name == "":
            file_name = self.file_name
        if file_ext == "":
            file_ext = self.file_ext
    #    self.find_unresolved(self.read_names)
    #    self.find_unresolved(self.write_names)
        with open(file_name + file_ext, 'w') as f:
            f.write(self.file_header + "\n")
            format_string = self.dump_format()
            for entry in self.data[begin:end]:
                output = format_string.format(entry)
                f.write(output + "\n")

    def A(self, addr):
        """Continue assembling at new address. Assumes pre-incr 'here'"""
        self.here = addr - 1

    def P(self, name, read_addr, write_addr = None):
        """Name a given location. Useful for ports and other mem-mapped hardware."""
        if write_addr is None:
            write_addr = read_addr + self.write_offset
        self.read_names.update({name:read_addr})
        self.write_names.update({name:write_addr})

    def N(self, name, write_addr = None):
        """Name current location. Must place after L or I, which pre-increment 'here'."""
        self.P(name, self.here, write_addr)

    def R(self, name):
        """Shortcut to resolve local names into READ addresses, with special case handling."""
        if type(name) == type(int()):
            return name
        return self.read_names.get(name, None)

    def W(self, name):
        """Shortcut to resolve local names into WRITE addresses, with special case handling."""
        if type(name) == type(int()):
            return name
        return self.write_names.get(name, None)

    def RL(self, name):
        """Resolve Literal: set named location to current READ address"""
        address = self.read_names[name]
        self.data[address] = self.here

    def WL(self, name):
        """Resolve Literal: set named location to current WRITE address"""
        address = self.write_names[name]
        self.data[address] = self.here

    def L(self, number):
        """Assemble a literal number"""
        self.here += 1
        self.data[self.here] = number & self.mask

    def C(self, character):
        """Assemble a character, one per word"""
        self.L(ord(character))

    def __init__(self, file_name, file_ext = ".MEM", depth = 1024, width = 36, write_offset = 0):
        self.file_name    = file_name
        self.file_ext     = file_ext
        self.depth        = depth
        self.width        = width
        self.write_offset = write_offset
        self.mask         = self.width_mask(self.width)
        self.data         = [(0 & self.mask)] * self.depth
        self.read_names   = {}
        # Write names must be globaly unique.
        self.write_names  = {}
        self.here         = -1
        # Lifted from Modelsim's output of $writememh
        self.file_header  = """// format=hex addressradix=h dataradix=h version=1.0 wordsperline=1 noaddress"""



class Instruction_Memory(Memory):
    """Extends Memory to assemble instructions. Requires a reference to the memories addressed by the operands, to resolve read/write addresses."""

    def lookup_write(self, dest, mem_list):
        if type(dest) == type(int()):
            return dest
        mem_pairs = [mem.write_names.items() for mem in mem_list]
        pairs = []
        for sublist in mem_pairs:
            for pair in sublist:
                pairs.append(pair)
        valid_pairs = [(name, addr) for name, addr in pairs if name == dest and addr is not None] 
        assert len(valid_pairs) > 0,   "ERROR: Cannot resolve undefined write name: {0}".format(dest)   
        assert len(valid_pairs) == 1,  "ERROR: Cannot resolve multiple identical write names: {0}".format(valid_pairs)   
        name, addr = valid_pairs[0]
        return addr

    def lookup_read(self, src, mem):
        addr = mem.R(src)
        assert addr is not None, "ERROR: Name {0} does not exist in {1}".format(src, mem.__class__.__name__)
        return addr

    def I(self, op, dest, src1, src2):
        """Assemble an instruction"""
        mem_list = [self.A_mem] + [self.B_mem] + self.other_mem
        D = self.lookup_write(dest, mem_list)
        S1 = self.lookup_read(src1, self.A_mem)
        S2 = self.lookup_read(src2, self.B_mem)
        instr  = ((op & self.op_mask  ) << self.op_shift  ) 
        instr |= ((D  & self.dest_mask) << self.dest_shift) 
        instr |= ((S1 & self.src1_mask) << self.src1_shift) 
        instr |= ((S2 & self.src2_mask) << self.src2_shift)
        self.L(instr)

    def branch_entry(self, origin, target, storage, condition, predict_taken):
        destination = self.R(target) 
        if destination is None:
            self.unresolved_jumps.append([origin, target, storage, condition, predict_taken])
            return 0
        # ECL XXX we should mask these...
        destination = destination << 10
        condition   = condition   << 20
        prediction_settings = {
            True:  (1,1),
            False: (0,1),
            None:  (0,0)
        }
        prediction, prediction_enable = prediction_settings[predict_taken]
        prediction        = prediction        << 23 
        prediction_enable = prediction_enable << 24
        return (prediction_enable | prediction | condition | destination | origin)

    def resolve_forward_jumps(self):
        while len(self.unresolved_jumps) > 0:
            jump = self.unresolved_jumps.pop()
            origin, target, storage, condition, predict_taken = jump
            entry = self.branch_entry(origin, target, storage, condition, predict_taken)
            self.A_mem.A(self.A_mem.R(storage))
            self.A_mem.L(entry)
        assert len(self.unresolved_jumps) == 0, "ERROR: Unresolvable jump(s)!: {0}".format(self.unresolved_jumps)
        
    def JMP(self, target, storage):
        entry = self.branch_entry(self.here, target, storage, JMP, None)
        # ECL XXX Storing in A mem as convention for now
        self.A_mem.A(self.A_mem.R(storage))
        self.A_mem.L(entry)

    def JZE(self, target, predict_taken, storage):
        entry = self.branch_entry(self.here, target, storage, JZE, predict_taken)
        self.A_mem.A(self.A_mem.R(storage))
        self.A_mem.L(entry)

    def JNZ(self, target, predict_taken, storage):
        entry = self.branch_entry(self.here, target, storage, JNZ, predict_taken)
        self.A_mem.A(self.A_mem.R(storage))
        self.A_mem.L(entry)

    def JPO(self, target, predict_taken, storage):
        entry = self.branch_entry(self.here, target, storage, JPO, predict_taken)
        self.A_mem.A(self.A_mem.R(storage))
        self.A_mem.L(entry)

    def JNE(self, target, predict_taken, storage):
        entry = self.branch_entry(self.here, target, storage, JNE, predict_taken)
        self.A_mem.A(self.A_mem.R(storage))
        self.A_mem.L(entry)

    def JEV(self, target, predict_taken, storage):
        entry = self.branch_entry(self.here, target, storage, JEV, predict_taken)
        self.A_mem.A(self.A_mem.R(storage))
        self.A_mem.L(entry)

    # Never change this encoding. NOP must be all zero, and zero-out location 0
    def NOP(self):
        self.I(XOR, 0, 0, 0)

    def __init__(self, file_name, A_mem, B_mem, other_mem = [], file_ext = ".I", depth = 1024, width = 36, op_width = 4, dest_width = 12, src1_width = 10, src2_width = 10, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)
        self.op_width       = op_width
        self.dest_width     = dest_width
        self.src1_width     = src1_width
        self.src2_width     = src2_width
        self.instr_width    = op_width + dest_width + src1_width + src2_width

        assert self.instr_width <= self.width, "ERROR: Instruction width {0} greater than Memory word width {1}".format(self.instr_width, self.width)

        self.src2_shift     = 0
        self.src1_shift     = src1_width
        self.dest_shift     = self.src1_shift + src2_width
        self.op_shift       = self.dest_shift + dest_width

        self.op_mask        = self.width_mask(op_width)
        self.dest_mask      = self.width_mask(dest_width)
        self.src1_mask      = self.width_mask(src1_width)
        self.src2_mask      = self.width_mask(src2_width)

        # List of all other memories addressed in instructions
        self.A_mem          = A_mem
        self.B_mem          = B_mem
        self.other_mem      = other_mem

        # List of unresolved jumps, to fix-up at the end
        self.unresolved_jumps = []



class PC_Memory(Memory):
    "Program Counter Memory. Packs two words per Memory word."

    def pack2(self, msw, lsw):
        upper =  ((msw & self.word_mask) << self.word_width) 
        lower =   (lsw & self.word_mask) 
        return (upper | lower) & self.mask

    def set_pc(self, pc, name):
        # next and current PCs, both the same at assemble-time
        self.L(self.pack2(pc, pc)), self.N(name)

    def get_pc(self, name):
        # We don't use the write names, as only branches change the PC
        addr = self.read_names[name]
        return self.data[addr] & self.word_mask

    def __init__(self, file_name, file_ext = ".PC", depth = 8, width = 20, write_offset = 0, word_width = 10):
        assert word_width > 0, "ERROR: Word width must be > 0 to pack anything into PC memory."
        assert (word_width * 2) <= width, "ERROR: Cannot pack two {1} bit words into a {2} bit memory word".format(word_width, width) 
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)
        self.word_width = word_width
        self.word_mask  = self.width_mask(word_width)


class Default_Offset_Memory(Memory):
    "Default offsets to add to A/B/D operands. One per thread."
    # Change extension to match: s/X/A/ for example.
    def __init__(self, file_name, file_ext = ".XDO", depth = 8, width = 10, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

class Programmed_Offset_Memory(Memory):
    "Programmed offsets to add to A/B/D operands. One per thread."
    # Change extension to match: s/X/A/ for example.
    def __init__(self, file_name, file_ext = ".XPO", depth = 8, width = 10, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

class Increments_Memory(Memory):
    "Increments to A/B/D Programmed Offsets after access. One per thread."
    # Change extension to match: s/X/A/ for example.
    def __init__(self, file_name, file_ext = ".XIN", depth = 8, width = 1, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)



class Branch_Origin_Memory(Memory):
    "Origin address of branches. One per thread min. Only one instance of this memory."
    def __init__(self, file_name, file_ext = ".BO", depth = 8, width = 10, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

class Branch_Destination_Memory(Memory):
    "Destination address of branches. One per thread min. Only one instance of this memory."
    def __init__(self, file_name, file_ext = ".BD", depth = 8, width = 10, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

class Branch_Condition_Memory(Memory):
    "Condition of branches. One per thread min. Only one instance of this memory."
    def __init__(self, file_name, file_ext = ".BC", depth = 8, width = 3, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

class Branch_Prediction_Memory(Memory):
    "Cancelling Branch prediction bit: 1 means Predict Taken. One per branch."
    def __init__(self, file_name, file_ext = ".BP", depth = 8, width = 1, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

class Branch_Prediction_Enable_Memory(Memory):
    "Cancelling Branch prediction enable: 1 means use Prediction bit, else never cancel. One per branch."
    def __init__(self, file_name, file_ext = ".BPE", depth = 8, width = 1, write_offset = 0):
        Memory.__init__(self, file_name, file_ext = file_ext, depth = depth, width = width, write_offset = write_offset)

