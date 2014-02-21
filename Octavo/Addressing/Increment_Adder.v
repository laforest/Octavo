
// Adds the post-increment to the programmed offset, between stages 2 and 3.

module Increment_Adder
#(
    parameter   OFFSET_WORD_WIDTH               = 0,
    parameter   INCREMENT_WORD_WIDTH            = 0
)
(
    input   wire                                clock,
    input   wire    [OFFSET_WORD_WIDTH-1:0]     offset_in,
    input   wire    [INCREMENT_WORD_WIDTH-1:0]  increment,
    output  wire    [OFFSET_WORD_WIDTH-1:0]     offset_out
);

// -----------------------------------------------------------

    wire    [OFFSET_WORD_WIDTH-1:0]     increment_reg;

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (INCREMENT_WORD_WIDTH)
    )
    increment_pipeline
    (
        .clock  (clock),
        .in     (increment),
        .out    (increment_reg)
    );

// -----------------------------------------------------------

    reg     [OFFSET_WORD_WIDTH-1:0]     offset_out_raw;

    // ECL XXX Fix: add signed increment support
    always @(*) begin
        offset_out_raw <= offset_in + increment_reg;
    end

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (OFFSET_WORD_WIDTH)
    )
    offset_out_pipeline
    (
        .clock  (clock),
        .in     (offset_out_raw),
        .out    (offset_out)
    );
`
endmodule

