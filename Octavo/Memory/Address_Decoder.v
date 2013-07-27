
module Address_Decoder
#(
    parameter       ADDR_COUNT          = 0,
    parameter       ADDR_BASE           = 0,
    parameter       ADDR_WIDTH          = 0
)
(
    input   wire    [ADDR_WIDTH-1:0]    addr,
    output  reg                         match 
);
    integer i;
    reg             [ADDR_COUNT-1:0]    per_addr_match;

    // Check each address in range for match
    always @(*) begin
        for(i = 0; i < ADDR_COUNT; i = i + 1) begin : addr_decode
            if( addr === (ADDR_BASE + i) ) begin
                per_addr_match[i] <= `HIGH;
            end
            else begin
                per_addr_match[i] <= `LOW;
            end
        end
    end

    // Do any of them match?
    always @(*) begin : is_match
        match <= | per_addr_match;
    end 

    initial begin
        for(i = 0; i < ADDR_COUNT; i = i + 1) begin
            per_addr_match[i] = `LOW; 
        end
    end
endmodule

