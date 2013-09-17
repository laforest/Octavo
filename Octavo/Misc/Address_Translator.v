
// Translates a non-consecutive sequence of address bits into a consecutive
// one, so they can be used "as expected" with other addressed components
// (muxes, RAMs, etc...). ***Consumes no hardware.***

// Since address ranges might not start at power-of-2 boundaries and may not
// span power-of-2 size blocks, the Least-Significant bits might not
// necessarily be consecutive, exhaustive, and starting at zero: their order
// can be rotated by the offset to the nearest power-of-2 boundary. Thus, we
// construct a translation table that should hopefully optimize down to mere
// rewiring of inputs or internal logic.

// Typically, you'll need this alongside an Address_Decoder module.

module Address_Translator
#(
    parameter       ADDR_COUNT          = 0,
    parameter       ADDR_BASE           = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       REGISTERED          = `FALSE
)
(
    input   wire                        clock,
    input   wire    [ADDR_WIDTH-1:0]    raw_address,
    output  reg     [ADDR_WIDTH-1:0]    translated_address
);
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

    generate
        if (REGISTERED == `TRUE) begin
            always @(posedge clock) begin
                translated_address <= translation_table[raw_address];
            end

            initial begin
                translated_address = 0;
            end
        end
        else begin
            always @(*) begin
                translated_address <= translation_table[raw_address];
            end
        end
    endgenerate
endmodule

