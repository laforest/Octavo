#! /usr/bin/python

"""
Generates a parametrized Scalar Octavo definition.
"""

import string

def definition(all_parameters):
    definition_template = string.Template(
"""module ${CPU_NAME}
#(
    parameter       ALU_WORD_WIDTH                  = ${ALU_WORD_WIDTH},

    parameter       INSTR_WIDTH                     = ${INSTR_WIDTH},
    parameter       OPCODE_WIDTH                    = ${OPCODE_WIDTH},
    parameter       D_OPERAND_WIDTH                 = ${D_OPERAND_WIDTH},
    parameter       A_OPERAND_WIDTH                 = ${A_OPERAND_WIDTH},
    parameter       B_OPERAND_WIDTH                 = ${B_OPERAND_WIDTH},

    parameter       A_WRITE_ADDR_OFFSET             = ${A_WRITE_ADDR_OFFSET},
    parameter       A_WORD_WIDTH                    = ${A_WORD_WIDTH},
    parameter       A_ADDR_WIDTH                    = ${A_ADDR_WIDTH},
    parameter       A_DEPTH                         = ${A_DEPTH},
    parameter       A_RAMSTYLE                      = ${A_RAMSTYLE},
    parameter       A_INIT_FILE                     = ${A_INIT_FILE},
    parameter       A_IO_READ_PORT_COUNT            = ${A_IO_READ_PORT_COUNT},
    parameter       A_IO_READ_PORT_BASE_ADDR        = ${A_IO_READ_PORT_BASE_ADDR},
    parameter       A_IO_READ_PORT_ADDR_WIDTH       = ${A_IO_READ_PORT_ADDR_WIDTH},
    parameter       A_IO_WRITE_PORT_COUNT           = ${A_IO_WRITE_PORT_COUNT},
    parameter       A_IO_WRITE_PORT_BASE_ADDR       = ${A_IO_WRITE_PORT_BASE_ADDR},
    parameter       A_IO_WRITE_PORT_ADDR_WIDTH      = ${A_IO_WRITE_PORT_ADDR_WIDTH},

    parameter       B_WRITE_ADDR_OFFSET             = ${B_WRITE_ADDR_OFFSET},
    parameter       B_WORD_WIDTH                    = ${B_WORD_WIDTH},
    parameter       B_ADDR_WIDTH                    = ${B_ADDR_WIDTH},
    parameter       B_DEPTH                         = ${B_DEPTH},
    parameter       B_RAMSTYLE                      = ${B_RAMSTYLE},
    parameter       B_INIT_FILE                     = ${B_INIT_FILE},
    parameter       B_IO_READ_PORT_COUNT            = ${B_IO_READ_PORT_COUNT},
    parameter       B_IO_READ_PORT_BASE_ADDR        = ${B_IO_READ_PORT_BASE_ADDR},
    parameter       B_IO_READ_PORT_ADDR_WIDTH       = ${B_IO_READ_PORT_ADDR_WIDTH},
    parameter       B_IO_WRITE_PORT_COUNT           = ${B_IO_WRITE_PORT_COUNT},
    parameter       B_IO_WRITE_PORT_BASE_ADDR       = ${B_IO_WRITE_PORT_BASE_ADDR},
    parameter       B_IO_WRITE_PORT_ADDR_WIDTH      = ${B_IO_WRITE_PORT_ADDR_WIDTH},

    parameter       I_WRITE_ADDR_OFFSET             = ${I_WRITE_ADDR_OFFSET},
    parameter       I_WORD_WIDTH                    = ${INSTR_WIDTH},
    parameter       I_ADDR_WIDTH                    = ${I_ADDR_WIDTH},
    parameter       I_DEPTH                         = ${I_DEPTH},
    parameter       I_RAMSTYLE                      = ${I_RAMSTYLE},
    parameter       I_INIT_FILE                     = ${I_INIT_FILE},

    parameter       H_WRITE_ADDR_OFFSET             = ${H_WRITE_ADDR_OFFSET},
    parameter       H_WORD_WIDTH                    = ${H_WORD_WIDTH},
    parameter       H_ADDR_WIDTH                    = ${H_ADDR_WIDTH},
    parameter       H_DEPTH                         = ${H_DEPTH},

    parameter       PC_RAMSTYLE                     = ${PC_RAMSTYLE},
    parameter       PC_INIT_FILE                    = ${PC_INIT_FILE},
    parameter       THREAD_COUNT                    = ${THREAD_COUNT}, 
    parameter       THREAD_ADDR_WIDTH               = ${THREAD_ADDR_WIDTH}, 

    parameter       PC_PIPELINE_DEPTH               = ${PC_PIPELINE_DEPTH},
    parameter       I_TAP_PIPELINE_DEPTH            = ${I_TAP_PIPELINE_DEPTH},
    parameter       TAP_AB_PIPELINE_DEPTH           = ${TAP_AB_PIPELINE_DEPTH},
    parameter       I_PASSTHRU_PIPELINE_DEPTH       = ${I_PASSTHRU_PIPELINE_DEPTH},
    parameter       AB_READ_PIPELINE_DEPTH          = ${AB_READ_PIPELINE_DEPTH},
    parameter       AB_ALU_PIPELINE_DEPTH           = ${AB_ALU_PIPELINE_DEPTH},

    parameter       LOGIC_OPCODE_WIDTH              = ${LOGIC_OPCODE_WIDTH},
    parameter       ADDSUB_CARRY_SELECT             = ${ADDSUB_CARRY_SELECT},
    parameter       MULT_DOUBLE_PIPE                = ${MULT_DOUBLE_PIPE},
    parameter       MULT_HETEROGENEOUS              = ${MULT_HETEROGENEOUS},    
    parameter       MULT_USE_DSP                    = ${MULT_USE_DSP},

    parameter       ADDRESSING_H_ADDR_BASE          = ${ADDRESSING_H_ADDR_BASE},
    parameter       ADDRESSING_DEPTH                = ${ADDRESSING_DEPTH},
    parameter       ADDRESSING_ADDR_WIDTH           = ${ADDRESSING_ADDR_WIDTH},
    parameter       ADDRESSING_RAMTYLE              = ${ADDRESSING_RAMTYLE},
    parameter       ADDRESSING_INIT_FILE            = ${ADDRESSING_INIT_FILE},
    parameter       ADDRESSING_INITIAL_THREAD       = ${ADDRESSING_INITIAL_THREAD}
)
(
    input   wire                                                    clock,
    input   wire                                                    half_clock,

    // Memory write enables for external control by accelerators
    input   wire                                                    I_wren_other,
    input   wire                                                    A_wren_other,
    input   wire                                                    B_wren_other,

    // ALU AddSub carry-in/out for external control by accelerators
    input   wire                                                    ALU_c_in,
    output  wire                                                    ALU_c_out,

    output  wire    [INSTR_WIDTH-1:0]                               I_read_data,

    input   wire    [(               A_IO_READ_PORT_COUNT)-1:0]     A_in_EF,
    output  wire    [(               A_IO_READ_PORT_COUNT)-1:0]     A_rden,
    input   wire    [(A_WORD_WIDTH * A_IO_READ_PORT_COUNT)-1:0]     A_in,
    input   wire    [(               A_IO_WRITE_PORT_COUNT)-1:0]    A_out_EF,
    output  wire    [(               A_IO_WRITE_PORT_COUNT)-1:0]    A_wren,
    output  wire    [(A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT)-1:0]    A_out,

    input   wire    [(               B_IO_READ_PORT_COUNT)-1:0]     B_in_EF,
    output  wire    [(               B_IO_READ_PORT_COUNT)-1:0]     B_rden,
    input   wire    [(B_WORD_WIDTH * B_IO_READ_PORT_COUNT)-1:0]     B_in,
    input   wire    [(               B_IO_WRITE_PORT_COUNT)-1:0]    B_out_EF,
    output  wire    [(               B_IO_WRITE_PORT_COUNT)-1:0]    B_wren,
    output  wire    [(B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT)-1:0]    B_out
);
    Scalar
    #(
        .ALU_WORD_WIDTH                     (ALU_WORD_WIDTH),                 
        
        .INSTR_WIDTH                        (INSTR_WIDTH),                       
        .OPCODE_WIDTH                       (OPCODE_WIDTH),                     
        .D_OPERAND_WIDTH                    (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH                    (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH                    (B_OPERAND_WIDTH),
        
        .A_WRITE_ADDR_OFFSET                (A_WRITE_ADDR_OFFSET),
        .A_WORD_WIDTH                       (A_WORD_WIDTH),
        .A_ADDR_WIDTH                       (A_ADDR_WIDTH),
        .A_DEPTH                            (A_DEPTH),
        .A_RAMSTYLE                         (A_RAMSTYLE),
        .A_INIT_FILE                        (A_INIT_FILE),
        .A_IO_READ_PORT_COUNT               (A_IO_READ_PORT_COUNT),
        .A_IO_READ_PORT_BASE_ADDR           (A_IO_READ_PORT_BASE_ADDR),
        .A_IO_READ_PORT_ADDR_WIDTH          (A_IO_READ_PORT_ADDR_WIDTH),
        .A_IO_WRITE_PORT_COUNT              (A_IO_WRITE_PORT_COUNT),
        .A_IO_WRITE_PORT_BASE_ADDR          (A_IO_WRITE_PORT_BASE_ADDR),
        .A_IO_WRITE_PORT_ADDR_WIDTH         (A_IO_WRITE_PORT_ADDR_WIDTH),
        
        .B_WRITE_ADDR_OFFSET                (B_WRITE_ADDR_OFFSET),
        .B_WORD_WIDTH                       (B_WORD_WIDTH),
        .B_ADDR_WIDTH                       (B_ADDR_WIDTH),
        .B_DEPTH                            (B_DEPTH),
        .B_RAMSTYLE                         (B_RAMSTYLE),
        .B_INIT_FILE                        (B_INIT_FILE),
        .B_IO_READ_PORT_COUNT               (B_IO_READ_PORT_COUNT),
        .B_IO_READ_PORT_BASE_ADDR           (B_IO_READ_PORT_BASE_ADDR),
        .B_IO_READ_PORT_ADDR_WIDTH          (B_IO_READ_PORT_ADDR_WIDTH),
        .B_IO_WRITE_PORT_COUNT              (B_IO_WRITE_PORT_COUNT),
        .B_IO_WRITE_PORT_BASE_ADDR          (B_IO_WRITE_PORT_BASE_ADDR),
        .B_IO_WRITE_PORT_ADDR_WIDTH         (B_IO_WRITE_PORT_ADDR_WIDTH),
        
        .I_WRITE_ADDR_OFFSET                (I_WRITE_ADDR_OFFSET),
        .I_WORD_WIDTH                       (I_WORD_WIDTH),
        .I_ADDR_WIDTH                       (I_ADDR_WIDTH),
        .I_DEPTH                            (I_DEPTH),
        .I_RAMSTYLE                         (I_RAMSTYLE),
        .I_INIT_FILE                        (I_INIT_FILE),
        
        .H_WRITE_ADDR_OFFSET                (H_WRITE_ADDR_OFFSET),
        .H_WORD_WIDTH                       (H_WORD_WIDTH),
        .H_ADDR_WIDTH                       (H_ADDR_WIDTH),
        .H_DEPTH                            (H_DEPTH),

        .PC_RAMSTYLE                        (PC_RAMSTYLE),
        .PC_INIT_FILE                       (PC_INIT_FILE),
        .THREAD_COUNT                       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH                  (THREAD_ADDR_WIDTH),
        
        .PC_PIPELINE_DEPTH                  (PC_PIPELINE_DEPTH),
        .I_TAP_PIPELINE_DEPTH               (I_TAP_PIPELINE_DEPTH),
        .TAP_AB_PIPELINE_DEPTH              (TAP_AB_PIPELINE_DEPTH),
        .I_PASSTHRU_PIPELINE_DEPTH          (I_PASSTHRU_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH             (AB_READ_PIPELINE_DEPTH),
        .AB_ALU_PIPELINE_DEPTH              (AB_ALU_PIPELINE_DEPTH),

        .LOGIC_OPCODE_WIDTH                 (LOGIC_OPCODE_WIDTH),
        .ADDSUB_CARRY_SELECT                (ADDSUB_CARRY_SELECT),
        .MULT_DOUBLE_PIPE                   (MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS                 (MULT_HETEROGENEOUS),
        .MULT_USE_DSP                       (MULT_USE_DSP),

        .ADDRESSING_H_ADDR_BASE             (ADDRESSING_H_ADDR_BASE),
        .ADDRESSING_DEPTH                   (ADDRESSING_DEPTH),
        .ADDRESSING_ADDR_WIDTH              (ADDRESSING_ADDR_WIDTH),
        .ADDRESSING_RAMTYLE                 (ADDRESSING_RAMTYLE),
        .ADDRESSING_INIT_FILE               (ADDRESSING_INIT_FILE),
        .ADDRESSING_INITIAL_THREAD          (ADDRESSING_INITIAL_THREAD)
    )
    Scalar
    (
        .clock                              (clock),
        .half_clock                         (half_clock),

        .I_wren_other                       (I_wren_other),        
        .A_wren_other                       (A_wren_other),        
        .B_wren_other                       (B_wren_other),        

        .ALU_c_in                           (ALU_c_in),
        .ALU_c_out                          (ALU_c_out),

        .I_read_data                        (I_read_data),

        .A_io_in_EF                         (A_in_EF),
        .A_io_rden                          (A_rden),
        .A_io_in                            (A_in),
        .A_io_out_EF                        (A_out_EF),
        .A_io_out                           (A_out),
        .A_io_wren                          (A_wren),
        
        .B_io_in_EF                         (B_in_EF),
        .B_io_rden                          (B_rden),
        .B_io_in                            (B_in),
        .B_io_out_EF                        (B_out_EF),
        .B_io_out                           (B_out),
        .B_io_wren                          (B_wren)
    );
endmodule
""")
    parameters = definition_template.substitute(all_parameters)
    return parameters


if __name__ == "__main__":
    import Scalar_parameters as sp
    all_parameters = sp.all_parameters()
    this_scalar = definition(all_parameters)
    print this_scalar

