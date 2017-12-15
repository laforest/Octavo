#! /usr/bin/python

from Memory import Memory
import Branch_Detector_Operators as BD
from sys import exit

class Branch_Detector_Memory(Memory):
    """Extends Memory to assemble Branch Detector entries.
       Not used to dump an initialization memory image,
       but to define and return pre-defined branch definitions
       to a higher assembler."""

    def __init__(self, file_name, depth = 0, width = 0, write_offset = 0):
        assert width >= BD.total_op_width, "ERROR: memory too narrow ({0} bits) to hold Branch Detector control bits in {1}".format(width, self.__class__.__name__)
        Memory.__init__(self, file_name, depth = depth, width = width, write_offset = write_offset)

        self.AB_operator_shift      = 0
        self.B_flag_shift           = self.AB_operator_shift    + BD.AB_operator_width
        self.A_flag_shift           = self.B_flag_shift         + BD.B_flag_width
        self.condition_shift        = 0
        self.predict_enable_shift   = self.condition_shift      + BD.condition_width
        self.predict_taken_shift    = self.predict_enable_shift + BD.predict_enable_width
        self.destination_shift      = self.predict_taken_shift  + BD.predict_taken_width
        self.origin_enable_shift    = self.destination_shift    + BD.destination_width
        self.origin_shift           = self.origin_enable_shift  + BD.origin_enable_width

        self.AB_operator_mask       = self.width_mask(BD.AB_operator_width)
        self.B_flag_mask            = self.width_mask(BD.B_flag_width)
        self.A_flag_mask            = self.width_mask(BD.A_flag_width)
        self.condition_mask         = self.width_mask(BD.condition_width)
        self.predict_enable_mask    = self.width_mask(BD.predict_enable_width)
        self.predict_taken_mask     = self.width_mask(BD.predict_taken_width)
        self.destination_mask       = self.width_mask(BD.destination_width)
        self.origin_enable_mask     = self.width_mask(BD.origin_enable_width)
        self.origin_mask            = self.width_mask(BD.origin_width)

    def branch_condition(self, name, A_flag, B_flag, AB_operator):
        condition  = (AB_operator & self.AB_operator_mask) << AB_operator_shift
        condition |= (B_flag      & self.B_flag_mask)      << B_flag_shift
        condition |= (A_flag      & self.A_flag_mask)      << A_flag_shift 
        self.lit(condition)
        self.loc(name)

    def branch(self, name, origin, origin_enable, destination, predict_taken, predict_enable, condition_name):
        condition = self.lookup(condition_name)
        config  = (condition      & self.condition_mask)      << self.condition_shift
        config |= (predict_enable & self.predict_enable_mask) << self.predict_enable_shift 
        config |= (predict_taken  & self.predict_taken_mask)  << self.predict_taken_shift
        config |= (destination    & self.destination_mask)    << self.destination_shift
        config |= (origin_enable  & self.origin_enable_mask)  << self.origin_enable_shift
        config |= (origin         & self.origin_mask)         << self.origin_shift
        self.lit(config)
        self.loc(name)

    def file_dump(self, begin = 0, end = 0, file_name = ""):
        """Override class method to disable memory dumps."""
        print "ERROR: {0} cannot be used to create a memory dump.".format(self.__class__.__name__)
        exit()

