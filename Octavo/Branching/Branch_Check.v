
// Detects when current PC matches a branch origin.

module Branch_Check
#(
    parameter   PC_WIDTH            = 0,
)
(
    input                           clock,
    input   wire    [PC_WIDTH-1:0]  PC,
    input   wire    [PC_WIDTH-1:0]  branch_origin,
    output  reg                     hit
);

    // ECL XXX Technically an XNOR, but let's leave it to the synthesis tool...
    always @(posedge clock) begin
        if (PC === branch_origin) begin
            hit <= `HIGH;
        end
        else begin
            hit <= `LOW;
        end
    end

endmodule

