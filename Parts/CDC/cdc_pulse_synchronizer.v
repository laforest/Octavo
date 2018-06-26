
// Clock-Domain-Crossing (CDC) Pulse Synchronizer
// Passes a posedge pulse from a fast clock domain to a slow clock domain

// Since it takes time to cross domains, there is a limit to the pulse rate.

// This rate depends on both clock speeds, and the uncertainty in *when*
// the CDC occurs.

// If a second pulse arrives before the first one is ack'ed, it will be lost
// since the input latch is still set.

// If a second pulse arrives during the ack of the first pulse, it will be
// lost since the input latch is in reset.

// If the pulse is longer than the ack latency, it will be cut short by the
// input latch reset. This means a steady high input will generate a pulse
// train at the output.

// Recommended input is a single-cycle pulse in the fast clock domain.
// Adjust the output pulse length (in slow clock cycles) with the PULSE_LENGTH
// parameter.

`default_nettype none

module cdc_pulse_synchronizer
#(
    parameter PULSE_LENGTH = 0
)
(
    input   wire    clock_from,
    input   wire    pulse_from,
    input   wire    clock_to,
    output  wire    pulse_to
);

    // Latch the incoming fast pulse then wait for the ack to come back,
    // to show it was captured in the slow clock domain, to clear the latch.
    // We then convert the level to a single pulse in the slow domain.

    reg  pulse_from_level = 0;
    wire clear_latch;
    
    // Hopefully, this will synth to a sync reset on the register

    always @(posedge clock_from) begin
        pulse_from_level <= (clear_latch == 1'b1) ? 1'b0 : (pulse_from | pulse_from_level);
    end

    // Pass the latched pulse to the slow clock domain

    wire pulse_to_level;

    cdc_synchronizer
    sync_to
    (
        .data_from  (pulse_from_level),
        .clock_to   (clock_to),
        .data_to    (pulse_to_level)
    );

    // Now pass the sync'ed level back to the fast clock domain to signal
    // that the CDC is complete, and clear the latch.

    cdc_synchronizer
    sync_from
    (
        .data_from  (pulse_to_level),
        .clock_to   (clock_from),
        .data_to    (clear_latch)
    );

    // Convert the level to a pulse in the slow clock domain

    posedge_pulse_generator
    #(
        .PULSE_LENGTH   (PULSE_LENGTH)
    )
    pulse_to_generator
    (
        .clock          (clock_to),
        .level_in       (pulse_to_level),
        .pulse_out      (pulse_to)
    );

endmodule

