#! /usr/bin/python3

from Memory import Memory
import Branch_Detector_Operators as Branch
from bitstring import pack,BitArray
from sys import exit

class Branch_Detector_Memory(Memory):
    """Extends Memory to assemble Branch Detector entries.
       Not used to dump an initialization memory image,
       but to define and return pre-defined branch definitions
       to a higher assembler."""

    def __init__(self, file_name, depth = 0, width = 0, write_offset = 0):
        assert width >= Branch.total_op_width, "ERROR: memory too narrow ({0} bits) to hold Branch Detector control bits in {1}".format(width, self.__class__.__name__)
        Memory.__init__(self, file_name, depth = depth, width = width, write_offset = write_offset)

        self.condition_format = 'uint:{0},uint:{1},uint:{2}'.format(Branch.A_flag_width, Branch.B_flag_width, Branch.AB_operator_width)
        self.branch_format = 'uint:{0},uint:{1},uint:{2},uint:{3},uint:{4},uint:{5}'.format(Branch.origin_width, Branch.origin_enable_width, Branch.destination_width, Branch.predict_taken_width, Branch.predict_enable_width, Branch.condition_width)

    def branch_condition(self, name, A_flag, B_flag, AB_operator):
        """Note we pack a smaller word in a bigger one. Slice it when reading back."""
        condition = BitArray()
        for entry in [A_flag, B_flag, AB_operator]:
            condition.append(entry)
        self.lit(condition.uint)
        self.loc(name)

    def branch(self, name, origin, origin_enable, destination, predict_taken, predict_enable, condition_name):
        condition = self.lookup(condition_name)
        # Slice out the extra bits
        extra_bits = self.width - Branch.condition_width
        condition = condition[extra_bits:]
        origin_bits = BitArray(uint=origin, length=Branch.origin_width)
        destination_bits = BitArray(uint=destination, length=Branch.destination_width)
        config = BitArray()
        for entry in [origin_bits, origin_enable, destination_bits, predict_taken, predict_enable, condition]:
            config.append(entry)
        self.lit(config.uint)
        self.loc(name)

    def file_dump(self, begin = 0, end = 0, file_name = ""):
        """Override class method to disable memory dumps."""
        print("ERROR: {0} cannot be used to create a memory dump.".format(self.__class__.__name__))
        exit()

if __name__ == "__main__":
    BDM = Branch_Detector_Memory("foobar.mem", depth = 4, width = Branch.total_op_width, write_offset = 300)
    BDM.branch_condition("LTE", Branch.A_flag_sentinel, Branch.B_flag_lessthan, Branch.Dyadic.a_or_b)
    BDM.branch("infinite", 123, Branch.origin_enabled, 456, Branch.predict_not_taken, Branch.predict_enabled, "LTE")
    print(BDM.condition_format)
    print(BDM.branch_format)
    print(BDM.lookup("LTE").bin)
    print(BDM.lookup("LTE").unpack(BDM.condition_format))
    print(BDM.lookup("infinite").bin)
    print(BDM.lookup("infinite").unpack(BDM.branch_format))

