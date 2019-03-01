// Counts downward to zero.
// Counts down one step if run is set.
// Halts when it reaches zero, and raises zero signal.
// Must load a new value to restart.
// Load overrides run.

// Uses an external count value store to support sharing the counter hardware.
// (e.g.: an array of memory locations, each updated in turn)

`default_nettype none

module Down_Counter_Zero
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire                        run,
    input   wire    [WORD_WIDTH-1:0]    count_in,
    input   wire                        load_wren,
    input   wire    [WORD_WIDTH-1:0]    load_value,
    output  reg                         count_out_wren,
    output  reg     [WORD_WIDTH-1:0]    count_out,
    // Incorrect detection of circular logic,
    // possibly because the clocked storage is outside this module.
    // verilator lint_off UNOPT
    output  reg                         count_zero
    // verilator lint_on  UNOPT
);

// --------------------------------------------------------------------------

    localparam ZERO = {WORD_WIDTH{1'b0}};
    localparam ONE  = {{(WORD_WIDTH-1){1'b0}},1'b1};

    initial begin
        count_out_wren  = 1'b0;
        count_out       = ZERO;
        count_zero      = 1'b1;
    end

// --------------------------------------------------------------------------

    reg                     count_run = 0;

    always @(*) begin
        count_run       = (run == 1'b1) & (count_zero == 1'b0);
        count_out_wren  = (count_run == 1'b1) | (load_wren == 1'b1);
        count_out       = (load_wren == 1'b1) ? load_value : (count_in - ONE); 
        count_zero      = (count_out == ZERO);
    end

endmodule

