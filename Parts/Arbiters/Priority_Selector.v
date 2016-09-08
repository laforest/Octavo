
// Priority Selector, where each selector bit brings out its corresponding
// data word to the output, but the selector bits are first filtered through
// a Priority Arbiter. Thus, the highest priority selector bit wins.
// Bit 0 has highest priority, selecting the lowest (zeroth) word.

// This implementation has a log depth on the datapath instead of the linear
// depth of a chain of multiplexers. However, there is a linear depth
// carry-chain implicit in the negation inside the Priority_Arbiter, which
// should get either optimized away, or mapped to fast carry-chain hardware.

// Henry Wong reports that Quartus destroys plain trees of multiplexers,
// reverting them to linear chains.

// You may want to substitute a structural priority arbiter if that allows
// a better logic optimization.

module Priority_Selector
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

    wire [WORD_COUNT-1:0] one_hot_selector;

    Priority_Arbiter
    #(
        .WORD_WIDTH (WORD_COUNT)
    )
    Selector_Filter
    (
        .requests   (selectors) ,
        .grant      (one_hot_selector)
    );

// --------------------------------------------------------------------

    wire [(WORD_COUNT*WORD_WIDTH)-1:0] selected_in

    Annuller
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Select_Input    [WORD_COUNT-1:0]
    (
        annul       (~one_hot_selector),
        in          (in),
        out         (selected_in)
    );

// --------------------------------------------------------------------

    Word_OR_Reducer
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .WORD_COUNT (WORD_COUNT)
    )
    Merge
    (
        in          (selected_in),
        out         (out)
    );

endmodule
