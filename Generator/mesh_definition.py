#! /usr/bin/python

import string

import misc
import parameters_misc
import mesh_parameters
import copy

def node_instance_port_connections(column, row, port_name, port_count):
    port = ""
    port_template = string.Template("${port_name}[${column}][${row}][${index}]")
    entries = {"port_name":port_name,
               "column":column,
               "row":row,
               "index":None}
    for index in range(port_count):
        entries.update({"index":index})
        port = port_template.substitute(entries) + ", " + port
    port = port.strip().strip(',')
    port = "{" + port + "}"
    return port
    
def node_instance(column, row, base_cpu, overrides, name):
    template = string.Template(
"""${cpu}${overrides}
${name}
(
    .clock      (clock),
    .half_clock (half_clock),

    .A_in       (${A_in}),
    .A_wren     (${A_wren}),
    .A_out      (${A_out}),

    .B_in       (${B_in}),
    .B_wren     (${B_wren}),
    .B_out      (${B_out})
);
""")
    node_parameters = copy.deepcopy(base_cpu)
    node_parameters.update(overrides)
    if len(overrides) > 0:
        overrides = parameters_misc.all_parameter_strings(overrides)
        overrides = "\n#(\n{0}\n)".format(misc.indent(overrides))
    else:
        overrides = ""
    # Note shifted wren access into its own smaller wire array
    A_in = node_instance_port_connections(column, row, "A_in", node_parameters["A_IO_READ_PORT_COUNT"])
    A_wren = node_instance_port_connections(column-1, row-1, "A_wren", node_parameters["A_IO_WRITE_PORT_COUNT"])
    A_out = node_instance_port_connections(column, row, "A_out", node_parameters["A_IO_WRITE_PORT_COUNT"])
    B_in = node_instance_port_connections(column, row, "B_in", node_parameters["B_IO_READ_PORT_COUNT"])
    B_wren = node_instance_port_connections(column-1, row-1, "B_wren", node_parameters["B_IO_WRITE_PORT_COUNT"])
    B_out = node_instance_port_connections(column, row, "B_out", node_parameters["B_IO_WRITE_PORT_COUNT"])
    entries = {"cpu":base_cpu["CPU_NAME"],
               "overrides":overrides,
               "A_in":A_in,
               "A_wren":A_wren,
               "A_out":A_out,
               "B_in":B_in,
               "B_wren":B_wren,
               "B_out":B_out,
               "name":name}
    return template.substitute(entries)

def all_node_instances(width, depth, base_cpu, nodes):
    all_nodes = []
    for row in range(depth):
        for column in range(width):
            node = nodes[row][column]
            # Offset by one row and column into middle of extended mesh
            # XXX Add longest vert/horiz hop to deal with topologies with skips
            instance = node_instance(column+1, row+1, base_cpu, node["CPU_OVERRIDES"], node["NAME"])
            all_nodes.append(instance)
    all_nodes = "\n".join(all_nodes)
    return all_nodes

def edge_port_counts(connect):
    """Assumes a rectangular grid: top == bottom, left == right"""
    top_ports, bottom_ports, left_ports, right_ports = (0, 0, 0, 0)
    column, row = connect
    if row < 0:
        top_ports += 1
    if row > 0:
        bottom_ports += 1
    if column < 0:
        left_ports += 1
    if column > 0:
        right_ports += 1
    return (top_ports, bottom_ports, left_ports, right_ports)

def edge_all_port_counts(connects):
    all_counts = [0, 0, 0, 0]
    for connect in connects:
        counts = edge_port_counts(connect)
        all_counts = [a + b for a, b in zip(counts, all_counts)]
    return tuple(all_counts)

