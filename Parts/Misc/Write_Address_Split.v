
// Write address translator

// Translates write addresses when in split mode
// Lower/upper half of D address selected by parameter

module Write_Address_Split
#(
    parameter   WRITE_ADDR_WIDTH            = 0,
    parameter   LOWER_UPPER_SPLIT           = 0  // 0/1 lower/upper half of D
)
(
    input   wire                            split,
    input   wire    [WRITE_ADDR_WIDTH-1:0]  write_addr,
    output  reg     [WRITE_ADDR_WIDTH-1:0]  write_addr_translated
);
// --------------------------------------------------------------------

    // Assumes an even number of write address bits.
    localparam WRITE_ADDR_WIDTH_SPLIT = WRITE_ADDR_WIDTH / 2;

    // To pad the upper bits of split memory write addresses.
    localparam WRITE_ADDR_ZERO_SPLIT = {WRITE_ADDR_WIDTH_SPLIT{1'b0}};

    initial begin
        write_addr_translated = 0;
    end

// --------------------------------------------------------------------

    // If split, select one half of write address (statically), and construct
    // new address. In both cases, return the narrower local write address.

    reg  [WRITE_ADDR_WIDTH-1:0]         write_addr_split       = 0;
    reg  [WRITE_ADDR_WIDTH_SPLIT-1:0]   write_addr_lower_half  = 0;
    reg  [WRITE_ADDR_WIDTH_SPLIT-1:0]   write_addr_upper_half  = 0;
    reg  [WRITE_ADDR_WIDTH_SPLIT-1:0]   write_addr_half        = 0;

    always @(*) begin
        write_addr_lower_half = write_addr[WRITE_ADDR_WIDTH_SPLIT-1:0];
        write_addr_upper_half = write_addr[WRITE_ADDR_WIDTH-1:WRITE_ADDR_WIDTH_SPLIT];
        write_addr_half       = (LOWER_UPPER_SPLIT == 0) ? write_addr_lower_half : write_addr_upper_half;
        write_addr_split      = {WRITE_ADDR_ZERO_SPLIT,write_addr_half};
        write_addr_translated = (split == 1) ? write_addr_split : write_addr;
    end

endmodule

