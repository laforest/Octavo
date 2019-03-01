
module posedge_pulse_generator_example
#(
    parameter PULSE_LENGTH = 3
)
(
    input   wire    clock,
    input   wire    level_in,
    output  reg     pulse_out
);

    posedge_pulse_generator
    #(
        .PULSE_LENGTH   (PULSE_LENGTH)
    )
    example
    (
        .clock          (clock),
        .level_in       (level_in),
        .pulse_out      (pulse_out)
    );

endmodule

