
// Round-robin thread number counter.
// Outputs both current and next thread.
// Use this to multiplex a resource across threads.
// Set to appropriate initial thread value depending on location in pipeline.

// This is the kind of resource that gets optimized a lot and reduced to
// a single instance. This causes artificial critical paths. You will want to
// preserve individual instances either through netlist logical partitioning
// or via source code directives at the module instance.

`default_nettype none

module Thread_Number
#(
    parameter   INITIAL_THREAD                  = 0,
    parameter   THREAD_COUNT                    = 0,
    parameter   THREAD_COUNT_WIDTH              = 0
)
(
    input   wire                                clock,
    output  wire    [THREAD_COUNT_WIDTH-1:0]    current_thread,
    output  wire    [THREAD_COUNT_WIDTH-1:0]    next_thread
);

    // Avoids width-mismatch warnings
    localparam ZERO = {THREAD_COUNT_WIDTH{1'b0}};

    reg last_thread = 0;

    always @(*) begin
        // Doing it this way to avoid an adder/subtracter comparator.
        last_thread = (current_thread == (THREAD_COUNT-1));
    end

// --------------------------------------------------------------------

    UpDown_Counter
    #(
        .WORD_WIDTH     (THREAD_COUNT_WIDTH),
        .INITIAL_COUNT  (INITIAL_THREAD)
    )
    Thread
    (
        .clock          (clock),
        .up_down        (1'b1),         // 1/0 up/down
        .run            (1'b1),         // counts one step if set
        .wren           (last_thread),  // Write overrules count
        .write_data     (ZERO),
        .count          (current_thread),
        .next_count     (next_thread)
    );

endmodule

