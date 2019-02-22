
// Expands a single input bit into a word, so that no hardware gets optimized
// away during synthesis. Allows testing without running out of pins.

`default_nettype none

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

// --------------------------------------------------------------------

    localparam ZERO         = {WIDTH{1'b0}};
    localparam SHORT_ZERO   = {WIDTH-1{1'b0}};

    reg [WIDTH-1:0] in_extended = ZERO;

    always @(*) begin
        in_extended = {SHORT_ZERO, in};
    end

    always @(posedge clock) begin
        out <= (rden == 1'b1) ? (out << 1 | in_extended) : out;
    end
endmodule

