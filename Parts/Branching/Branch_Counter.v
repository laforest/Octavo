
// Branch Counter: once loaded, counts down one step to zero each time the
// branch is reached.

// If the counter is at zero, it will halt counting and raise it's "done"
// output and hold it there until it is reloaded.

// So for a counter value of N, "done" will seen on the N+1 pass.

// To restart the counter, you must reload the counter with a new count value.
// Load overrides a coincident decrement.

// Counter starts at zero at initialization.

// Multithreaded: one counter per thread, one each clock cycle.

module Branch_Counter
#(
    parameter WORD_WIDTH                = 0,
    parameter RAMSTYLE                  = ""
)
(
    input   wire                        clock,
    input   wire                        branch_reached,
    input   wire                        start_count_wren,
    input   wire    [WORD_WIDTH-1:0]    start_count,
    output  wire                        done
);

// --------------------------------------------------------------------

    localparam COUNTER_ZERO     = {COUNTER_WIDTH{1'b0}};
    localparam COUNTER_ONE      = {{(COUNTER_WIDTH-1){1'b0}},1'b1};

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0]   current_count;
    wire [WORD_WIDTH-1:0]   new_count;
    wire                    new_count_wren;

    Down_Counter_Zero
    #(
        .WORD_WIDTH         (WORD_WIDTH)
    )
    BC_DCZ
    (
        .run                (branch_reached),
        .count_in           (current_count),
        .load_wren          (start_count_wren),
        .load_value         (start_count),
        .count_out_wren     (new_count_wren),
        .count_out          (new_count),
        .zero               (done)
    );

// --------------------------------------------------------------------

    // Multiplex the memory amongst all threads.
    // Read one thread ahead so we have the values for the thread ready
    // before we write them back in the next cycle.

    wire [`OCTAVO_THREAD_COUNT_WIDTH-1:0] thread_number_read;
    wire [`OCTAVO_THREAD_COUNT_WIDTH-1:0] thread_number_write;

    module Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (`OCTAVO_THREAD_COUNT),
        .THREAD_COUNT_WIDTH (`OCTAVO_THREAD_COUNT_WIDTH)
    )
    BC_TN
    (
        .clock              (clock),
        .current_thread     (thread_number_write),
        .next_thread        (thread_number_read)
    );

// --------------------------------------------------------------------

    // Store the count value.
    // One word per thread.

    RAM_SDP 
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (`OCTAVO_THREAD_COUNT_WIDTH),
        .DEPTH          (`OCTAVO_THREAD_COUNT),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (0),
        .USE_INIT_FILE  (0),
        .INIT_FILE      (),
    )
    BC_RAM
    (
        .clock          (clock),
        .wren           (new_count_wren),
        .write_addr     (thread_number_write),
        .write_data     (new_count),
        .rden           (1'b1),
        .read_addr      (thread_number_read), 
        .read_data      (current_count)
    );

endmodule

