
// See Condition_Predicate.v

`ifndef CONDITION_PREDICATE_OPERATIONS
`define CONDITION_PREDICATE_OPERATIONS

    // Never changes
    `define GROUP_SELECTOR_WIDTH    2

    // First, the A/B group condition flag selectors

    `define A_GROUP_NEGATIVE        2'd0
    `define A_GROUP_CARRYOUT        2'd1
    `define A_GROUP_SENTINEL        2'd2
    `define A_GROUP_EXTERNAL        2'd3

    `define B_GROUP_LESSTHAN        2'd0
    `define B_GROUP_COUNTER         2'd1
    `define B_GROUP_SENTINEL        2'd2
    `define B_GROUP_EXTERNAL        2'd3

    // Second, for the combining stage

    `include "Dyadic_Boolean_Operations.vh"

`endif
