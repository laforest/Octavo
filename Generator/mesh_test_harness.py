#! /usr/bin/python

import string

import mesh_definition
import mesh_parameters

def test_harness(parameters):
    test_harness_template = string.Template(
"""module ${MESH_NAME}_test_harness
#(
    parameter       MESH_WIDTH                  = ${MESH_WIDTH},
    parameter       MESH_DEPTH                  = ${MESH_DEPTH},

    parameter       A_WORD_WIDTH                = ${A_WORD_WIDTH},
    parameter       A_IO_READ_PORT_COUNT        = ${A_IO_READ_PORT_COUNT},
    parameter       A_IO_WRITE_PORT_COUNT       = ${A_IO_WRITE_PORT_COUNT},

    parameter       B_WORD_WIDTH                = ${B_WORD_WIDTH},
    parameter       B_IO_READ_PORT_COUNT        = ${B_IO_READ_PORT_COUNT},
    parameter       B_IO_WRITE_PORT_COUNT       = ${B_IO_WRITE_PORT_COUNT},

    // Add extra rows/columns on each side to support I/O wires, which would otherwise index out of bounds.
    // All wires will end up connected, though many edge ones will connect an input pin to an output pin without logic in between.
    // XXX Add longest vert/horiz hop to deal with topologies with skips
    parameter       EXTENDED_MESH_DEPTH         = MESH_DEPTH + 2,
    parameter       EXTENDED_MESH_WIDTH         = MESH_WIDTH + 2,

    parameter       A_PORTS_TOP                 = ${A_top_ports},
    parameter       A_PORTS_BOTTOM              = ${A_bottom_ports},
    parameter       A_PORTS_LEFT                = ${A_left_ports},
    parameter       A_PORTS_RIGHT               = ${A_right_ports},

    parameter       B_PORTS_TOP                 = ${B_top_ports},
    parameter       B_PORTS_BOTTOM              = ${B_bottom_ports},
    parameter       B_PORTS_LEFT                = ${B_left_ports},
    parameter       B_PORTS_RIGHT               = ${B_right_ports},

    parameter       A_EDGE_PORTS_COUNT          = (EXTENDED_MESH_WIDTH * (A_PORTS_TOP + A_PORTS_BOTTOM)) + (EXTENDED_MESH_DEPTH * (A_PORTS_LEFT + A_PORTS_RIGHT)),
    parameter       B_EDGE_PORTS_COUNT          = (EXTENDED_MESH_WIDTH * (B_PORTS_TOP + B_PORTS_BOTTOM)) + (EXTENDED_MESH_DEPTH * (B_PORTS_LEFT + B_PORTS_RIGHT)),

    parameter       A_IO_READ_WIDTH             = A_EDGE_PORTS_COUNT,
    parameter       A_IO_WRITE_WIDTH            = A_EDGE_PORTS_COUNT,

    parameter       B_IO_READ_WIDTH             = B_EDGE_PORTS_COUNT,
    parameter       B_IO_WRITE_WIDTH            = B_EDGE_PORTS_COUNT,

    parameter       A_DUT_IO_READ_WIDTH         = A_WORD_WIDTH * A_EDGE_PORTS_COUNT,
    parameter       A_DUT_IO_WRITE_WIDTH        = A_WORD_WIDTH * A_EDGE_PORTS_COUNT,

    parameter       B_DUT_IO_READ_WIDTH         = B_WORD_WIDTH * B_EDGE_PORTS_COUNT,
    parameter       B_DUT_IO_WRITE_WIDTH        = B_WORD_WIDTH * B_EDGE_PORTS_COUNT

)
(
    input   wire                            clock,
    input   wire                            half_clock,
    
    input   wire    [A_IO_READ_WIDTH-1:0]   A_io_in,
    output  wire    [A_IO_WRITE_WIDTH-1:0]  A_io_out,
    
    input   wire    [B_IO_READ_WIDTH-1:0]   B_io_in,
    output  wire    [B_IO_WRITE_WIDTH-1:0]  B_io_out
);

    wire    [A_DUT_IO_READ_WIDTH-1:0]   dut_A_io_in;
    wire    [A_DUT_IO_WRITE_WIDTH-1:0]  dut_A_io_out;

    wire    [B_DUT_IO_READ_WIDTH-1:0]   dut_B_io_in;
    wire    [B_DUT_IO_WRITE_WIDTH-1:0]  dut_B_io_out;
    
    ${MESH_NAME}
    DUT
    (
        .clock      (clock),
        .half_clock (half_clock),
        
        .A_io_in    (dut_A_io_in),
        .A_io_out   (dut_A_io_out),

        .B_io_in    (dut_B_io_in),
        .B_io_out   (dut_B_io_out)
    );

    shift_register
    #(
        .WIDTH  (A_WORD_WIDTH)
    )
    input_harness_A [0:A_EDGE_PORTS_COUNT-1]
    (
        .clock          (clock),
        .input_port     (A_io_in),
        .output_port    (dut_A_io_in)
    );

    shift_register
    #(
        .WIDTH  (B_WORD_WIDTH)
    )
    input_harness_B [0:B_EDGE_PORTS_COUNT-1]
    (
        .clock          (clock),
        .input_port     (B_io_in),
        .output_port    (dut_B_io_in)
    );

    registered_reducer
    #(
        .WIDTH          (A_WORD_WIDTH)
    ) 
    rr_out_A [0:A_EDGE_PORTS_COUNT-1]
    (
        .clock          (clock),
        .input_port     (dut_A_io_out),
        .output_port    (A_io_out)
    );

    registered_reducer
    #(
        .WIDTH          (B_WORD_WIDTH)
    ) 
    rr_out_B [0:B_EDGE_PORTS_COUNT-1]
    (
        .clock          (clock),
        .input_port     (dut_B_io_out),
        .output_port    (B_io_out)
    );
endmodule
""")
    width, depth        = mesh_parameters.mesh_dimensions(parameters)
    mesh_name           = parameters["NAME"]
    base_cpu            = parameters["BASE_CPU"]
    A_top_ports, A_bottom_ports, A_left_ports, A_right_ports = mesh_definition.edge_all_port_counts(parameters["TOPOLOGY"].values()[0]["A"]["CONNECTS"])
    B_top_ports, B_bottom_ports, B_left_ports, B_right_ports = mesh_definition.edge_all_port_counts(parameters["TOPOLOGY"].values()[0]["B"]["CONNECTS"])
    entries = {"MESH_WIDTH":width,
               "MESH_DEPTH":depth,
               "MESH_NAME":mesh_name,
               "A_WORD_WIDTH":base_cpu["A_WORD_WIDTH"],
               "A_IO_READ_PORT_COUNT":base_cpu["A_IO_READ_PORT_COUNT"],
               "A_IO_WRITE_PORT_COUNT":base_cpu["A_IO_WRITE_PORT_COUNT"],
               "B_WORD_WIDTH":base_cpu["B_WORD_WIDTH"],
               "B_IO_READ_PORT_COUNT":base_cpu["B_IO_READ_PORT_COUNT"],
               "B_IO_WRITE_PORT_COUNT":base_cpu["B_IO_WRITE_PORT_COUNT"],
               "A_top_ports":A_top_ports,
               "A_bottom_ports":A_bottom_ports,
               "A_left_ports":A_left_ports,
               "A_right_ports":A_right_ports,
               "B_top_ports":B_top_ports,
               "B_bottom_ports":B_bottom_ports,
               "B_left_ports":B_left_ports,
               "B_right_ports":B_right_ports}
    return test_harness_template.substitute(entries)

if __name__ == "__main__":
    import mesh_parameters as mp
    all_parameters = mp.all_parameters(parameters = {"BASE_CPU":"Octavo_A2in2out_B2in2out",
                                                     "COLUMNS":3,
                                                     "ROWS":3,
                                                     "TOPOLOGY":"SQUARE"})
    harness = test_harness(all_parameters)
    print harness
    
