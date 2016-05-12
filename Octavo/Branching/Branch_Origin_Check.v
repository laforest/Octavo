
// Detects when current PC matches a branch origin.

module Branch_Origin_Check
#(
    parameter   PC_WIDTH            = 0
)
(
    input                           clock,
    input   wire    [PC_WIDTH-1:0]  PC,
    input   wire    [PC_WIDTH-1:0]  branch_origin,
    output  wire                    hit_stage2,
    output  wire                    hit_stage3
);

// -----------------------------------------------------------

    reg     hit_raw;

    // ECL XXX Technically an XNOR, but let's leave it to the synthesis tool...
    always @(*) begin
        hit_raw <= (PC == branch_origin);
    end

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (1)
    )
    BOC_stage1to2
    (
        .clock  (clock),
        .in     (hit_raw),
        .out    (hit_stage2)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (1)
    )
    BOC_stage2to3
    (
        .clock  (clock),
        .in     (hit_stage2),
        .out    (hit_stage3)
    );

endmodule

