
module Address_Translator
#(
    parameter       ADDR_COUNT          = 0,
    parameter       ADDR_BASE           = 0,
    parameter       ADDR_WIDTH          = 0
)
(
    input   wire    [ADDR_WIDTH-1:0]    raw_address,
    output  reg     [ADDR_WIDTH-1:0]    translated_address
);
    // Since I/O addresses are not always aligned to power-of-2 boundaries and
    // may not span power-of-2 blocks, the LSB are not necessarily consecutive,
    // exhaustive, and starting at zero: their order can be rotated by the
    // offset to the nearest power-of-2 boundary. Thus, we construct a
    // translation table that should hopefully optimize down to mere rewiring
    // of the mux inputs or of its internal logic.
    
    localparam ADDR_DEPTH = 2**ADDR_WIDTH;

    integer                     i, j;
    reg     [ADDR_WIDTH-1:0]    translation_table [ADDR_DEPTH-1:0];

    initial begin
        // In the case where ADDR_COUNT < ADDR_DEPTH, make sure all entries are defined
        // This happens for a single entry: ADDR_WIDTH is artificially kept at 1 instead of 0
        for(i = 0; i < ADDR_DEPTH; i = i + 1) begin
            translation_table[i] = 'h0;
        end

        // In the case of a single entry, the LSB (j) will be either 1 or zero,
        // but always translates to 0, thus this should optimize away.
        j = ADDR_BASE[ADDR_WIDTH-1:0];
        for(i = 0; i < ADDR_COUNT; i = i + 1) begin
            translation_table[j] = i[ADDR_WIDTH-1:0];
            j = (j + 1) % ADDR_DEPTH; // Force wrap-around
        end
    end

    always @(*) begin
        translated_address <= translation_table[raw_address];
    end

endmodule

