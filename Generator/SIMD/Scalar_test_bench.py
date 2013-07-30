#! /usr/bin/python

import string
import os
import sys

import misc
import parameters_misc

default_bench = "hailstone_numbers"
install_base = misc.base_install_path()

def test_bench(parameters, default_bench = default_bench, install_base = install_base):
    assembler_base = os.path.join(install_base, "Assembler")
    test_bench_template = string.Template(
"""module ${CPU_NAME}_test_bench
#(
    parameter       A_WORD_WIDTH                = ${A_WORD_WIDTH},
    parameter       B_WORD_WIDTH                = ${B_WORD_WIDTH},
    parameter       SIMD_A_WORD_WIDTH           = ${SIMD_A_WORD_WIDTH},
    parameter       SIMD_B_WORD_WIDTH           = ${SIMD_B_WORD_WIDTH},

    parameter       A_IO_READ_PORT_COUNT        = ${A_IO_READ_PORT_COUNT},
    parameter       A_IO_WRITE_PORT_COUNT       = ${A_IO_WRITE_PORT_COUNT},
    parameter       SIMD_A_IO_READ_PORT_COUNT   = ${SIMD_A_IO_READ_PORT_COUNT},
    parameter       SIMD_A_IO_WRITE_PORT_COUNT  = ${SIMD_A_IO_WRITE_PORT_COUNT},

    parameter       B_IO_READ_PORT_COUNT        = ${B_IO_READ_PORT_COUNT},
    parameter       B_IO_WRITE_PORT_COUNT       = ${B_IO_WRITE_PORT_COUNT},
    parameter       SIMD_B_IO_READ_PORT_COUNT   = ${SIMD_B_IO_READ_PORT_COUNT},
    parameter       SIMD_B_IO_WRITE_PORT_COUNT  = ${SIMD_B_IO_WRITE_PORT_COUNT},

    parameter       SIMD_LANE_COUNT             = ${SIMD_LANE_COUNT},

    parameter       A_INIT_FILE                 = "${assembler_base}/${default_bench}.mem",
    parameter       B_INIT_FILE                 = "${assembler_base}/${default_bench}.mem",
    parameter       I_INIT_FILE                 = "${assembler_base}/${default_bench}.mem",
    parameter       PC_INIT_FILE                = "${assembler_base}/${default_bench}.pc",
    parameter       SIMD_A_INIT_FILE            = "${assembler_base}/${SIMD_MEM_INIT_FILE_PREFIX}${default_bench}.mem",
    parameter       SIMD_B_INIT_FILE            = "${assembler_base}/${SIMD_MEM_INIT_FILE_PREFIX}${default_bench}.mem"
)
(
    output  reg     [((A_WORD_WIDTH * A_IO_READ_PORT_COUNT)  + (SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT))-1:0] A_in,
    output  wire    [((               A_IO_READ_PORT_COUNT)  + (                    SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT))-1:0] A_rden,
    output  wire    [((A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT) + (SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT))-1:0] A_out, 
    output  wire    [((               A_IO_WRITE_PORT_COUNT) + (                    SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT))-1:0] A_wren,
    
    output  reg     [((B_WORD_WIDTH * B_IO_READ_PORT_COUNT)  + (SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT))-1:0] B_in,
    output  wire    [((               B_IO_READ_PORT_COUNT)  + (                    SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT))-1:0] B_rden,
    output  wire    [((B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT) + (SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT))-1:0] B_out, 
    output  wire    [((               B_IO_WRITE_PORT_COUNT) + (                    SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT))-1:0] B_wren    
);
    integer     cycle;
    reg         clock;
    reg         half_clock;

    initial begin
        cycle       = 0;
        clock       = 0;
        half_clock  = 0;
        A_in        = 0;
        B_in        = 0;
        `DELAY_CLOCK_CYCLES(1000) $$stop;
    end

    always begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        half_clock <= ~half_clock;
    end

    always @(posedge clock) begin
        cycle = cycle + 1;
    end

    always begin
        `DELAY_CLOCK_CYCLES(300)
        A_in        = -1;
        B_in        = -1;
        `DELAY_CLOCK_CYCLES(300)
        A_in        = 0;
        B_in        = 0;
        `DELAY_CLOCK_CYCLES(300)
        A_in        = -1;
        B_in        = -1;
    end

    localparam WREN_OTHER_DEFAULT = {(SIMD_LANE_COUNT+1){`HIGH}};
    localparam ALU_C_IN_DEFAULT   = {(SIMD_LANE_COUNT+1){`LOW}};

    ${CPU_NAME} 
    #(
        .A_INIT_FILE        (A_INIT_FILE),
        .B_INIT_FILE        (B_INIT_FILE),
        .I_INIT_FILE        (I_INIT_FILE),
        .PC_INIT_FILE       (PC_INIT_FILE),
        .SIMD_A_INIT_FILE   (SIMD_A_INIT_FILE),
        .SIMD_B_INIT_FILE   (SIMD_B_INIT_FILE)
    )
    DUT 
    (
        .clock              (clock),
        .half_clock         (half_clock),

        .I_wren_other       (`HIGH),
        .A_wren_other       (WREN_OTHER_DEFAULT),
        .B_wren_other       (WREN_OTHER_DEFAULT),

        .ALU_c_in           (ALU_C_IN_DEFAULT),
        .ALU_c_out          (),

        .A_in               (A_in),
        .A_rden             (A_rden),
        .A_out              (A_out),
        .A_wren             (A_wren),
        
        .B_in               (B_in),
        .B_rden             (B_rden),
        .B_out              (B_out),
        .B_wren             (B_wren)
    );
endmodule
""")
    parameters["default_bench"] = default_bench
    parameters["assembler_base"] = assembler_base
    return test_bench_template.substitute(parameters)

