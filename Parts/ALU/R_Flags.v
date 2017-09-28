
// Simple flag generator.
// Moved out of Triadic_ALU because word-wide operations like NOR-reduction
// cannot be folded into a 4:1 MUX, as the 6-LUT is already fully used.
// This created a critical path, with no room to pipeline in the ALU.
// Place this in the middle of the R feedback pipeline instead.

`default_nettype none

module R_Flags
#(
    parameter WORD_WIDTH = 0
)
(
    input   wire  [WORD_WIDTH-1:0]  R,
    output  reg                     R_zero,
    output  reg                     R_negative
);

    initial begin
        R_zero     = 0;
        R_negative = 0;
    end

    always @(*) begin
        R_zero     <= ~|R;
        R_negative <= R[WORD_WIDTH-1];
    end

endmodule

