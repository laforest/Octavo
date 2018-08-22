#! /usr/bin/python3

"""
Takes parsed lines and drives the lower code generation objects.
"""

from sys import exit

class Command_Parser:
    """Interprets the parsed file as commands. Defines command syntax."""

    def __init__ (self):
        pass

    def next_command (self, lines, current_line = 0):
        line            = lines[current_line]
        line_start      = line.words[0]
        command_word    = line.words[1]
        # A command starts with a blank in front. Signals end of previous command.
        if line_start != None:
            print("Unexpected word {0} at start of line number {1} in file {2}".format(line_start, line.line_number, line.filename))
            print(line.raw_line)
            exit(1)
        # Commands are named the same as the implementing function
        command = getattr(self, command_word)
        print("FOUND COMMAND: {0}".format(command_word))
        current_line = command(lines, current_line)
        return current_line

    def parse_commands (self, lines, current_line = 0):
        for line in lines[current_line:]:
            current_line = self.next_command(lines, current_line)
            if current_line == len(lines):
                print("DONE PARSING")
                exit(0)

    def branches (self, lines, current_line):
        # skip command (no parameters to it)
        current_line += 1
        # process each branch condition definition
        for line in lines[current_line:]:
            # The first blank line start indicates the end of the parameters
            # and the start of the next command
            if line.words[0] == None:
                break
            condition_name, A_flag, B_flag, AB_operator = line.words
            print(condition_name, A_flag, B_flag, AB_operator)
            current_line += 1
        return current_line

    def opcodes (self, lines, current_line):
        # skip command (no parameters to it)
        current_line += 1
        # process each opcode definition
        for line in lines[current_line:]:
            # The first blank line start indicates the end of the parameters
            # and the start of the next command
            if line.words[0] == None:
                break
            opcode_name, split, shift, d3, addsub, dual, d2, d1, select  = line.words
            print(opcode_name, split, shift, d3, addsub, dual, d2, d1, select)
            current_line += 1
        return current_line

    def memory (self, lines, current_line):
        # To which memory will the follwing commands apply?
        memory_name = lines[current_line].words[2]
        print("FOUND memory {0}".format(memory_name))
        current_line += 1
        if memory_name == "A" or memory_name == "B":
            current_line = self.data_memory(lines, current_line)
        elif memory_name == "I":
            current_line = self.instruction_memory(lines, current_line)
        else:
            print("Unknown memory name {0}".format(memory_name))
            print(lines[current_line].raw_line)
            exit(1)
        return current_line

    def data_memory (self, lines, current_line):
        for line in lines[current_line:]:
            line_name       = line.words[0]
            line_command    = line.words[1]
            if line_name == None:
                if line_command == "thread":
                    threads = line.words[2:]
                    print("FOUND threads")
                    print(threads)
                if line_command == "pool":
                    print("FOUND pool")
                    pool_entry = line.words[2]
                    print(pool_entry)
                if line_command == "lit":
                    print("FOUND lit")
                    literals = line.words[2:]
                    print(literals)
                if line_command in ["ind", "apo", "bpo", "dapo", "dbpo"]:
                    print("Missing name for {0} command on line {1} in file {2}".format(line_command, line.line_number, line.filename))
                    exit(1) 
                if line_command == "memory":
                    break
                if line_command == "pc":
                    break
            else:
                if line_command == "pool":
                    print("FOUND pool {0}".format(line_name))
                    pool_entry = line.words[2]
                    print(pool_entry)
                if line_command == "lit":
                    print("FOUND lit {0}".format(line_name))
                    literals = line.words[2:]
                    print(literals)
                if line_command == "ind":
                    print("FOUND ind {0}".format(line_name))
                    ind_entry = line.words[2]
                    print(ind_entry)
                if line_command == "apo":
                    print("FOUND apo {0}".format(line_name))
                    apo_entry = line.words[2]
                    print(apo_entry)
                if line_command == "bpo":
                    print("FOUND bpo {0}".format(line_name))
                    bpo_entry = line.words[2]
                    print(bpo_entry)
                if line_command == "dapo":
                    print("FOUND dapo {0}".format(line_name))
                    dapo_entry = line.words[2]
                    print(dapo_entry)
                if line_command == "dbpo":
                    print("FOUND dbpo {0}".format(line_name))
                    dbpo_entry = line.words[2]
                    print(dbpo_entry)
                if line_command == "memory":
                    print("Unexpected name {0} before memory command at line {1} in file {2}".format(line_name, line.line_number, line.filename))
                    print(line.raw_line)
                    exit(1)
                if line_command == "pc":
                    print("Unexpected name {0} before pc command at line {1} in file {2}".format(line_name, line.line_number, line.filename))
                    print(line.raw_line)
                    exit(1)
            current_line += 1
        return current_line

    def instruction_memory (self, lines, current_line):
        for line in lines[current_line:]:
            # Get optional branch destination name, and the opcode and its arguments
            line_name       = line.words[0]
            line_opcode     = line.words[1]
            line_arguments  = line.words[2:4]
            if line_opcode == "program_counter":
                return current_line
            print("OPCODE")
            print(line_name, line_opcode, line_arguments)
            # If there is more, then it's one or more parallel branches
            length = len(line.words)
            if length > 5:
                current_word_index = 5
                while current_word_index < length:
                    branch_condition    = line.words[current_word_index    ]
                    branch_prediction   = line.words[current_word_index + 1]
                    branch_destination  = line.words[current_word_index + 2]
                    print("BRANCH")
                    print(branch_condition, branch_prediction, branch_destination)
                    current_word_index += 3
            current_line += 1
        return current_line 

    def program_counter (self, lines, current_line):
        line = lines[current_line]
        line_name = line.words[0]
        if line_name != None:
            print("Unexpected line name {0} at program_counter command at line {1} in file {2}".format(line_name, line.line_number, line.filename))
            print(line.raw_line)
            exit(1)
        # We already know line.words[1] is "program_counter", else we wouldn't be here.
        start_names = line.words[2:]
        print(start_names)
        current_line += 1
        return current_line
