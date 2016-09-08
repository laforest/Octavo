
// Computes a word-wide OR-reduction
// Implemented as a fold operation.

// XXX ECL Couldn't this be done with a dumb iteration? I forget why I did it this way...

module Word_OR_Reducer
#(
    parameter       WORD_WIDTH                      = 0,
    parameter       WORD_COUNT                      = 0
)
(
    input   wire    [(WORD_WIDTH * WORD_COUNT)-1:0] in,
    output  reg     [ WORD_WIDTH-1:0]               out
);

// -----------------------------------------------------------

    // Init all intermediate results to zero

    reg     [WORD_WIDTH-1:0]    out_raw     [WORD_COUNT-1:0];

    integer count;
    initial begin
        for(count = 0; count < WORD_COUNT; count = count + 1) begin
            out_raw[count] = {WORD_WIDTH{`LOW}};
        end
    end

// -----------------------------------------------------------

    // Set the first intermediate result to the first word
    // then successively OR the previous intermediate result
    // with the current input word.

    reg     [WORD_COUNT-1:0]    slice;

    genvar  word;
    generate
        always @(*) begin
            out_raw[0] <= in[WORD_WIDTH-1:0];
        end
        for(word = 1; word < WORD_COUNT; word = word + 1) begin : OR_reduction
            always @(*) begin
                out_raw[word] <= out_raw[word-1] | in[WORD_WIDTH + (WORD_WIDTH * word)-1:(WORD_WIDTH * word)];
            end
        end
    endgenerate

// -----------------------------------------------------------

    // The last intermediate result is the final reduced word.

    always @(*) begin
        out <= out_raw[WORD_COUNT-1];
    end
endmodule

