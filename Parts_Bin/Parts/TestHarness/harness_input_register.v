
// Converts a single input bit into a word, so that no hardware gets optimized
// away during synthesis. Allows testing without running out of pins.

module harness_input_register
#(
    parameter   integer WIDTH           = 0
)
(
    input       wire                    clock,    
    input       wire                    in,
    input       wire                    rden,
    output      reg     [WIDTH-1:0]     out
);
    always @(posedge clock) begin
        out <= (rden == 1'b1) ? out << 1 | in : out;
    end
endmodule

