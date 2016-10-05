
// Extracts the "split" bit from the ALU control bits.
// The split bit changes the write addressing mode, using the D operand as two
// separate halves. This affects multiple modules later on.

// FIXME This is a hack, but no clean solution presents itself.
// See Triadic_ALU_Operations.vh and Triadic_ALU.v for control bits ordering.
// For now, the split bit is the MSB.

module Split_Extractor
(
    input   wire    [`TRIADIC_CTRL_WIDTH-1:0]   control,
    output  reg                                 split
);

    initial begin
        split <= 0;
    end

    always @(*) begin
        split <= control[`TRIADIC_CTRL_WIDTH-1];
    end

endmodule