def node_connections(port_name, port_index, pipe, connect):
    node_connections_template = string.Template(
"""// *** Port ${port_name}_${port_index} ***
generate
    for (row = 0; row < EXTENDED_MESH_DEPTH; row = row + 1) begin : node_connection_${port_name}_${port_index}_row
        for (column = 0; column < EXTENDED_MESH_WIDTH; column = column + 1) begin : node_connection_${port_name}_${port_index}_column

            // *** NODE-TO-NODE ***
            // If we are a real node, do port_out --> simple_link --> port_in
            if(is_inner_node(column, row)) begin : simple_link
                simple_link
                #(
                    .DEPTH (${pipe}),
                    .WIDTH (${port_name}_WORD_WIDTH)
                )
                sl_${port_name}_${port_index}
                (
                    .clock (clock),
                    .in    (${port_name}_out[column][row][${port_index}]),
                    // Shift access into the smaller wren wire array
                    .wren  (${port_name}_wren[hidden_index(column-1)][hidden_index(row-1)][${port_index}]),
                    .out   (${port_name}_in[hidden_index(column + ${column_offset})][hidden_index(row + ${row_offset})][${port_index}])
                );
            end
            // Otherwise do port_out --> port_in, if we are not pointing past edge and not to an inner node
            else begin
                if(!is_past_edge(column + ${column_offset}, row + ${row_offset}) &&
                   !is_inner_node(column + ${column_offset}, row + ${row_offset}))
                begin : node_patch_wire
                    assign ${port_name}_in[hidden_index(column + ${column_offset})][hidden_index(row + ${row_offset})][${port_index}] = ${port_name}_out[column][row][${port_index}];
                end
            end

            // *** EDGE-TO-NODE ***
            // If we are at the edge, and pointing to a node, do edge_port_out --> delay_line --> node_port_in
            // This is to balance out the converse node_port_out --> simple_link --> edge_port_in path.
            if(!is_past_edge(column, row) &&
               !is_inner_node(column, row) &&
               is_inner_node(column + ${column_offset}, row + ${row_offset}))
            begin : edge_delay_line
                delay_line
                #(
                    // Always at least 1 stage to match simple_link
                    .DEPTH (${pipe} + 1),
                    .WIDTH (${port_name}_WORD_WIDTH)
                )
                dl_${port_name}_${port_index}
                (
                    .clock (clock),
                    .in    (${port_name}_out[column][row][${port_index}]),
                    .out   (${port_name}_in[hidden_index(column + ${column_offset})][hidden_index(row + ${row_offset})][${port_index}])
                );
            end

            // *** EDGE-INPUT-TO-EDGE-OUTPUT ***
            // If we are at the edge, do edge_port_in --> edge_port_out within this position
            if(!is_past_edge(column, row) &&
               !is_inner_node(column, row))
            begin : edge_patch_wire
                assign ${port_name}_out[column][row][${port_index}] = ${port_name}_in[column][row][${port_index}];
            end            

            localparam port_top_${port_name}_${port_index}    = ${port_top};
            localparam port_bottom_${port_name}_${port_index} = ${port_bottom};
            localparam port_left_${port_name}_${port_index}   = ${port_left};
            localparam port_right_${port_name}_${port_index}  = ${port_right};

            // *** EDGE-OUTPUT-TO-IO ***
            // If we are at the edge, map edge_port_out --> module_io_out
            if(port_top_${port_name}_${port_index} > 0 && row == 0) begin : port_top_output_patch_wire
                assign ${port_name}_io_out[((EXTENDED_MESH_WIDTH + column) * ${port_name}_WORD_WIDTH) +: ${port_name}_WORD_WIDTH] = ${port_name}_out[column][row][${port_index}];
            end            
            if(port_bottom_${port_name}_${port_index} > 0 && row == EXTENDED_MESH_DEPTH-1) begin : port_bottom_output_patch_wire
                assign ${port_name}_io_out[((0 + column) * ${port_name}_WORD_WIDTH) +: ${port_name}_WORD_WIDTH] = ${port_name}_out[column][row][${port_index}];
            end            
            if(port_left_${port_name}_${port_index} > 0 && column == 0) begin : port_left_output_patch_wire
                assign ${port_name}_io_out[((EXTENDED_MESH_DEPTH + row) * ${port_name}_WORD_WIDTH) +: ${port_name}_WORD_WIDTH] = ${port_name}_out[column][row][${port_index}];
            end            
            if(port_right_${port_name}_${port_index} > 0 && column == EXTENDED_MESH_WIDTH-1) begin : port_right_output_patch_wire
                assign ${port_name}_io_out[((0 + row) * ${port_name}_WORD_WIDTH) +: ${port_name}_WORD_WIDTH] = ${port_name}_out[column][row][${port_index}];
            end            

            // *** IO-TO-EDGE-INPUT ***
            // If we are at the extended edge, map module_io_in --> edge_port_in
            // XXX This is hackish and dependent on the notion that the input port is opposite the output port
            if(port_bottom_${port_name}_${port_index} > 0 && row == 0) begin : port_top_input_patch_wire
                assign ${port_name}_in[column][row][${port_index}] = ${port_name}_io_in[((0 + column) * ${port_name}_WORD_WIDTH) +: ${port_name}_WORD_WIDTH];
            end            
            if(port_top_${port_name}_${port_index} > 0 && row == EXTENDED_MESH_DEPTH-1) begin : port_bottom_input_patch_wire
                assign ${port_name}_in[column][row][${port_index}] = ${port_name}_io_in[((EXTENDED_MESH_WIDTH + column) * ${port_name}_WORD_WIDTH) +: ${port_name}_WORD_WIDTH];
            end            
            if(port_right_${port_name}_${port_index} > 0 && column == 0) begin : port_left_input_path_wire
                assign ${port_name}_in[column][row][${port_index}] = ${port_name}_io_in[((0 + row) * ${port_name}_WORD_WIDTH) +: ${port_name}_WORD_WIDTH];
            end            
            if(port_left_${port_name}_${port_index} > 0 && column == EXTENDED_MESH_WIDTH-1) begin : port_right_input_patch_wire
                assign ${port_name}_in[column][row][${port_index}] = ${port_name}_io_in[((EXTENDED_MESH_DEPTH + row) * ${port_name}_WORD_WIDTH) +: ${port_name}_WORD_WIDTH];
            end            

        end
    end
endgenerate
""")
    column_offset, row_offset = connect
    port_top, port_bottom, port_left, port_right = edge_port_counts(connect)
    entries = {"port_name":port_name,
               "port_index":port_index,
               "pipe":pipe,
               "column_offset":column_offset,
               "row_offset":row_offset,
               "port_top":port_top,
               "port_bottom":port_bottom,
               "port_left":port_left,
               "port_right":port_right}
    return node_connections_template.substitute(entries)

