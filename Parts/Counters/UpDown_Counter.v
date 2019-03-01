
// A counter which can count up or down by 1, wraps around when passing 0 or maximum.

`default_nettype none

module UpDown_Counter
#(
    parameter                   WORD_WIDTH      = 0,
    parameter [WORD_WIDTH-1:0]  INITIAL_COUNT   = 0  // Since WORD_WIDTH can be > 32 bits
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

// --------------------------------------------------------------------------

    localparam ZERO         = {WORD_WIDTH{1'b0}};
    localparam ONE          = {{WORD_WIDTH-1{1'b0}},1'b1};
    localparam MINUS_ONE    = ~ZERO;

    initial begin
        count       = INITIAL_COUNT;
        next_count  = ZERO;
    end

// --------------------------------------------------------------------------

    reg [WORD_WIDTH-1:0] increment = ZERO;

    always @(*) begin
        increment   = (up_down == 1'b1) ? ONE : MINUS_ONE;
        next_count  = (wren    == 1'b1) ? write_data : (count + increment);
    end

    always @(posedge clock) begin
        count <= ((run == 1'b1) || (wren == 1'b1)) ? next_count : count;
    end

endmodule

