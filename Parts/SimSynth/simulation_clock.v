
// Clock generator for simulation

// The following are handy to use with the resulting clock:

// `define WAIT_CYCLES(n) repeat (n) begin @(posedge clock); end

// time cycle = 0; 
// `define UNTIL_CYCLE(n) wait (cycle == n);

`default_nettype none

`timescale 1 ns / 1 ps

module simulation_clock
#(
    parameter CLOCK_PERIOD = 0
)
(
    output reg clock
);

    localparam HALF_PERIOD = CLOCK_PERIOD / 2;

    // NOTE: clock is deliberately left uninitialized, and thus X in most
    // simulators, and will not trigger a (X -> 0) edge until after the
    // simulated clock half-period delay.

    always begin
        #HALF_PERIOD clock = (clock === 1'b0);
    end

endmodule

