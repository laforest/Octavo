
// Address Splitter

// Splits the D address operand into DA and DB, depending on split control
// bit. 

// If unsplit, then they are both D, addressing the entire write address
// space. Later address decode logic will typically only write-enable the A or
// B memory exclusively, else we would duplicate the written data into both.

// If split, then DA/DB each address a range at the beginning of the A and
// B memories as mapped in the write address space. That range will be half of
// the address width of the full D address, extended to the full width of
// D with the upper bits set to the upper bits of the base address of A and B.

// The base address of A is assumed to be zero. That of B is higher, and
// a parameter.

// *** THE NUMBER OF D ADDRESS BITS MUST BE EVEN ***

`default_nettype none

module Address_Splitter
#(
    parameter   ADDR_WIDTH              = 0,
    parameter   DB_BASE_ADDR            = 0
)
(
    input   wire                        clock,
    input   wire                        split,
    input   wire    [ADDR_WIDTH-1:0]    D,
    output  reg     [ADDR_WIDTH-1:0]    DA,
    output  reg     [ADDR_WIDTH-1:0]    DB
);

// --------------------------------------------------------------------

    initial begin
        DA = 0;
        DB = 0;
    end

// --------------------------------------------------------------------

    localparam ADDR_WIDTH_SPLIT = ADDR_WIDTH / 2;
    localparam DA_UPPER_BITS    = {ADDR_WIDTH_SPLIT{1'b0}};
    localparam DB_UPPER_BITS    = DB_BASE_ADDR [ADDR_WIDTH-1:ADDR_WIDTH_SPLIT];

// --------------------------------------------------------------------

    reg [ADDR_WIDTH_SPLIT-1:0] DA_LOWER_BITS = 0;
    reg [ADDR_WIDTH_SPLIT-1:0] DB_LOWER_BITS = 0;

    always @(*) begin
        {DA_LOWER_BITS,DB_LOWER_BITS} <= D;
    end

// --------------------------------------------------------------------

    always @(posedge clock) begin
        DA <= (split == 1'b1) ? {DA_UPPER_BITS,DA_LOWER_BITS} : D;
        DB <= (split == 1'b1) ? {DB_UPPER_BITS,DB_LOWER_BITS} : D;
    end

endmodule