def test_bench_script(parameters, default_bench = default_bench, install_base = install_base):
    test_bench_script_template = string.Template(
"""#! /bin/bash

INSTALL_BASE="${install_base}"

TOP_LEVEL_MODULE="${CPU_NAME}_test_bench"
TESTBENCH="./$${TOP_LEVEL_MODULE}.v"

LPM_LIBRARY="/pkgs/altera/quartus/quartus12.0/linux/quartus/eda/sim_lib/220model.v"
ALT_LIBRARY="/pkgs/altera/quartus/quartus12.0/linux/quartus/eda/sim_lib/altera_mf.v"

OCTAVO="$$INSTALL_BASE/Octavo/Misc/params.v \\
        $$INSTALL_BASE/Octavo/Misc/delay_line.v \\
        $$INSTALL_BASE/Octavo/Memory/Memory.v \\
        $$INSTALL_BASE/Octavo/ControlPath/Instr_Decoder/Instr_Decoder.v \\
        $$INSTALL_BASE/Octavo/ControlPath/Controller/Controller.v \\
        $$INSTALL_BASE/Octavo/ControlPath/ControlPath.v \\
        $$INSTALL_BASE/Octavo/DataPath/ALU/Multiplier/Mult.v \\
        $$INSTALL_BASE/Octavo/DataPath/ALU/AddSub/AddSub_Carry_Select.v \\
        $$INSTALL_BASE/Octavo/DataPath/ALU/AddSub/AddSub_Ripple_Carry.v \\
        $$INSTALL_BASE/Octavo/DataPath/ALU/Bitwise/Bitwise.v \\
        $$INSTALL_BASE/Octavo/DataPath/ALU/ALU.v \\
        $$INSTALL_BASE/Octavo/DataPath/DataPath.v \\
        $$INSTALL_BASE/Octavo/Octavo.v \\
        $$INSTALL_BASE/Octavo/Scalar.v \\
        $$INSTALL_BASE/Octavo/SIMD.v \\
        ../${CPU_NAME}.v
"

VLIB="work"

VSIM_ACTIONS="vcd file $$TOP_LEVEL_MODULE.vcd ; vcd add -r /* ; run -all ; quit"

rm $$TOP_LEVEL_MODULE.wlf $$TOP_LEVEL_MODULE.vcd
vlib $$VLIB 2>&1 > /dev/null
vlog -mfcu -incr -lint $$LPM_LIBRARY $$ALT_LIBRARY $$OCTAVO $$TESTBENCH 2>&1 > /dev/null
vsim -voptargs="+acc" -c -do "$$VSIM_ACTIONS" $$TOP_LEVEL_MODULE 2>&1 > /dev/null
vcd2wlf $$TOP_LEVEL_MODULE.vcd $$TOP_LEVEL_MODULE.wlf 2>&1 > /dev/null
rm vsim.wlf
""")
    parameters["default_bench"] = default_bench
    parameters["install_base"] = install_base
    return test_bench_script_template.substitute(parameters)

def main(parameters = {}):
    name                = parameters["CPU_NAME"]
    test_bench_name     = name + "_" + misc.bench_name
    test_bench_file     = test_bench(parameters)
    test_bench_run      = test_bench_script(parameters)
    test_bench_dir      = os.path.join(os.getcwd(), misc.bench_name)
    misc.write_file(test_bench_dir, test_bench_name + ".v", test_bench_file)
    misc.write_file(test_bench_dir, "run_" + misc.bench_name, test_bench_run)
    misc.make_file_executable(test_bench_dir, "run_" + misc.bench_name)
    

if __name__ == "__main__":
    parameters          = parameters_misc.parse_cmdline(sys.argv[1:])
    main(parameters)
