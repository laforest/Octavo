
// Computes a word-wide OR-reduction

`default_nettype none

module Word_OR_Reducer
#(
    parameter       WORD_WIDTH                      = 0,
    parameter       WORD_COUNT                      = 0
)
(
    input   wire    [(WORD_WIDTH*WORD_COUNT)-1:0]   in,
    output  reg     [ WORD_WIDTH            -1:0]   out
);

    initial begin
        out = 0;
    end

// --------------------------------------------------------------------

    // We must contain each partial result in a separate variable.
    // Computing the OR-reduction in a loop on the same variable implies
    // a combinational loop, which is not what we want.

    reg [WORD_WIDTH-1:0] out_reduction [WORD_COUNT-1:0];

    integer i;

    initial begin
        for(i=0; i < WORD_COUNT; i=i+1) begin
            out_reduction[i] = 0;
        end
    end

// --------------------------------------------------------------------

    always @(*) begin
        // Connect the zeroth input word to the zeroth variable.
        // This peels out the first loop iteration, where the read index 
        // would be out of range otherwise.
        out_reduction[0] = in[0 +: WORD_WIDTH];

        // OR the previous partial result with the current input word.
        for(i=1; i < WORD_COUNT; i=i+1) begin
            out_reduction[i] = out_reduction[i-1] | in[WORD_WIDTH*i +: WORD_WIDTH];
        end

        // The last partial result is the final result.
        out = out_reduction[WORD_COUNT-1];
    end

endmodule

