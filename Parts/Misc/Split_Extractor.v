
// Extracts the "split" bit from the ALU control bits.  The split bit changes
// the write addressing mode, using the D operand as two separate halves. This
// affects multiple modules later on.

// FIXME This is a hack, but no clean solution presents itself.  See
// Triadic_ALU_Operations.vh and Triadic_ALU_Forward_Path.v for control bits
// ordering.

// For now, the split bit is the MSB.

`default_nettype none

module Split_Extractor
#(
    parameter       WORD_WIDTH          = 0
)
(
    input   wire    [WORD_WIDTH-1:0]    control,
    output  reg                         split
);

    initial begin
        split = 1'b0;
    end

    always @(*) begin
        split = control [WORD_WIDTH-1];
    end

endmodule

