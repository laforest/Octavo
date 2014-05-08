#! /usr/bin/python

import string
import os
import sys

from Misc import misc, parameters_misc
import SIMD_quartus_project

default_memory_init = "Empty/empty"
install_base = misc.base_install_path()

def test_harness(parameters, default_memory_init = default_memory_init, install_base = install_base):
    assembler_base = os.path.join(install_base, "Assembler")
    test_harness_template = string.Template(
"""module ${CPU_NAME}_test_harness
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

    parameter       A_INIT_FILE                 = "${assembler_base}/${default_memory_init}.A",
    parameter       B_INIT_FILE                 = "${assembler_base}/${default_memory_init}.B",
    parameter       I_INIT_FILE                 = "${assembler_base}/${default_memory_init}.I",
    parameter       PC_INIT_FILE                = "${assembler_base}/${default_memory_init}.PC",
    parameter       SIMD_A_INIT_FILE            = "${assembler_base}/${default_memory_init}.A",
    parameter       SIMD_B_INIT_FILE            = "${assembler_base}/${default_memory_init}.B",

    parameter       A_DEFAULT_OFFSET_INIT_FILE  = "${assembler_base}/${default_memory_init}.ADO",
    parameter       B_DEFAULT_OFFSET_INIT_FILE  = "${assembler_base}/${default_memory_init}.BDO",
    parameter       D_DEFAULT_OFFSET_INIT_FILE  = "${assembler_base}/${default_memory_init}.DDO",

    parameter       A_PROGRAMMED_OFFSETS_INIT_FILE  = "${assembler_base}/${default_memory_init}.APO",
    parameter       B_PROGRAMMED_OFFSETS_INIT_FILE  = "${assembler_base}/${default_memory_init}.BPO",
    parameter       D_PROGRAMMED_OFFSETS_INIT_FILE  = "${assembler_base}/${default_memory_init}.DPO",

    parameter       A_INCREMENTS_INIT_FILE  = "${assembler_base}/${default_memory_init}.AIN",
    parameter       B_INCREMENTS_INIT_FILE  = "${assembler_base}/${default_memory_init}.BIN",
    parameter       D_INCREMENTS_INIT_FILE  = "${assembler_base}/${default_memory_init}.DIN",

    parameter       ORIGIN_INIT_FILE       = "${assembler_base}/${default_memory_init}.BO",
    parameter       DESTINATION_INIT_FILE  = "${assembler_base}/${default_memory_init}.BD",
    parameter       CONDITION_INIT_FILE    = "${assembler_base}/${default_memory_init}.BC",
    parameter       PREDICTION_INIT_FILE   = "${assembler_base}/${default_memory_init}.BP",
    parameter       PREDICTION_ENABLE_INIT_FILE   = "${assembler_base}/${default_memory_init}.BPE",

    // ****** These are computed for brevity later. Do not redefine at module instantiation. ******
    parameter       A_IO_READ_PORT_WIDTH                = (A_WORD_WIDTH * A_IO_READ_PORT_COUNT),
    parameter       A_IO_WRITE_PORT_WIDTH               = (A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT),
    parameter       B_IO_READ_PORT_WIDTH                = (B_WORD_WIDTH * B_IO_READ_PORT_COUNT),
    parameter       B_IO_WRITE_PORT_WIDTH               = (B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT),

    parameter       SIMD_A_IO_READ_PORT_COUNT_TOTAL     = (SIMD_A_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT),
    parameter       SIMD_A_IO_WRITE_PORT_COUNT_TOTAL    = (SIMD_A_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT),
    parameter       SIMD_B_IO_READ_PORT_COUNT_TOTAL     = (SIMD_B_IO_READ_PORT_COUNT  * SIMD_LANE_COUNT),
    parameter       SIMD_B_IO_WRITE_PORT_COUNT_TOTAL    = (SIMD_B_IO_WRITE_PORT_COUNT * SIMD_LANE_COUNT),

    parameter       SIMD_A_IO_READ_PORT_WIDTH_TOTAL     = (SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT_TOTAL),
    parameter       SIMD_A_IO_WRITE_PORT_WIDTH_TOTAL    = (SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT_TOTAL),
    parameter       SIMD_B_IO_READ_PORT_WIDTH_TOTAL     = (SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT_TOTAL),
    parameter       SIMD_B_IO_WRITE_PORT_WIDTH_TOTAL    = (SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT_TOTAL)
)
(
    input   wire                                            clock,
    input   wire                                            half_clock,
    
    input   wire    [A_IO_READ_PORT_COUNT-1:0]      A_in,
    input   wire    [A_IO_READ_PORT_COUNT-1:0]      A_in_EF,
    output  wire    [A_IO_WRITE_PORT_COUNT-1:0]     A_out,
    input   wire    [A_IO_READ_PORT_COUNT-1:0]      A_out_EF,
    
    input   wire    [B_IO_READ_PORT_COUNT-1:0]      B_in,
    input   wire    [B_IO_READ_PORT_COUNT-1:0]      B_in_EF,
    output  wire    [B_IO_WRITE_PORT_COUNT-1:0]     B_out,
    input   wire    [B_IO_READ_PORT_COUNT-1:0]      B_out_EF,

    input   wire    [SIMD_A_IO_READ_PORT_COUNT_TOTAL-1:0]   SIMD_A_in,
    input   wire    [SIMD_A_IO_READ_PORT_COUNT_TOTAL-1:0]   SIMD_A_in_EF,
    output  wire    [SIMD_A_IO_WRITE_PORT_COUNT_TOTAL-1:0]  SIMD_A_out,
    input   wire    [SIMD_A_IO_WRITE_PORT_COUNT_TOTAL-1:0]  SIMD_A_out_EF,

    input   wire    [SIMD_B_IO_READ_PORT_COUNT_TOTAL-1:0]   SIMD_B_in,
    input   wire    [SIMD_B_IO_READ_PORT_COUNT_TOTAL-1:0]   SIMD_B_in_EF,
    output  wire    [SIMD_B_IO_WRITE_PORT_COUNT_TOTAL-1:0]  SIMD_B_out,
    input   wire    [SIMD_B_IO_WRITE_PORT_COUNT_TOTAL-1:0]  SIMD_B_out_EF
);
    wire    [A_IO_READ_PORT_WIDTH-1:0]      dut_A_in;
    wire    [A_IO_READ_PORT_COUNT-1:0]      dut_A_in_EF;
    wire    [A_IO_READ_PORT_COUNT-1:0]      dut_A_rden;
    wire    [A_IO_WRITE_PORT_WIDTH-1:0]     dut_A_out;
    wire    [A_IO_WRITE_PORT_COUNT-1:0]     dut_A_out_EF;
    wire    [A_IO_WRITE_PORT_COUNT-1:0]     dut_A_wren;

    wire    [B_IO_READ_PORT_WIDTH-1:0]      dut_B_in;
    wire    [B_IO_READ_PORT_COUNT-1:0]      dut_B_in_EF;
    wire    [B_IO_READ_PORT_COUNT-1:0]      dut_B_rden;
    wire    [B_IO_WRITE_PORT_WIDTH-1:0]     dut_B_out;
    wire    [B_IO_WRITE_PORT_COUNT-1:0]     dut_B_out_EF;
    wire    [B_IO_WRITE_PORT_COUNT-1:0]     dut_B_wren;

    wire    [SIMD_A_IO_READ_PORT_WIDTH_TOTAL-1:0]   dut_SIMD_A_in;
    wire    [SIMD_A_IO_READ_PORT_COUNT_TOTAL-1:0]   dut_SIMD_A_in_EF;
    wire    [SIMD_A_IO_READ_PORT_COUNT_TOTAL-1:0]   dut_SIMD_A_rden;
    wire    [SIMD_A_IO_WRITE_PORT_WIDTH_TOTAL-1:0]  dut_SIMD_A_out;
    wire    [SIMD_A_IO_WRITE_PORT_COUNT_TOTAL-1:0]  dut_SIMD_A_out_EF;
    wire    [SIMD_A_IO_WRITE_PORT_COUNT_TOTAL-1:0]  dut_SIMD_A_wren;

    wire    [SIMD_B_IO_READ_PORT_WIDTH_TOTAL-1:0]   dut_SIMD_B_in;
    wire    [SIMD_B_IO_READ_PORT_COUNT_TOTAL-1:0]   dut_SIMD_B_in_EF;
    wire    [SIMD_B_IO_READ_PORT_COUNT_TOTAL-1:0]   dut_SIMD_B_rden;
    wire    [SIMD_B_IO_WRITE_PORT_WIDTH_TOTAL-1:0]  dut_SIMD_B_out;
    wire    [SIMD_B_IO_WRITE_PORT_COUNT_TOTAL-1:0]  dut_SIMD_B_out_EF;
    wire    [SIMD_B_IO_WRITE_PORT_COUNT_TOTAL-1:0]  dut_SIMD_B_wren;

    localparam WREN_OTHER_DEFAULT       = `HIGH;
    localparam ALU_C_IN_DEFAULT         = `LOW;
    localparam SIMD_WREN_OTHER_DEFAULT  = {SIMD_LANE_COUNT{`HIGH}};
    localparam SIMD_ALU_C_IN_DEFAULT    = {SIMD_LANE_COUNT{`LOW}};

    ${CPU_NAME}
    #(
        .A_INIT_FILE        (A_INIT_FILE),
        .B_INIT_FILE        (B_INIT_FILE),
        .I_INIT_FILE        (I_INIT_FILE),
        .PC_INIT_FILE       (PC_INIT_FILE),
        .SIMD_A_INIT_FILE   (SIMD_A_INIT_FILE),
        .SIMD_B_INIT_FILE   (SIMD_B_INIT_FILE),
        .A_DEFAULT_OFFSET_INIT_FILE     (A_DEFAULT_OFFSET_INIT_FILE),
        .B_DEFAULT_OFFSET_INIT_FILE     (B_DEFAULT_OFFSET_INIT_FILE),
        .D_DEFAULT_OFFSET_INIT_FILE     (D_DEFAULT_OFFSET_INIT_FILE),
        .A_PROGRAMMED_OFFSETS_INIT_FILE (A_PROGRAMMED_OFFSETS_INIT_FILE),
        .B_PROGRAMMED_OFFSETS_INIT_FILE (B_PROGRAMMED_OFFSETS_INIT_FILE),
        .D_PROGRAMMED_OFFSETS_INIT_FILE (D_PROGRAMMED_OFFSETS_INIT_FILE),
        .A_INCREMENTS_INIT_FILE         (A_INCREMENTS_INIT_FILE),
        .B_INCREMENTS_INIT_FILE         (B_INCREMENTS_INIT_FILE),
        .D_INCREMENTS_INIT_FILE         (D_INCREMENTS_INIT_FILE),
        .ORIGIN_INIT_FILE               (ORIGIN_INIT_FILE),
        .DESTINATION_INIT_FILE          (DESTINATION_INIT_FILE),
        .CONDITION_INIT_FILE            (CONDITION_INIT_FILE),
        .PREDICTION_INIT_FILE           (PREDICTION_INIT_FILE),
        .PREDICTION_ENABLE_INIT_FILE    (PREDICTION_ENABLE_INIT_FILE)

    )
    DUT
    (
        .clock              (clock),
        .half_clock         (half_clock),

        .I_wren_other       (`HIGH),
        .A_wren_other       (WREN_OTHER_DEFAULT),
        .B_wren_other       (WREN_OTHER_DEFAULT),
        .SIMD_A_wren_other  (SIMD_WREN_OTHER_DEFAULT),
        .SIMD_B_wren_other  (SIMD_WREN_OTHER_DEFAULT),
        
        .ALU_c_in           (ALU_C_IN_DEFAULT),
        .ALU_c_out          (),
        .SIMD_ALU_c_in      (SIMD_ALU_C_IN_DEFAULT),
        .SIMD_ALU_c_out     (),

        .A_in_EF            (dut_A_in_EF),
        .A_rden             (dut_A_rden),
        .A_in               (dut_A_in),
        .A_out_EF           (dut_A_out_EF),
        .A_wren             (dut_A_wren),
        .A_out              (dut_A_out),

        .B_in_EF            (dut_B_in_EF),
        .B_rden             (dut_B_rden),
        .B_in               (dut_B_in),
        .B_out_EF           (dut_B_out_EF),
        .B_wren             (dut_B_wren),
        .B_out              (dut_B_out),

        .SIMD_A_in_EF       (dut_SIMD_A_in_EF),
        .SIMD_A_rden        (dut_SIMD_A_rden),
        .SIMD_A_in          (dut_SIMD_A_in),
        .SIMD_A_out_EF      (dut_SIMD_A_out_EF),
        .SIMD_A_wren        (dut_SIMD_A_wren),
        .SIMD_A_out         (dut_SIMD_A_out),

        .SIMD_B_in_EF       (dut_SIMD_B_in_EF),
        .SIMD_B_rden        (dut_SIMD_B_rden),
        .SIMD_B_in          (dut_SIMD_B_in),
        .SIMD_B_out_EF      (dut_SIMD_B_out_EF),
        .SIMD_B_wren        (dut_SIMD_B_wren),
        .SIMD_B_out         (dut_SIMD_B_out)
    );




    // ****** A PORT INPUT ******
    shift_register
    #(
        .WIDTH          (A_WORD_WIDTH)
    )
    input_harness_A     [A_IO_READ_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .input_port     (A_in),
        .read_enable    (dut_A_rden),
        .output_port    (dut_A_in)
    );

    shift_register
    #(
        .WIDTH              (SIMD_A_WORD_WIDTH)
    )
    SIMD_input_harness_A    [SIMD_A_IO_READ_PORT_COUNT_TOTAL-1:0]
    (
        .clock              (clock),
        .input_port         (SIMD_A_in),
        .read_enable        (dut_SIMD_A_rden),
        .output_port        (dut_SIMD_A_in)
    );

    shift_register
    #(
        .WIDTH          (1)
    )
    input_harness_A_EF  [A_IO_READ_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .input_port     (A_in_EF     [0 +: A_IO_READ_PORT_COUNT]),
        .read_enable    ({A_IO_READ_PORT_COUNT{`HIGH}}),
        .output_port    (dut_A_in_EF [0 +: A_IO_READ_PORT_COUNT])
    );

    shift_register
    #(
        .WIDTH          (1)
    )
    SIMD_input_harness_A_EF  [SIMD_A_IO_READ_PORT_COUNT_TOTAL-1:0]
    (
        .clock          (clock),
        .input_port     (SIMD_A_in_EF),
        .read_enable    ({SIMD_A_IO_READ_PORT_COUNT_TOTAL{`HIGH}}),
        .output_port    (dut_SIMD_A_in_EF)
    );




    // ****** B PORT INPUT ******
    shift_register
    #(
        .WIDTH          (B_WORD_WIDTH)
    )
    input_harness_B     [B_IO_READ_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .input_port     (B_in),
        .read_enable    (dut_B_rden),
        .output_port    (dut_B_in)
    );

    shift_register
    #(
        .WIDTH              (SIMD_B_WORD_WIDTH)
    )
    SIMD_input_harness_B    [SIMD_B_IO_READ_PORT_COUNT_TOTAL-1:0]
    (
        .clock              (clock),
        .input_port         (SIMD_B_in),
        .read_enable        (dut_SIMD_B_rden),
        .output_port        (dut_SIMD_B_in)
    );

    shift_register
    #(
        .WIDTH          (1)
    )
    input_harness_B_EF  [B_IO_READ_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .input_port     (B_in_EF     [0 +: B_IO_READ_PORT_COUNT]),
        .read_enable    ({B_IO_READ_PORT_COUNT{`HIGH}}),
        .output_port    (dut_B_in_EF [0 +: B_IO_READ_PORT_COUNT])
    );

    shift_register
    #(
        .WIDTH          (1)
    )
    SIMD_input_harness_B_EF  [SIMD_B_IO_READ_PORT_COUNT_TOTAL-1:0]
    (
        .clock          (clock),
        .input_port     (SIMD_B_in_EF),
        .read_enable    ({SIMD_B_IO_READ_PORT_COUNT_TOTAL{`HIGH}}),
        .output_port    (dut_SIMD_B_in_EF)
    );





    // ****** A PORT OUTPUT ******
    wire    [A_IO_WRITE_PORT_WIDTH-1:0]     out_A;
    
    output_register
    #(
        .WIDTH          (A_WORD_WIDTH)
    )
    or_out_A            [A_IO_WRITE_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .in             (dut_A_out),
        .wren           (dut_A_wren),
        .out            (out_A)
    );

    registered_reducer
    #(
        .WIDTH          (A_WORD_WIDTH)
    ) 
    rr_out_A            [A_IO_WRITE_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .input_port     (out_A),
        .output_port    (A_out)
    );

    shift_register
    #(
        .WIDTH          (1)
    )
    output_harness_A_EF [A_IO_WRITE_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .input_port     (A_out_EF),
        .read_enable    ({A_IO_WRITE_PORT_COUNT{`HIGH}}),
        .output_port    (dut_A_out_EF)
    );

    wire    [SIMD_A_IO_WRITE_PORT_WIDTH_TOTAL-1:0]  SIMD_out_A;
    
    output_register
    #(
        .WIDTH          (SIMD_A_WORD_WIDTH)
    )
    SIMD_or_out_A       [SIMD_A_IO_WRITE_PORT_COUNT_TOTAL-1:0]
    (
        .clock          (clock),
        .in             (dut_SIMD_A_out),
        .wren           (dut_SIMD_A_wren),
        .out            (SIMD_out_A)
    );

    registered_reducer
    #(
        .WIDTH          (SIMD_A_WORD_WIDTH)
    ) 
    SIMD_rr_out_A       [SIMD_A_IO_WRITE_PORT_COUNT_TOTAL-1:0]
    (
        .clock          (clock),
        .input_port     (SIMD_out_A),
        .output_port    (SIMD_A_out)
    );

    shift_register
    #(
        .WIDTH          (1)
    )
    SIMD_output_harness_A_EF [SIMD_A_IO_WRITE_PORT_COUNT_TOTAL-1:0]
    (
        .clock          (clock),
        .input_port     (SIMD_A_out_EF),
        .read_enable    ({SIMD_A_IO_WRITE_PORT_COUNT_TOTAL{`HIGH}}),
        .output_port    (dut_SIMD_A_out_EF)
    );





    // ****** B PORT OUTPUT ******
    wire    [B_IO_WRITE_PORT_WIDTH-1:0]     out_B;
    
    output_register
    #(
        .WIDTH          (B_WORD_WIDTH)
    )
    or_out_B            [B_IO_WRITE_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .in             (dut_B_out),
        .wren           (dut_B_wren),
        .out            (out_B)
    );

    registered_reducer
    #(
        .WIDTH          (B_WORD_WIDTH)
    ) 
    rr_out_B            [B_IO_WRITE_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .input_port     (out_B),
        .output_port    (B_out)
    );

    shift_register
    #(
        .WIDTH          (1)
    )
    output_harness_B_EF [B_IO_WRITE_PORT_COUNT-1:0]
    (
        .clock          (clock),
        .input_port     (B_out_EF),
        .read_enable    ({B_IO_WRITE_PORT_COUNT{`HIGH}}),
        .output_port    (dut_B_out_EF)
    );

    wire    [SIMD_B_IO_WRITE_PORT_WIDTH_TOTAL-1:0]  SIMD_out_B;
    
    output_register
    #(
        .WIDTH          (SIMD_B_WORD_WIDTH)
    )
    SIMD_or_out_B       [SIMD_B_IO_WRITE_PORT_COUNT_TOTAL-1:0]
    (
        .clock          (clock),
        .in             (dut_SIMD_B_out),
        .wren           (dut_SIMD_B_wren),
        .out            (SIMD_out_B)
    );

    registered_reducer
    #(
        .WIDTH          (SIMD_B_WORD_WIDTH)
    ) 
    SIMD_rr_out_B       [SIMD_B_IO_WRITE_PORT_COUNT_TOTAL-1:0]
    (
        .clock          (clock),
        .input_port     (SIMD_out_B),
        .output_port    (SIMD_B_out)
    );

    shift_register
    #(
        .WIDTH          (1)
    )
    SIMD_output_harness_B_EF [SIMD_B_IO_WRITE_PORT_COUNT_TOTAL-1:0]
    (
        .clock          (clock),
        .input_port     (SIMD_B_out_EF),
        .read_enable    ({SIMD_B_IO_WRITE_PORT_COUNT_TOTAL{`HIGH}}),
        .output_port    (dut_SIMD_B_out_EF)
    );
endmodule
""")
    parameters["default_memory_init"] = default_memory_init
    parameters["assembler_base"] = assembler_base
    return test_harness_template.substitute(parameters)

