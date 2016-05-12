
// Round-robin thread number counter. Nothing much really.
// Outputs both current and next thread. (The Controller needs that.)

module Thread_Number
#(
    parameter   INITIAL_THREAD      = 0,
    parameter   THREAD_COUNT        = 0,
    parameter   THREAD_ADDR_WIDTH   = 0
)
(
    input   wire                            clock,
    output  reg     [THREAD_ADDR_WIDTH-1:0] current_thread,
    output  reg     [THREAD_ADDR_WIDTH-1:0] next_thread
);

    // Workaround to allow bit vector selection to eliminate truncation warnings
    // Cause: can't put a parameter in the bitwidth part of a literal.
    // e.g.: THREAD_ADDR_WIDTH'd1 is not allowed. :P
    integer zero = 0;
    integer one  = 1;

    initial begin
        current_thread = INITIAL_THREAD[THREAD_ADDR_WIDTH-1:0];
    end

    reg last_thread;

    always @(*) begin
        // Doing it this way to avoid an adder/subtracter comparator.
        last_thread <= (current_thread == (THREAD_COUNT-1));
        next_thread <= !last_thread ? current_thread + one[THREAD_ADDR_WIDTH-1:0] : zero[THREAD_ADDR_WIDTH-1:0];
    end

    always @(posedge clock) begin
        current_thread  <= next_thread;
    end
endmodule

