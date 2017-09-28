
// A counter which can count up or down by 1, wraps around when passing 0 or maximum.

`default_nettype none

module UpDown_Counter
#(
    parameter WORD_WIDTH                = 0,
    parameter INITIAL_COUNT             = 0
)
(
    input   wire                        clock,
    input   wire                        up_down,        // 1/0 up/down
    input   wire                        run,            // counts one step if set
    input   wire                        wren,           // Write overrules count
    input   wire    [WORD_WIDTH-1:0]    write_data,
    output  reg     [WORD_WIDTH-1:0]    count,
    output  reg     [WORD_WIDTH-1:0]    next_count      // sometimes handy
);

    initial begin
        count       = INITIAL_COUNT [WORD_WIDTH-1:0];
        next_count  = 0;
    end

    localparam one          = {{WORD_WIDTH-1{1'b0}},1'b1};
    localparam minus_one    = {WORD_WIDTH{1'b1}};

// --------------------------------------------------------------------

    reg [WORD_WIDTH-1:0] increment;

    always @(*) begin
        increment   = (up_down == 1'b1) ? one : minus_one;
        next_count  = (wren    == 1'b1) ? write_data : (count + increment);
    end

    always @(posedge clock) begin
        count <= (run == 1'b1) ? next_count : count;
    end

endmodule

