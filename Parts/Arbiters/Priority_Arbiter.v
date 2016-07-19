
// Simple priority arbiter.
// Returns the LSB set, where bit 0 has highest priority
// Core logic from Hacker's Delight, Chapter 2.

module Priority_Arbiter
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    requests,
    output  reg     [WORD_WIDTH-1:0]    grant
);

    always @(*) begin
        grant = requests & -requests;
    end

endmodule

