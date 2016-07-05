
module Dyadic_Boolean_Operator_test_harness
#(
    parameter   WORD_WIDTH = 36
)
(
    input   wire    clock,
    input   wire    test_op,
    input   wire    test_a,
    input   wire    test_b,
    output  wire    test_o
);

    localparam OP_WIDTH = 4;

// --------------------------------------------------------------------

    wire    [OP_WIDTH-1:0]      test_op_dut;
    wire    [WORD_WIDTH-1:0]    test_a_dut;
    wire    [WORD_WIDTH-1:0]    test_b_dut;
    wire    [WORD_WIDTH-1:0]    test_o_dut;

    Dyadic_Boolean_Operator
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    DUT
    (
        .op         (test_op_dut),
        .a          (test_a_dut),
        .b          (test_b_dut),
        .o          (test_o_dut)
    );

// --------------------------------------------------------------------

    harness_input_register
    #(
        .WIDTH  (OP_WIDTH)
    )
    op
    (
        .clock  (clock),    
        .in     (test_op),
        .rden   (1'b1),
        .out    (test_op_dut)
    );

    harness_input_register
    #(
        .WIDTH  (WORD_WIDTH)
    )
    a
    (
        .clock  (clock),    
        .in     (test_a),
        .rden   (1'b1),
        .out    (test_a_dut)
    );

    harness_input_register
    #(
        .WIDTH  (WORD_WIDTH)
    )
    b
    (
        .clock  (clock),    
        .in     (test_b),
        .rden   (1'b1),
        .out    (test_b_dut)
    );

    harness_output_register 
    #(
        .WIDTH  (WORD_WIDTH)
    )
    o
    (
        .clock  (clock),
        .in     (test_o_dut),
        .wren   (1'b1),
        .out    (test_o)
    );

endmodule

