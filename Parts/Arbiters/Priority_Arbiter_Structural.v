
// Simple priority arbiter.
// Returns the LSB set, where bit 0 has highest priority
// Core logic from Hacker's Delight, Chapter 2.

module Priority_Arbiter_Structural
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    requests,
    output  reg     [WORD_WIDTH-1:0]    grant
);

// --------------------------------------------------------------------

    localparam zero = {WORD_WIDTH{1'b0}};

// --------------------------------------------------------------------

    // 0 - requests

    wire [WORD_WIDTH-1:0] requests_negated;

    AddSub_Structural
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Negater
    (
        .sub_add    (1'b1),    // 1/0 A-B/A+B
        .carry_in   (1'b0),
        .A          (zero),
        .B          (requests),
        .sum        (requests_negated),
        .carry_out  ()
    );

// --------------------------------------------------------------------

    always @(*) begin
        grant = requests & requests_negated;
    end

endmodule

