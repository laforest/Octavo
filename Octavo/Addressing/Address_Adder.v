
// Adds the final offset to the operand, between stages 2 and 3.

module Address_Adder
#(
    parameter   WORD_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    addr_in,
    input   wire    [WORD_WIDTH-1:0]    offset,
    output  reg     [WORD_WIDTH-1:0]    addr_out
);
    reg     [WORD_WIDTH-1:0]    raw_addr;

    always @(posedge clock) begin
        raw_addr <= addr_in;
        addr_out <= raw_addr + offset;
    end
endmodule

