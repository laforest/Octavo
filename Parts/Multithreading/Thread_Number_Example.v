
`default_nettype none

module Thread_Number_Example
#(
    parameter   INITIAL_THREAD                  = 5,
    parameter   THREAD_COUNT                    = 8,
    parameter   THREAD_COUNT_WIDTH              = 3  // clog2(THREAD_COUNT)
)
(
    input   wire                                clock,
    output  wire    [THREAD_COUNT_WIDTH-1:0]    current_thread,
    output  wire    [THREAD_COUNT_WIDTH-1:0]    next_thread
);

    Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    Example
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        (next_thread)
    );

endmodule

