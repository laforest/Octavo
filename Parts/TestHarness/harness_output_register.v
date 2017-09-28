
// Reduces a word-wide register into a single bit.  This prevents
// optimizations, and allows testing without running out of pins.

`default_nettype none

module harness_output_register 
#(
    parameter   integer WIDTH           = 0
)
(
    input       wire                    clock,
    input       wire    [WIDTH-1:0]     in,
    input       wire                    wren,
    output      reg                     out
);
    reg [WIDTH-1:0] out_reg;

    always @(posedge clock) begin
        out_reg <= (wren == 1'b1) ? in : out_reg;
    end

    always @(*) begin
        out <= &out_reg;
    end
endmodule

