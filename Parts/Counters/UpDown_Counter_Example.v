
`default_nettype none

module UpDown_Counter_Example
#(
    parameter WORD_WIDTH                = 36,
    parameter INITIAL_COUNT             = 55
)
(
    input   wire                        clock,
    input   wire                        up_down,        // 1/0 up/down
    input   wire                        run,            // counts one step if set
    input   wire                        wren,           // Write overrules count
    input   wire    [WORD_WIDTH-1:0]    write_data,
    output  wire    [WORD_WIDTH-1:0]    count,
    output  wire    [WORD_WIDTH-1:0]    next_count      // sometimes handy
);

    UpDown_Counter
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .INITIAL_COUNT  (INITIAL_COUNT)
    )
    Example
    (
        .clock          (clock),
        .up_down        (up_down),
        .run            (run),
        .wren           (wren),
        .write_data     (write_data),
        .count          (count),
        .next_count     (next_count)
    );

endmodule

