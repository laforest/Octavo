
`default_nettype none

module Down_Counter_Zero_Example
#(
    parameter WORD_WIDTH                = 36
)
(
    input   wire                        clock,
    input   wire                        run,
    input   wire                        load_wren,
    input   wire    [WORD_WIDTH-1:0]    load_value,
    output  wire    [WORD_WIDTH-1:0]    count_out,
    output  wire                        count_zero
);

// --------------------------------------------------------------------------

    localparam ZERO = {WORD_WIDTH{1'b0}};

    reg [WORD_WIDTH-1:0] count = ZERO;

// --------------------------------------------------------------------------

    wire count_out_wren;

    Down_Counter_Zero
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    Example
    (
        .run            (run),
        .count_in       (count),
        .load_wren      (load_wren),
        .load_value     (load_value),
        .count_out_wren (count_out_wren),
        .count_out      (count_out),
        .count_zero     (count_zero)
    );

// --------------------------------------------------------------------------

    always @(posedge clock) begin
        count <= (count_out_wren == 1'b1) ? count_out : count; 
    end

endmodule