# -----------------------------------------------------------

def test_harness_script(parameters):
    test_harness_script_template = string.Template(
"""#! /bin/bash

quartus_sh --flow compile ${CPU_NAME}_test_harness 2>&1 | tee LOG_QUARTUS

""")
    return test_harness_script_template.substitute(parameters)

# -----------------------------------------------------------

def seed_run_script(harness_name = misc.harness_name):
    seed_run_script_template = string.Template(
"""#! /bin/bash

SOURCEDIR=${HARNESS_NAME}
WORKDIR=$${SOURCEDIR}_$$1

function generate_seed () {
    # No idea about the distribution...
    echo $$(( $${RANDOM}$${RANDOM} % 2**31 ))
}

function set_project_parameters () {
    local SEED=$$1
    sed -i -e"s/SEED.*/SEED $${SEED}/" *.qsf
}

function extract_fmax () {
    echo $$(grep "MHz" *.sta.rpt | grep -v Base | grep -v half_clock | cut -d';' -f 2 | cut -d' ' -f 2)
}

function do_seed_run () {
    rm -rf $${WORKDIR} > /dev/null
    cp -a $${SOURCEDIR} $${WORKDIR}
    pushd $${WORKDIR} > /dev/null
        set_project_parameters $$(generate_seed)
        ./run_test_harness > /dev/null
        rm -rf db incremental_db > /dev/null
        extract_fmax > ./fmax
    popd > /dev/null
}

do_seed_run

""")
    return seed_run_script_template.substitute({"HARNESS_NAME":harness_name})

