
// Detects when current PC matches a branch location.

module PC_Match
#(
    parameter   PC_WIDTH            = 0,
)
(
    input                           clock,
    input   wire    [PC_WIDTH-1:0]  PC,
    input   wire    [PC_WIDTH-1:0]  match,
    output  reg                     hit
);

    // ECL XXX Technically an XNOR, but let's leave it to the synthesis tool...
    always @(posedge clock) begin
        if (PC === Match) begin
            hit <= `HIGH;
        end
        else begin
            hit <= `LOW;
        end
    end

endmodule

