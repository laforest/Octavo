
// A *universal* address decoder. Works for any address range at any starting point.

// Checks if the input address matches each possible address in range, then
// outputs the bitwise OR of all these checks.  Some boolean algebra shows that
// it will always optimize down to a minimal form: any bits which iterate over
// their entire binary range become boolean "don't care", leaving the other
// bits to do the match. Thus, for aligned power of 2 address ranges, we get
// the minimal NOT-AND-gate decoder.

// This approach has one caveat: you have to test, at synthesis time, all 2^N
// possible addresses, and store the matches into a vector 2^N bits long.  This
// could take a long time and AFAIK, Verilog implementations have a maximum
// vector width of a few million, so this decoder will break for addresses more
// than 20-23 bits wide.

// Call it a synthesizer stress-test. ;)

module Address_Decoder
#(
    parameter       ADDR_COUNT          = 0,
    parameter       ADDR_BASE           = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       REGISTERED          = `FALSE
)
(
    input   wire                        clock,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    output  reg                         hit 
);
    integer                     i;
    reg     [ADDR_COUNT-1:0]    per_addr_match;
    reg                         match;

    // Check each address in range for match
    always @(*) begin
        for(i = 0; i < ADDR_COUNT; i = i + 1) begin : addr_decode
            per_addr_match[i] <= (addr == (ADDR_BASE + i));
        end
    end

    // Do any of them match?
    always @(*) begin : is_match
        match <= | per_addr_match;
    end 

// ECL What was I thinking?!?
//    initial begin
//        for(i = 0; i < ADDR_COUNT; i = i + 1) begin
//            per_addr_match[i] = `LOW; 
//        end
//    end

    generate
        if (REGISTERED == `TRUE) begin
            always @(posedge clock) begin
                hit <= match;
            end

            initial begin
                hit = 0;
            end
        end
        else begin
            always @(*) begin
                hit <= match;
            end
        end
    endgenerate
endmodule

