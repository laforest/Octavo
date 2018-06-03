
// Master reset for IP that needs a reset to enter non-X initial state.
// Simply a delayed release, synchronous to the system clock, after the FPGA
// comes out of configuration reset.

module master_reset
#(
    parameter DELAY_CYCLE_COUNT = 0
)
(
    input   wire    clock,
    output  reg     reset
);

    initial begin
        reset = 0;
    end

    `include "clog2_function.vh"

    localparam                      COUNTER_WIDTH   = clog2(DELAY_CYCLE_COUNT);
    localparam                      COUNTER_ZERO    = {COUNTER_WIDTH{1'b0}};
    localparam                      COUNTER_ONE     = {{COUNTER_WIDTH-1{1'b0}},1'b1};
    localparam [COUNTER_WIDTH-1:0]  COUNTER_FINAL   = DELAY_CYCLE_COUNT-1;

    reg [COUNTER_WIDTH-1:0] count = COUNTER_ZERO;

    // Count N-1 times, and reset goes low one cycle later.
    // This keeps everything pipelined, and means reset stays high
    // for DELAY_CYCLE_COUNT cycles exactly.

    always @(posedge clock) begin
        count <= (count != COUNTER_FINAL) ? count + COUNTER_ONE : count;
        reset <= (count != COUNTER_FINAL);
    end

endmodule

