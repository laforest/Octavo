
// Counts downward to zero, with zero signal.
// Counts down one step if run is set.
// Halts when it reaches zero.
// Must load a new value to restart.
// Load overrides run.

module Down_Counter_Zero
#(
    parameter WORD_WIDTH                = 0,
    parameter INITIAL_COUNT             = 0
)
(
    input   wire                        clock,
    input   wire                        run,
    input   wire                        load_wren,
    input   wire    [WORD_WIDTH-1:0]    load_value,
    output  reg                         zero
);

// --------------------------------------------------------------------

    initial begin
        zero = 0;
    end

    localparam ZERO = {WORD_WIDTH{1'b0}};

// --------------------------------------------------------------------

    // Halt counter at zero.

    reg run_counter = 0;

    always @(*) begin
        run_counter <= (run == 1'b1) & (zero == 1'b0);
    end

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] count;

    UpDown_Counter
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .INITIAL_COUNT  (INITIAL_COUNT)
    )
    (
        .clock          (clock),
        .up_down        (1'b0),     // down
        .run            (run_counter),
        .wren           (load_wren),
        .write_data     (load_value),
        .count          (count),
        .next_count     ()          // N/C
    );

// --------------------------------------------------------------------

    always @(*) begin
        zero <= (count == ZERO);
    end

endmodule

