
// Latch pulse to level, until cleared

`default_nettype none

module pulse_to_level
// No parameters
(
    input   wire    clock,
    input   wire    clear,
    input   wire    pulse_in,
    output  reg     level_out
);

    initial begin
        level_out = 1'b0;
    end

    reg level_out_internal = 1'b0;

    always @(*) begin
        level_out_internal = pulse_in | level_out;
        level_out_internal = (clear == 1'b1) ? 1'b0 : level_out_internal;
    end

    always @(posedge clock) begin
        level_out <= level_out_internal;
    end

endmodule

