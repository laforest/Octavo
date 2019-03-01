
module cdc_pulse_synchronizer_example
#(
    parameter PULSE_LENGTH = 3,
    parameter EXTRA_DEPTH  = 1
)
(
    input   wire    clock_from,
    input   wire    pulse_from,
    input   wire    clock_to,
    output  wire    pulse_to
);

    cdc_pulse_synchronizer
    #(
        .PULSE_LENGTH   (PULSE_LENGTH),
        .EXTRA_DEPTH    (EXTRA_DEPTH)
    )
    example
    (
        .clock_from     (clock_from),
        .pulse_from     (pulse_from),
        .clock_to       (clock_to),
        .pulse_to       (pulse_to)
    );

endmodule