def all_node_connections(port_name, pipes, connects):
    all_node_connections = []
    port_count = len(pipes)
    for port_index, pipe, connect in zip(range(port_count), pipes, connects):
        connections = node_connections(port_name, port_index, pipe, connect)
        all_node_connections.append(connections)
    all_node_connections = "\n".join(all_node_connections)
    return all_node_connections

def all_ports_node_connections(topology):
    all_port_connections = []
    for port_entry in topology:
        for port, connections in port_entry.items():
            port_connections = all_node_connections(port, connections["PIPE"], connections["CONNECTS"])
            all_port_connections.append(port_connections)
    all_port_connections = "\n".join(all_port_connections)
    return all_port_connections

def definition(parameters):
    definition_template = string.Template(
"""module ${MESH_NAME}
#(
    parameter       MESH_WIDTH                  = ${MESH_WIDTH},
    parameter       MESH_DEPTH                  = ${MESH_DEPTH},

    parameter       A_WORD_WIDTH                = ${A_WORD_WIDTH},
    parameter       A_IO_READ_PORT_COUNT        = ${A_IO_READ_PORT_COUNT},
    parameter       A_IO_WRITE_PORT_COUNT       = ${A_IO_WRITE_PORT_COUNT},

    parameter       B_WORD_WIDTH                = ${B_WORD_WIDTH},
    parameter       B_IO_READ_PORT_COUNT        = ${B_IO_READ_PORT_COUNT},
    parameter       B_IO_WRITE_PORT_COUNT       = ${B_IO_WRITE_PORT_COUNT},

    parameter       DATAPATH_COUNT              = ${DATAPATH_COUNT},

    parameter       A_IO_READ_PORT_COUNT_TOTAL  = (A_IO_READ_PORT_COUNT  * DATAPATH_COUNT),
    parameter       A_IO_WRITE_PORT_COUNT_TOTAL = (A_IO_WRITE_PORT_COUNT * DATAPATH_COUNT),

    parameter       B_IO_READ_PORT_COUNT_TOTAL  = (B_IO_READ_PORT_COUNT  * DATAPATH_COUNT),
    parameter       B_IO_WRITE_PORT_COUNT_TOTAL = (B_IO_WRITE_PORT_COUNT * DATAPATH_COUNT),    

    // Add extra rows/columns on each side to support I/O wires, which would otherwise index out of bounds.
    // All wires will end up connected, though many edge ones will connect an input pin to an output pin without logic in between.
    parameter       EXTENDED_MESH_DEPTH         = 1 + MESH_DEPTH + 1,
    parameter       EXTENDED_MESH_WIDTH         = 1 + MESH_WIDTH + 1,

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

    parameter       A_IO_READ_WIDTH             = A_WORD_WIDTH * A_EDGE_PORTS_COUNT,
    parameter       A_IO_WRITE_WIDTH            = A_WORD_WIDTH * A_EDGE_PORTS_COUNT,

    parameter       B_IO_READ_WIDTH             = B_WORD_WIDTH * B_EDGE_PORTS_COUNT,
    parameter       B_IO_WRITE_WIDTH            = B_WORD_WIDTH * B_EDGE_PORTS_COUNT
)
(
    input   wire                                clock,
    input   wire                                half_clock,

    // View each of these as one vector outside the extended mesh connecting to the edge ports
    input   wire    [A_IO_READ_WIDTH-1:0]    A_io_in,
    output  wire    [A_IO_WRITE_WIDTH-1:0]   A_io_out,

    input   wire    [B_IO_READ_WIDTH-1:0]    B_io_in,
    output  wire    [B_IO_WRITE_WIDTH-1:0]   B_io_out    
);
    // wren wires don't leave mesh, so are not extended into edge wires. Access with a -1 column/row offset.
    wire    [A_WORD_WIDTH-1:0] A_in     [EXTENDED_MESH_WIDTH-1:0][EXTENDED_MESH_DEPTH-1:0][A_IO_READ_PORT_COUNT-1:0];
    wire    [A_WORD_WIDTH-1:0] A_out    [EXTENDED_MESH_WIDTH-1:0][EXTENDED_MESH_DEPTH-1:0][A_IO_WRITE_PORT_COUNT-1:0];
    wire                       A_wren   [MESH_WIDTH-1:0][MESH_DEPTH-1:0][A_IO_WRITE_PORT_COUNT-1:0];

    wire    [A_WORD_WIDTH-1:0] B_in     [EXTENDED_MESH_WIDTH-1:0][EXTENDED_MESH_DEPTH-1:0][A_IO_READ_PORT_COUNT-1:0];
    wire    [A_WORD_WIDTH-1:0] B_out    [EXTENDED_MESH_WIDTH-1:0][EXTENDED_MESH_DEPTH-1:0][A_IO_WRITE_PORT_COUNT-1:0];
    wire                       B_wren   [MESH_WIDTH-1:0][MESH_DEPTH-1:0][A_IO_WRITE_PORT_COUNT-1:0];

${node_instances}

    // *** Tests for when generating connections ***
    
    function is_inner_node(input integer column, row);
        is_inner_node = (column >= 1 && column <= MESH_WIDTH && row >= 1 && row <= MESH_DEPTH);
    endfunction

    function is_past_edge(input integer column, row);
        is_past_edge = (column < 0 || column > EXTENDED_MESH_WIDTH-1 || row < 0 || row > EXTENDED_MESH_DEPTH-1);
    endfunction

    // Modelsim complains about unreachable out-of-bounds by +/-1 indices. Hide them. :P
    function integer hidden_index(input integer index);
        hidden_index = index;
    endfunction

// Apparently, generate blocks don't scope their genvars...
genvar column, row;

${node_connections}

endmodule
""")
    width, depth        = mesh_parameters.mesh_dimensions(parameters)
    mesh_name           = parameters["NAME"]
    base_cpu            = parameters["BASE_CPU"]
    node_instances      = misc.indent(all_node_instances(width, depth, base_cpu, parameters["NODES"]))
    node_connections    = misc.indent(all_ports_node_connections(parameters["TOPOLOGY"].values()))
    A_top_ports, A_bottom_ports, A_left_ports, A_right_ports = edge_all_port_counts(parameters["TOPOLOGY"].values()[0]["A"]["CONNECTS"])
    B_top_ports, B_bottom_ports, B_left_ports, B_right_ports = edge_all_port_counts(parameters["TOPOLOGY"].values()[0]["B"]["CONNECTS"])
    entries = {"MESH_WIDTH":width,
               "MESH_DEPTH":depth,
               "MESH_NAME":mesh_name,
               "A_WORD_WIDTH":base_cpu["A_WORD_WIDTH"],
               "A_IO_READ_PORT_COUNT":base_cpu["A_IO_READ_PORT_COUNT"],
               "A_IO_WRITE_PORT_COUNT":base_cpu["A_IO_WRITE_PORT_COUNT"],
               "B_WORD_WIDTH":base_cpu["B_WORD_WIDTH"],
               "B_IO_READ_PORT_COUNT":base_cpu["B_IO_READ_PORT_COUNT"],
               "B_IO_WRITE_PORT_COUNT":base_cpu["B_IO_WRITE_PORT_COUNT"],
               "DATAPATH_COUNT":base_cpu["DATAPATH_COUNT"],
               "node_instances":node_instances,
               "node_connections":node_connections,
               "A_top_ports":A_top_ports,
               "A_bottom_ports":A_bottom_ports,
               "A_left_ports":A_left_ports,
               "A_right_ports":A_right_ports,
               "B_top_ports":B_top_ports,
               "B_bottom_ports":B_bottom_ports,
               "B_left_ports":B_left_ports,
               "B_right_ports":B_right_ports}
    definition = definition_template.substitute(entries)
    return definition

if __name__ == "__main__":
    all_parameters = mesh_parameters.all_parameters(parameters = {"BASE_CPU":"Octavo_A2in2out_B2in2out",
                                                                  "COLUMNS":3,
                                                                  "ROWS":3,
                                                                  "TOPOLOGY":"SQUARE"})
    mesh_definition = definition(all_parameters)
    print mesh_definition

