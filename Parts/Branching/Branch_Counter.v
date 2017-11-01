
// Branch Counter: once loaded, counts down one step to zero each time the
// branch is reached and the associated instruction is not annulled.

// Outputs high ("counter running") until it reaches zero, where the output
// drops to zero, and the counter halts until a non-zero reload.
// Load overrides a coincident decrement.

// So for a counter value of N, completion will be seen on the N+1 pass.

// Counter starts at zero at initialization.

// Multithreaded: one counter per thread, one each clock cycle.

`default_nettype none

module Branch_Counter
#(
    parameter       WORD_WIDTH          = 0,
    // Common RAM parameters
    parameter       RAMSTYLE            = "",
    parameter       READ_NEW_DATA       = 0,
    // Multithreading
    parameter       THREAD_COUNT        = 0,
    parameter       THREAD_COUNT_WIDTH  = 0
)
(
    input   wire                        clock,
    input   wire                        branch_reached,
    input   wire                        IO_Ready,
    input   wire                        IO_Ready_previous,
    input   wire                        load,
    input   wire    [WORD_WIDTH-1:0]    load_value,
    output  wire                        running
);

// --------------------------------------------------------------------

    localparam MEM_PIPE_DEPTH       = 1;
    localparam DECREMENT_PIPE_DEPTH = 2;
    localparam MODULE_PIPE_DEPTH    = MEM_PIPE_DEPTH + DECREMENT_PIPE_DEPTH;
    localparam COUNTER_ONE          = {{(WORD_WIDTH-1){1'b0}},1'b1};
    localparam SUBTRACT             = 1'b1;

// --------------------------------------------------------------------
// Delay write from previous instruction to synchronize with module output.
// We can then arbitrate them.

    wire                        IO_Ready_previous_sync;
    wire                        load_sync;
    wire    [WORD_WIDTH-1:0]    load_value_sync;

    Delay_Line 
    #(
        .DEPTH  (MODULE_PIPE_DEPTH), 
        .WIDTH  (1+1+WORD_WIDTH)
    ) 
    BC_LOAD
    (
        .clock  (clock),
        .in     ({IO_Ready_previous,      load,      load_value}),
        .out    ({IO_Ready_previous_sync, load_sync, load_value_sync})
    );

// --------------------------------------------------------------------
// Delay branch_reached to synchronize with module output.
// We use to enable writing back the decremented count, generated a few cycles
// later at the output.

    wire branch_reached_sync;

    Delay_Line 
    #(
        .DEPTH  (DECREMENT_PIPE_DEPTH), 
        .WIDTH  (1)
    ) 
    BC_BR
    (
        .clock  (clock),
        .in     (branch_reached),
        .out    (branch_reached_sync)
    );

// --------------------------------------------------------------------
// Delay IO_Ready to synchronize with module output.
// Note that we don't care about Cancel here, as even with a cancelled
// instruction, we have reached the branch, and thus the counter must
// decrement.

    wire IO_Ready_sync;

    Delay_Line 
    #(
        .DEPTH  (DECREMENT_PIPE_DEPTH-1), 
        .WIDTH  (1)
    ) 
    BC_IOR
    (
        .clock  (clock),
        .in     (IO_Ready),
        .out    (IO_Ready_sync)
    );

// --------------------------------------------------------------------
// Calculate counter memory write enable
// Store decremented value if counter is running, current instruction 
// is not annulled, and branch is reached.
// Store loaded count value at any time, if previous instruction 
// is not annulled.

    reg wren = 0;

    always @(*) begin
        wren = (running == 1'b1) & (IO_Ready_sync == 1'b1) & (branch_reached_sync == 1'b1);
        wren = wren | ((load_sync == 1'b1) & (IO_Ready_previous_sync == 1'b1));
    end

// --------------------------------------------------------------------
// Select new count value

    reg  [WORD_WIDTH-1:0] new_value = 0;
    wire [WORD_WIDTH-1:0] decremented_count;

    always @(*) begin
        new_value <= (load_sync == 1'b1) ? load_value_sync : decremented_count;
    end

// --------------------------------------------------------------------
// Multiplex the memory amongst all threads.

    wire [THREAD_COUNT_WIDTH-1:0] thread_number_read;
    wire [THREAD_COUNT_WIDTH-1:0] thread_number_write;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    BC_READ_THREAD
    (
        .clock              (clock),
        .current_thread     (thread_number_read),
        .next_thread        ()
    );

    // Write back (to same thread) the output value generated later.
    // Or the load value, assumed to be already synchronized to this thread
    // number.

    Thread_Number
    #(
        .INITIAL_THREAD     (THREAD_COUNT - MODULE_PIPE_DEPTH),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    BC_WRITE_THREAD
    (
        .clock              (clock),
        .current_thread     (thread_number_write),
        .next_thread        ()
    );

// --------------------------------------------------------------------
// Store the count value. One word per thread.

    wire [WORD_WIDTH-1:0]   count;

    RAM_SDP 
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (THREAD_COUNT_WIDTH),
        .DEPTH          (THREAD_COUNT),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        .USE_INIT_FILE  (0),
        .INIT_FILE      ()
    )
    BC_RAM
    (
        .clock          (clock),
        .wren           (wren),
        .write_addr     (thread_number_write),
        .write_data     (new_value),
        .rden           (1'b1),
        .read_addr      (thread_number_read), 
        .read_data      (count)
    );

// --------------------------------------------------------------------
// Delay running flag to synchronize it with the decremented count value
// This is split into two to isolate the OR-reducer logic

    wire [WORD_WIDTH-1:0] count_internal;

    Delay_Line 
    #(
        .DEPTH  (DECREMENT_PIPE_DEPTH-1), 
        .WIDTH  (WORD_WIDTH)
    ) 
    BC_RUNNING_PRE
    (
        .clock  (clock),
        .in     (count),
        .out    (count_internal)
    );

// --------------------------------------------------------------------
// OR-Reduce count as the "running" flag: stops running at zero

    reg running_internal = 0;

    always @(*) begin
        running_internal <= |count_internal;
    end

// --------------------------------------------------------------------
// Delay running flag to synchronize it with the decremented count value
// This is split into two to isolate the OR-reducer logic

    Delay_Line 
    #(
        .DEPTH  (DECREMENT_PIPE_DEPTH-1), 
        .WIDTH  (1)
    ) 
    BC_RUNNING_POST
    (
        .clock  (clock),
        .in     (running_internal),
        .out    (running)
    );

// --------------------------------------------------------------------
// Decrement by one. Use 2-stage Add/Sub module since a counter
// word could be large enough to take a while to decrement.

    AddSub_Ripple_Carry_2stages
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    BC_DECREMENT
    (
        .clock      (clock),
        .add_sub    (SUBTRACT),
        .cin        (1'b0),
        .dataa      (count),
        .datab      (COUNTER_ONE),
        .cout       (),
        .result     (decremented_count)
    );

endmodule

