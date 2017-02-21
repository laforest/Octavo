
// Computes a true/false value based on a Boolean combination of selected
// input conditional predicates, each selected from one of two groups.  (See
// Hacker's Delight, 2-12) These groups form a bi-partite, fully connected
// graph

// This module can compute all signed/unsigned comparison predicates, as well
// as Boolean combinations with other inputs: sentinel values and timers
// (provided externally). The external input is for future expansion.
// (e.g.: chaining predicate calculations)

// The ALU provides the carryout and lessthan (Negative XOR Overflow)
// predicates.  Another module can calculate zero/negative, both usually from
// the previous instruction result.  Use a sentinel value as a zero-predicate.

// Total non-redundant predicates: 202 out of 256 (2 bits + 2 bits + 4 bits)
// (16 cases are always 0 or 1, keep 2 for use)
// (32 cases are always A or B, keep 8 for use, one per input)

module Condition_Predicate
(
    input   wire    [`GROUP_SELECTOR_WIDTH-1:0]     A_selector,
    input   wire                                    A_negative,
    input   wire                                    A_carryout,
    input   wire                                    A_sentinel,
    input   wire                                    A_external,
    input   wire    [`GROUP_SELECTOR_WIDTH-1:0]     B_selector,
    input   wire                                    B_lessthan,
    input   wire                                    B_counter,
    input   wire                                    B_sentinel,
    input   wire                                    B_external,
    input   wire    [`DYADIC_CTRL_WIDTH-1:0]        AB_operator,
    output  wire                                    predicate
);

// --------------------------------------------------------------------

    localparam WORD_WIDTH = 1; // Predicates are 1/0

// --------------------------------------------------------------------

    wire selected_A;

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (`GROUP_SELECTOR_WIDTH),
        .INPUT_COUNT    (2**`GROUP_SELECTOR_WIDTH)
    )
    Select_A
    (
        .addr           (A_selector),    
        .in             ({A_external,A_sentinel,A_carryout,A_negative}),
        .out            (selected_A)
    );

// --------------------------------------------------------------------

    wire selected_B;

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (`GROUP_SELECTOR_WIDTH),
        .INPUT_COUNT    (2**`GROUP_SELECTOR_WIDTH)
    )
    Select_B
    (
        .addr           (B_selector),    
        .in             ({B_external,B_sentinel,B_counter,B_lessthan}),
        .out            (selected_B)
    );

// --------------------------------------------------------------------

    Dyadic_Boolean_Operator
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    AB_Combiner
    (
        .op             (AB_operator),
        .a              (selected_A),
        .b              (selected_B),
        .o              (predicate)
    );

endmodule

