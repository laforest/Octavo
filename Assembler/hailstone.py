#! /usr/bin/python

from Assembler import *

bench_dir  = "Hailstone"
bench_file = "hailstone"
bench_name = bench_dir + "/" + bench_file
SIMD_bench_name = bench_dir + "/" + "SIMD_" + bench_file

def partition_data_memory(memory_depth = 1024, literal_pool_depth = 32, thread_count = 8):
    thread_data_memory_depth = memory_depth - literal_pool_depth;
    offsets = [(thread * (thread_data_memory_depth / 8)) + literal_pool_depth for thread in range(0,thread_count)]
    return offsets

# We don't have programmed offsets, so we can modify them to reach a literal
# pool, I/O or H mem. For now, the tesbench will have to run "blind", with
# private data, and we'll check it's internal state for correct operation.

offsets = partition_data_memory(literal_pool_depth = 0)

def assemble_PC():
    PC = PC_Memory(bench_name + ".PC", depth = 8, width = 20, word_width = 10)
    # Shared code. All starts at the same place, matching thread 0 for simplicity.
    PC.L(PC.pack2(1,1)), PC.N("THREAD0_START")
    PC.L(PC.pack2(1,1)), PC.N("THREAD1_START")
    PC.L(PC.pack2(1,1)), PC.N("THREAD2_START")
    PC.L(PC.pack2(1,1)), PC.N("THREAD3_START")
    PC.L(PC.pack2(1,1)), PC.N("THREAD4_START")
    PC.L(PC.pack2(1,1)), PC.N("THREAD5_START")
    PC.L(PC.pack2(1,1)), PC.N("THREAD6_START")
    PC.L(PC.pack2(1,1)), PC.N("THREAD7_START")
    return PC

def assemble_A():
    A = Data_Memory(bench_name + ".A")
    A.add_port_pair("READ_PORT", "WRITE_PORT", 1023)
    # Peel out zeroth iteration for naming
    A.ALIGN(offsets[0])
    A.L(0),                 A.N("zero")
    A.L(1),                 A.N("one")
    A.L(3),                 A.N("three")
    A.L(2**(A.width-1)),    A.N("right_shift_1")
    A.L(0),                 A.N("temp")
    # All other iterations implicitly use the same names via offsets
    for thread in range(1,8):
        A.ALIGN(offsets[thread])
        A.L(0)             
        A.L(1)             
        A.L(3)             
        A.L(2**(A.width-1))
        A.L(0)             
    return A

def assemble_B():
    B = Data_Memory(bench_name + ".B", write_offset = 1024)
    B.add_port_pair("READ_PORT", "WRITE_PORT", 1023)

    seeds = [27, 47, 67, 87, 107, 127, 234, 335]

    # Peel out zeroth iteration for naming
    B.ALIGN(offsets[0])
    B.L(0),         B.N("zero")
    B.L(seeds[0]),  B.N("seed")
    # All other iterations implicitly use the same names via offsets
    for thread,seed in zip(range(1,8),seeds[1:]):
        B.ALIGN(offsets[thread])
        B.L(0)
        B.L(seed)
    return B

def assemble_I(PC, A, B):
    I = Instruction_Memory(bench_name + ".I", write_offset = 2048)
    I.NOP()

    I.ALIGN(PC.get_pc("THREAD0_START"))
    # Is the seed odd?
    I.I(AND, (A,"temp"), (A,"one"), (B,"seed")),   I.N("hailstone")
    I.I(JNZ, 0, (A,"temp"), 0),                    I.N("odd")
    # Even: seed = seed / 2
    I.I(MHU, (B,"seed"), (A,"right_shift_1"), (B,"seed"))
    I.I(JMP, 0, 0, 0),                             I.N("output")
    # Odd: seed = (3 * seed) + 1
    I.I(MLS, (B,"seed"), (A,"three"), (B,"seed")), I.RD("odd")
    I.I(ADD, (B,"seed"), (A,"one"), (B,"seed"))
    # placeholder, as we are running "blind"
    I.I(XOR, 0, 0, 0),                             I.RD("output")
    # I.I(ADD, (A,"WRITE_PORT"), 0, (B,seed)),   I.RD("output")
    #I.I(ADD, (B,"WRITE_PORT"), 0, (B,seed))
    I.I(JMP, "hailstone", 0, 0)
    return I

def assemble_DOFF():
    DOFF = Memory(bench_name + ".DOFF", depth = 8, width = 10)
    for offset in offsets:
        DOFF.L(offset)
    return DOFF

def assemble_all():
    PC = assemble_PC()
    A  = assemble_A()
    B  = assemble_B()
    I  = assemble_I(PC, A, B)
    DOFF = assemble_DOFF()

    PC.file_dump()

    A.file_dump()
    A.file_name = SIMD_bench_name + ".A"
    A.file_dump()

    B.file_dump()
    B.file_name = SIMD_bench_name + ".B"
    B.file_dump()

    I.file_dump()

    DOFF.file_dump()

if __name__ == "__main__":
    assemble_all()

