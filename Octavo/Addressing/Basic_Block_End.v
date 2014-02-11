
// Compares the Control Memory Match value with the PC. Within a power-of-2
// length block of memory, each addressing bit permutation for that block
// will occur once, just not necessarily in order. Hence the value of Match
// has to take the absolute address of the code into account. A match
// denotes the end of a Basic Block.

module Basic_Block_End
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    PC_LSB,
    input   wire    [WORD_WIDTH-1:0]    match,
    output  wire                        block_end_stage_2,
    output  wire                        block_end_stage_3
);

// -----------------------------------------------------------

    // Note: match comes out of stage 0 (Control_Memory), hence no pipeline needed.

    wire    [WORD_WIDTH-1:0]    PC_LSB_reg;

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    )
    stage_0
    (
        .clock  (clock),
        .in     (PC_LSB),
        .out    (PC_LSB_reg)
    );

// -----------------------------------------------------------

    // ECL XXX For now, let's do the simplest thing and let the CAD tool
    // synthesize this. The schematic denotes this as bitwise XOR'ing
    // followed by a NOR-reduction, but let's see if this works.

    wire    block_end_raw;

    always @(*) begin
        if(PC_LSB_reg === match) begin
            block_end_raw <= `HIGH;
        end else begin
            block_end_raw <= `LOW;
        end
    end

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (1)
    )
    stages_1_2
    (
        .clock  (clock),
        .in     (block_end_raw),
        .out    (block_end_stage_2)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (1)
    )
    stage_3
    (
        .clock  (clock),
        .in     (block_end_stage_2),
        .out    (block_end_stage_3)
    );
endmodule

