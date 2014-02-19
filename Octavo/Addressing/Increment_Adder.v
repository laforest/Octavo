
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
    reg     [OFFSET_WORD_WIDTH-1:0]    offset_out_raw;

    // ECL XXX Fix: add signed increment support
    always @(*) begin
        offset_out_raw <= offset_in + increment;
    end

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (OFFSET_WORD_WIDTH)
    )
    incr_adder_pipeline
    (
        .clock  (clock),
        .in     (offset_out_raw),
        .out    (offset_out)
    );
endmodule