# -----------------------------------------------------------

def all_seed_runs_script():
    all_seed_run_script_template = string.Template(
"""#! /bin/bash

if [ $$# -lt 1 ]; then
    JOBS=1
else
    JOBS=$$1
fi

parallel -j $${JOBS} <<TODO
./seed_run 0
./seed_run 1
./seed_run 2
./seed_run 3
./seed_run 4
./seed_run 5
./seed_run 6
./seed_run 7
./seed_run 8
./seed_run 9
TODO

""")
    return all_seed_run_script_template.substitute()

# -----------------------------------------------------------

def all_fmax_script(harness_name = misc.harness_name):
    all_fmax_script_template = string.Template(
"""#! /bin/bash

for i in ${HARNESS_NAME}_*;
do
    cat $$i/fmax
done | sort -n |  awk '{s+=$$1; print $$1}END{print s/NR}'

""")
    return all_fmax_script_template.substitute({"HARNESS_NAME":harness_name})

# -----------------------------------------------------------

def main(parameters = {}):
    name                = parameters["CPU_NAME"]
    test_harness_name   = name + "_" + misc.harness_name
    test_harness_dir    = os.path.join(os.getcwd(), misc.harness_name)
    cwd                 = os.getcwd()

    test_harness_file   = test_harness(parameters)
    misc.write_file(test_harness_dir, test_harness_name + ".v", test_harness_file)

    test_harness_run    = test_harness_script(parameters)
    misc.write_file(test_harness_dir, "run_" + misc.harness_name, test_harness_run)
    misc.make_file_executable(test_harness_dir, "run_" + misc.harness_name)

    seed_run            = seed_run_script()
    misc.write_file(cwd, "seed_run", seed_run)
    misc.make_file_executable(cwd, "seed_run")

    all_seed_runs       = all_seed_runs_script()
    misc.write_file(cwd, "all_seed_runs", all_seed_runs)
    misc.make_file_executable(cwd, "all_seed_runs")

    all_fmax            = all_fmax_script()
    misc.write_file(cwd, "all_fmax", all_fmax)
    misc.make_file_executable(cwd, "all_fmax")

    # XXX ECL hack: we should specify the location of the parameter file
    parameters_misc.update_parameter_file(os.getcwd(), 
                                          name, 
                                          {"PROJECT_NAME":test_harness_name})
    parameters.update({"PROJECT_NAME":test_harness_name})
    SIMD_quartus_project.project(parameters, test_harness_dir)
    

if __name__ == "__main__":
    parameters          = parameters_misc.parse_cmdline(sys.argv[1:])
    main(parameters)

