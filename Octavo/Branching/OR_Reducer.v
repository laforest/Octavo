
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
    reg     [WORD_WIDTH-1:0]    out_raw;
    reg     [WORD_COUNT-1:0]    slice;
    
    integer                     bit,word;
    integer                     index;

    always @(*) begin
        for(bit = 0; bit < WORD_WIDTH; bit = bit + 1) begin
            for(word = 0; word < WORD_COUNT; word = word + 1) begin
                index       <= (WORD_WIDTH * word) + bit;
                slice[word] <= in[index];
            end
            out_raw[bit]    <= | slice;
        end
    end

    generate
        if (REGISTERED == `TRUE) begin
            always @(posedge clock) begin
                out <= out_raw;
            end

            initial begin
                out = 0;
            end
        end
        else begin
            always @(*) begin
                out <= out_raw;
            end
        end
    endgenerate

endmodule

