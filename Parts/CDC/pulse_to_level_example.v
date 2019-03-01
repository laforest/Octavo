
`default_nettype none

module pulse_to_level_example
// No parameters
(
    input   wire    clock,
    input   wire    clear,
    input   wire    pulse_in,
    output  reg     level_out
);

    pulse_to_level
    example
    (
        .clock      (clock),
        .clear      (clear),
        .pulse_in   (pulse_in),
        .level_out  (level_out)
    );

endmodule

