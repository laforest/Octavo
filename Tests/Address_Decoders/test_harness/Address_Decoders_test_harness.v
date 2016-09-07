
module Address_Decoders_test_harness
#(
    parameter   WORD_WIDTH = 36
)
(
    input   wire    clock,
    input   wire    in,
    output  wire    out
);

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    // We can only do one decoder at a time since we can't partition them, and
    // that makes measuring logic usage difficult.

    localparam [WORD_WIDTH-1:0] BASE  = 'd567;
    localparam [WORD_WIDTH-1:0] BOUND = 'd666;

    wire [WORD_WIDTH-1:0] addr_in;

    wire hit;

    Address_Decoder_Static
    #(
        .ADDR_WIDTH (WORD_WIDTH),
        .ADDR_BASE  (BASE),
        .ADDR_BOUND (BOUND)
    )
    Static
    (
        .addr       (addr_in),
        .hit        (hit)
    );

//    Address_Decoder_Arithmetic
//    #(
//        .ADDR_WIDTH (WORD_WIDTH)
//    )
//    Arith
//    (
//        .base_addr  (BASE),
//        .bound_addr (BOUND),
//        .addr       (addr_in),
//        .hit        (hit)
//    );

//    Address_Decoder_Arithmetic_Structural
//    #(
//        .ADDR_WIDTH (WORD_WIDTH)
//    )
//    Struct
//    (
//        .base_addr  (BASE),
//        .bound_addr (BOUND),
//        .addr       (addr_in),
//        .hit        (hit)
//    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    // Tie-off and register inputs and outputs to get a valid timing analysis.

    harness_input_register
    #(
        .WIDTH  (WORD_WIDTH)
    )
    i
    (
        .clock  (clock),    
        .in     (in),
        .rden   (1'b1),
        .out    ({addr_in})
    );


    harness_output_register 
    #(
        .WIDTH  (1)
    )
    o
    (
        .clock  (clock),
        .in     ({hit}),
        .wren   (1'b1),
        .out    (out)
    );

endmodule

