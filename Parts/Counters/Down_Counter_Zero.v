
// Counts downward to zero, with zero signal.
// Counts down one step if run is set.
// Halts when it reaches zero.
// Must load a new value to restart.
// Load overrides run.

// Uses a separate count value store to support sharing the counter hardware.
// (e.g.: an array of memory locations, each updated in turn)

module Down_Counter_Zero
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire                        run,
    input   wire    [WORD_WIDTH-1:0]    count_in;
    input   wire                        load_wren,
    input   wire    [WORD_WIDTH-1:0]    load_value,
    output  reg                         count_out_wren,
    output  reg     [WORD_WIDTH-1:0]    count_out,
    output  reg                         zero
);

// --------------------------------------------------------------------

    initial begin
        count_out_wren  = 0;
        count_out       = 0;
        zero            = 0;
    end

    localparam ZERO = {WORD_WIDTH{1'b0}};
    localparam ONE  = {{(WORD_WIDTH-1){1'b0}},1'b1};

// --------------------------------------------------------------------

    reg                     count_run = 0;

    always @(*) begin
        count_run       = (run == 1'b1) & (zero == 1'b0);
        count_out_wren  = (count_run == 1'b1) | (load_wren == 1'b1);
        count_out       = (load_wren == 1'b1) ? load_value : (count_in - ONE); 
        zero            = (count_out == ZERO);
    end

endmodule

