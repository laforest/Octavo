
// One-Hot Multiplexer, where a set selector bit brings out its associated
// word to the output.

// If more than one selector bit is set, the output is the bitwise OR of the
// associated words.

`default_nettype none

module One_Hot_Mux
#(
    parameter       WORD_WIDTH                      = 0,
    parameter       WORD_COUNT                      = 0
)
(
    input   wire    [WORD_COUNT-1:0]                selectors,
    input   wire    [(WORD_COUNT*WORD_WIDTH)-1:0]   in,
    output  wire    [WORD_WIDTH-1:0]                out
);

// --------------------------------------------------------------------

    wire [(WORD_COUNT*WORD_WIDTH)-1:0] selected_in;

    Annuller
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Select_Input    [WORD_COUNT-1:0]
    (
        .annul       (~selectors),
        .in          (in),
        .out         (selected_in)
    );

// --------------------------------------------------------------------

    Word_OR_Reducer
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .WORD_COUNT (WORD_COUNT)
    )
    Merge
    (
        .in          (selected_in),
        .out         (out)
    );

endmodule
