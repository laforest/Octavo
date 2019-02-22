
// A configurable multi-stage pipeline, with no logic.
// Allows easy adjustments via parameter calculations.
// This is very useful to align various signals along a pipeline.

`default_nettype none

module Delay_Line 
#(
    parameter       DEPTH           = 0, 
    parameter       WIDTH           = 0
) 
(
    // Not used if DEPTH is zero
    // verilator lint_off UNUSED
    input   wire                    clock,
    // verilator lint_on  UNUSED
    input   wire    [WIDTH-1:0]     in,
    output  reg     [WIDTH-1:0]     out
);

// --------------------------------------------------------------------------

    localparam ZERO = {WIDTH{1'b0}};

    initial begin
        out = ZERO;
    end

// --------------------------------------------------------------------------

    generate
        if (DEPTH == 0) begin
            always @(*) begin
                out = in;
            end
        end
        else begin
            integer i;

            reg [WIDTH-1:0] stage [DEPTH-1:0];

            initial begin
                for(i = 0; i < DEPTH; i = i + 1) begin
                    stage[i] = ZERO;
                end
            end 

            always @(posedge clock) begin
                stage[0] <= in;
                for(i = 1; i < DEPTH; i = i + 1) begin
                    stage[i] <= stage[i-1];
                end
            end

            always @(*) begin
                out = stage[DEPTH-1];
            end
        end
    endgenerate

endmodule

