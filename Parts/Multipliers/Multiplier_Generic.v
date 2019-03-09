
// Generic description for an optionally pipelined
// full-word multiplier, signed or unsigned.
// Meant for simulation, but might synthesize well too.

// {R_high, R_low} = A * B;

`default_nettype none

module Multiplier_Generic
#(
    parameter WORD_WIDTH                = 0,
    parameter PIPELINE_DEPTH            = 0
)
(
    input   wire                        clock,
    input   wire                        is_signed,
    input   wire    [WORD_WIDTH-1:0]    A,
    input   wire    [WORD_WIDTH-1:0]    B,
    output  wire    [WORD_WIDTH-1:0]    R_low,
    output  wire    [WORD_WIDTH-1:0]    R_high
);

// --------------------------------------------------------------------------

    // Let's always do a full multiplication.
    // The enclosing module can pick a subset if it wants to.
    localparam OUTPUT_WIDTH = WORD_WIDTH * 2;
    localparam RESULT_ZERO  = {OUTPUT_WIDTH{1'b0}};

    reg [OUTPUT_WIDTH-1:0] result = RESULT_ZERO;

    always @(*) begin
        result = (is_signed == 1'b1) ? $signed(A) * $signed(B) : A * B;
    end

// --------------------------------------------------------------------------

    // Pipeline the result. These should get retimed if synthesized.

    Delay_Line
    #(
        .DEPTH  (PIPELINE_DEPTH),
        .WIDTH  (OUTPUT_WIDTH)
    )
    pipeline_stages
    (
        .clock  (clock),
        .in     (result),
        .out    ({R_high, R_low})
    );

endmodule

