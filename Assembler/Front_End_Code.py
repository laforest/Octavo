
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

    def __init__ (self, front_end_data, front_end_code, label = None, destination = None,):
        self.label          = label
        self.destination    = destination
        self.instructions   = []
        self.init_data      = []
        self.front_end_data = front_end_data
        # keep any init instructions added later in order, so add list of init instructions
        front_end_code.instructions.append(self.instructions)

    def add_variable (self, label):
        """Adds data for an initialization load. Order not important. Referenced by label."""
        new_init_data = self.front_end_data.allocate_variable(label)
        self.init_data.append(new_init_data)

    def add_constant (self, label):
        """Adds data for an initialization load. Order not important. Referenced by label."""
        new_init_data = self.front_end_data.allocate_constant(label)
        self.init_data.append(new_init_data)

    def add_instruction (self, label):
        """Adds an instruction to initialization load. Remains in sequence added."""
        new_instruction = Instruction(label = label, opcode = "add")
        self.instructions.append(new_instruction)


class Front_End_Code:
    """Parses the code, which drives the resolution of unknowns about the data."""

    def __init__ (self, back_end, front_end_data):
        self.back_end       = back_end
        self.front_end_data = front_end_data
        self.init_loads   = []
        self.instructions   = []
        self.opcodes        = []
        self.conditions     = []
        self.threads        = []

    def set_current_threads (self, thread_list):
        self.threads = thread_list

    def allocate_init_load (self, label, destination):
        new_init_load = Initialization_Load(self.front_end_data, self, label = label, destination = destination)
        self.init_loads.append(new_init_load)

    def allocate_opcode (self, label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select):
        new_opcode = Opcode(label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select)
        self.opcodes.append(new_opcode)
        return new_opcode
        # self.back_end.OD.define(label, split, shift, dyadic3, addsub, dual, dyadic2, dyadic1, select) 
        
    def allocate_condition (self, label, a, b, ab_operator):
        new_condition = Condition(label, a, b, ab_operator)
        self.conditions.append(new_condition)
        return new_condition
        # self.back_end.BD.condition(label, a, b, ab_operator)

    def lookup_opcode (self, label):
        for opcode in self.opcodes:
            if opcode.label == label:
                return opcode
        print("Opcode {0} not found".format(label))
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
        
