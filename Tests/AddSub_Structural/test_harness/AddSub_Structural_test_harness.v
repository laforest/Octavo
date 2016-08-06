
module AddSub_Structural_test_harness
#(
    parameter   WORD_WIDTH = 36
)
(
    input   wire    clock,
    input   wire    in,
    output  wire    out
);

// --------------------------------------------------------------------

    wire                            sub_add_dut;
    wire                            carry_in_dut;
    wire [WORD_WIDTH-1:0]           A_dut;
    wire [WORD_WIDTH-1:0]           B_dut;
    wire [WORD_WIDTH-1:0]           sum_dut;
    wire                            carry_out_dut;

    AddSub_Structural
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    DUT
    (
        .sub_add    (sub_add_dut),
        .carry_in   (carry_in_dut),
        .A          (A_dut),      
        .B          (B_dut),      
        .sum        (sum_dut),      
        .carry_out  (carry_out_dut)
    );

// --------------------------------------------------------------------

    // Tie-off and register inputs and outputs to get a valid timing analysis.

    harness_input_register
    #(
        .WIDTH  ((WORD_WIDTH * 2) + 2)
    )
    i
    (
        .clock  (clock),    
        .in     (in),
        .rden   (1'b1),
        .out    ({sub_add_dut, carry_in_dut, A_dut, B_dut})
    );


    harness_output_register 
    #(
        .WIDTH  ((WORD_WIDTH) + 1)
    )
    o
    (
        .clock  (clock),
        .in     ({sum_dut, carry_out_dut}),
        .wren   (1'b1),
        .out    (out)
    );

endmodule

