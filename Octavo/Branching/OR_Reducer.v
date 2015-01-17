
// Computes a word-wide OR-reduction

module OR_Reducer
#(
    parameter       WORD_WIDTH                      = 0,
    parameter       WORD_COUNT                      = 0,
    parameter       REGISTERED                      = `FALSE
)
(
    input   wire                                    clock,
    input   wire    [(WORD_WIDTH * WORD_COUNT)-1:0] in,
    output  reg     [ WORD_WIDTH-1:0]               out
);

// ECL XXX Basically a fold operation, necessarily done in the most manual way possible...*sigh*

// -----------------------------------------------------------

    reg     [WORD_WIDTH-1:0]    out_raw     [WORD_COUNT-1:0];

    integer count;
    initial begin
        for(count = 0; count < WORD_COUNT; count = count + 1) begin
            out_raw[count] = {WORD_WIDTH{`LOW}};
        end
    end

// -----------------------------------------------------------

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

    generate
        if (REGISTERED == `TRUE) begin
            always @(posedge clock) begin
                out <= out_raw[WORD_COUNT-1];
            end

            initial begin
                out = 0;
            end
        end
        else begin
            always @(*) begin
                out <= out_raw[WORD_COUNT-1];
            end
        end
    endgenerate

endmodule

