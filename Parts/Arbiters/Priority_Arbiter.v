
// Simple priority arbiter.
// Returns the LSB set, where bit 0 has highest priority
// Core logic from Hacker's Delight, Chapter 2.

`default_nettype none

module Priority_Arbiter
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    requests,
    output  reg     [WORD_WIDTH-1:0]    grant
);

    localparam ZERO = {WORD_WIDTH{1'b0}};

    initial begin
        grant = ZERO;
    end

    always @(*) begin
        grant = requests & -requests;
    end

endmodule

