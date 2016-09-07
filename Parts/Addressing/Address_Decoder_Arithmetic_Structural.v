
// A *universal* address decoder. Works for any address range at any starting point.

// Checks if the address lies between the base and (higher, inclusive) bound of a range.

// This version uses arithmetic checks and thus should scale to wide addresses
// without reaching limits in the CAD tool.

// However, the Quartus CAD tool, at least, mangles the two structural AddSubs
// into a chain of logic that is much larger and slower than the obvious
// straight Verilog implementation.

// It's kept here in case it works better on other platforms.

module Address_Decoder_Arithmetic_Structural
#(
    parameter       ADDR_WIDTH          = 0
)
(
    input   wire    [ADDR_WIDTH-1:0]    base_addr,
    input   wire    [ADDR_WIDTH-1:0]    bound_addr,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    output  reg                         hit 
);

// --------------------------------------------------------------------

    // base_or_higher = (addr >= base_addr);
    // addr - base_addr, expecting zero or positive    

    wire [ADDR_WIDTH-1:0] base_or_higher_check;
    reg                   base_or_higher;

    AddSub_Structural
    #(
        .WORD_WIDTH (ADDR_WIDTH)
    )
    base_check
    (
        .sub_add    (1'b1),     // 1/0 A-B/A+B
        .carry_in   (1'b0),
        .A          (addr),
        .B          (base_addr),
        .sum        (base_or_higher_check),
        .carry_out  ()
    );

    always @(*) begin
        base_or_higher = ~base_or_higher_check[ADDR_WIDTH-1]; // sign bit
    end

// --------------------------------------------------------------------

    // bound_or_lower = (addr <= bound_addr);
    // bound_addr - addr, expecting zero or positive    

    wire [ADDR_WIDTH-1:0] bound_or_lower_check;
    reg                   bound_or_lower;

    AddSub_Structural
    #(
        .WORD_WIDTH (ADDR_WIDTH)
    )
    bound_check
    (
        .sub_add    (1'b1),     // 1/0 A-B/A+B
        .carry_in   (1'b0),
        .A          (bound_addr),
        .B          (addr),
        .sum        (bound_or_lower_check),
        .carry_out  ()
    );

    always @(*) begin
        bound_or_lower = ~bound_or_lower_check[ADDR_WIDTH-1]; // sign bit
    end

// --------------------------------------------------------------------

    always @(*) begin
        hit = (base_or_higher && bound_or_lower);
    end

endmodule

