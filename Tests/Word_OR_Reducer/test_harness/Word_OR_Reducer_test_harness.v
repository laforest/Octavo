
module Word_OR_Reducer_test_harness
#(
    parameter   WORD_WIDTH = 36,
    parameter   WORD_COUNT = 16
)
(
    input   wire    clock,
    input   wire    in,
    output  wire    out
);

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    wire [WORD_WIDTH*WORD_COUNT-1:0]    dut_in;
    wire [WORD_WIDTH-1:0]               dut_out;

    Word_OR_Reducer
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .WORD_COUNT (WORD_COUNT)
    )
    DUT
    (
        .in         (dut_in),
        .out        (dut_out)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    // Tie-off and register inputs and outputs to get a valid timing analysis.

    harness_input_register
    #(
        .WIDTH  (WORD_WIDTH*WORD_COUNT)
    )
    i
    (
        .clock  (clock),    
        .in     (in),
        .rden   (1'b1),
        .out    ({dut_in})
    );


    harness_output_register 
    #(
        .WIDTH  (WORD_WIDTH)
    )
    o
    (
        .clock  (clock),
        .in     ({dut_out}),
        .wren   (1'b1),
        .out    (out)
    );

endmodule

