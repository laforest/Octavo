
`default_nettype none

module harness_example
#(
    parameter   WORD_WIDTH  = 36,
    parameter   ADDR_WIDTH  = 24
)
(
    input   wire                    clock,
    input   wire                    test_in,
    output  wire                    test_out,

    // These are only here so the "input" signal are used
    // in this example. Normally not here, and sent to
    // the DUT.
    output  reg [WORD_WIDTH-1:0]    word_out,
    output  reg [ADDR_WIDTH-1:0]    addr_out
);

// --------------------------------------------------------------------

    localparam INPUT_WIDTH  = WORD_WIDTH + ADDR_WIDTH;
    localparam OUTPUT_WIDTH = WORD_WIDTH + ADDR_WIDTH;

    wire    [INPUT_WIDTH-1:0]   test_input;
    reg     [OUTPUT_WIDTH-1:0]  test_output;

// --------------------------------------------------------------------

    localparam WORD_ZERO = {WORD_WIDTH{1'b0}};
    localparam ADDR_ZERO = {ADDR_WIDTH{1'b0}};

    reg [WORD_WIDTH-1:0] some_word_input = WORD_ZERO;
    reg [ADDR_WIDTH-1:0] some_addr_input = ADDR_ZERO;

    reg [WORD_WIDTH-1:0] some_word_output = WORD_ZERO;
    reg [ADDR_WIDTH-1:0] some_addr_output = ADDR_ZERO;

    always @(*) begin
        {some_word_input, some_addr_input} = test_input;
        test_output = {some_word_output, some_addr_output};
    end

    // Only for this example, so signals are used.
    always @(*) begin
        word_out = some_word_input;
        addr_out = some_addr_input;
    end

// --------------------------------------------------------------------
// Test Harness Registers

    harness_input_register
    #(
        .WIDTH  (INPUT_WIDTH)
    )
    harness_in
    (
        .clock  (clock),
        .in     (test_in),
        .rden   (1'b1),
        .out    (test_input)
    );

    harness_output_register
    #(
        .WIDTH  (OUTPUT_WIDTH)
    )
    harness_out
    (
        .clock  (clock),
        .in     (test_output),
        .wren   (1'b1),
        .out    (test_out)
    );

endmodule

