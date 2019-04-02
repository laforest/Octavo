
// Sums 8 values to a single one, using a tree reduction. Adjusted to do so in 8 cycles.
// Use: hook to 8 write ports, can read reduction result next thread cycle.

`default_nettype none

module Add_Reducer
#(
    parameter WORD_WIDTH = 36,
    parameter ADDENDS    = 8  // ECL XXX Hardcoded for now
)
(
    input   wire                                    clock,
	input   wire    [(ADDENDS * WORD_WIDTH)-1:0]    addends,
	output  wire    [WORD_WIDTH-1:0]                reduction
);

// -----------------------------------------------------------

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ECL XXX FIXME I have no idea why:
// ECL XXX FIXME The first instance always has DEPTH-1 or 0 for no reason.
// ECL XXX FIXME This 0-DEPTH instance solely exists to contain the bug
// ECL XXX FIXME which manifests in both Modelsim and Icarus Verilog
// ECL XXX FIXME but not Quartus.
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    wire [(ADDENDS * WORD_WIDTH)-1:0] addends_delayed;

    delay_line 
    #(
        .DEPTH  (0),
        .WIDTH  (WORD_WIDTH)
    ) 
    addends_pipeline [ADDENDS-1:0]
    (
        .clock  (clock),
        .in     (addends),
        .out    (addends_delayed)
    );

// -----------------------------------------------------------

    wire [(ADDENDS * WORD_WIDTH)-1:0] addends_delayed_2;

    delay_line 
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    ) 
    addends_pipeline_2 [ADDENDS-1:0]
    (
        .clock  (clock),
        .in     (addends_delayed),
        .out    (addends_delayed_2)
    );

// -----------------------------------------------------------

    wire [((ADDENDS/2) * WORD_WIDTH)-1:0] partial_reduction_1;

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    AR_Layer_1 [(ADDENDS/2)-1:0]
    (
        .clock      (clock),
        .add_sub    (`HIGH),
        .cin        (`LOW),
        .dataa      (addends_delayed_2 [0 +: ((ADDENDS/2) * WORD_WIDTH)]),
        .datab      (addends_delayed_2 [((ADDENDS/2) * WORD_WIDTH) +: ((ADDENDS/2) * WORD_WIDTH)]),
        .cout       (),
        .result     (partial_reduction_1)
    );

// -----------------------------------------------------------

    wire [((ADDENDS/4) * WORD_WIDTH)-1:0] partial_reduction_2;

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    AR_Layer_2 [(ADDENDS/4)-1:0]
    (
        .clock      (clock),
        .add_sub    (`HIGH),
        .cin        (`LOW),
        .dataa      (partial_reduction_1 [0 +: ((ADDENDS/4) * WORD_WIDTH)]),
        .datab      (partial_reduction_1 [((ADDENDS/4) * WORD_WIDTH) +: ((ADDENDS/4) * WORD_WIDTH)]),
        .cout       (),
        .result     (partial_reduction_2)
    );

// -----------------------------------------------------------

    wire [((ADDENDS/8) * WORD_WIDTH)-1:0] partial_reduction_3;

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    AR_Layer_3 [(ADDENDS/8)-1:0]
    (
        .clock      (clock),
        .add_sub    (`HIGH),
        .cin        (`LOW),
        .dataa      (partial_reduction_2 [0 +: ((ADDENDS/8) * WORD_WIDTH)]),
        .datab      (partial_reduction_2 [((ADDENDS/8) * WORD_WIDTH) +: ((ADDENDS/8) * WORD_WIDTH)]),
        .cout       (),
        .result     (partial_reduction_3)
    );

// -----------------------------------------------------------

    delay_line 
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    ) 
    reduction_pipeline
    (
        .clock  (clock),
        .in     (partial_reduction_3),
        .out    (reduction)
    );

endmodule

