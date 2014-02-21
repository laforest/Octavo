
// Adds the final offset to the operand, between stages 2 and 3.

// ECL XXX Should be factored out with Increment_Adder.v

module Address_Adder
#(
    parameter   WORD_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    addr_in,
    input   wire    [WORD_WIDTH-1:0]    offset,
    output  wire    [WORD_WIDTH-1:0]    addr_out
)

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]     addr_in_reg;

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    )
    addr_in_pipeline
    (
        .clock  (clock),
        .in     (addr_in),
        .out    (addr_in_reg)
    );

// -----------------------------------------------------------

    reg     [WORD_WIDTH-1:0]     addr_out_raw;

    always @(*) begin
        addr_out_raw <= addr_in_reg + offset;
    end

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    )
    addr_out_pipeline
    (
        .clock  (clock),
        .in     (addr_out_raw),
        .out    (addr_out)
    );
`

endmodule

