
// Branch Counter: once loaded, counts down to zero based on a selectable
// condition: When the branch has been reached, decrement either if the
// branch was taken or not.

// If the counter is at zero, it will raise "done" once, and clear its
// internal "run" bit, halting the counter, clearing "done", and leaving its
// memory word all-zero.
// Thus, for a counter value of N, "done" will be raised on the N+1 pass.

// To restart the counter, you must reload the counter with a new count value
// and a new condition. The "run" bit is internally set by the configuration write. 

// TODO: If the counter is too slow: pipeline the counter. Delay write thread
// number as required.

module Branch_Counter
#(
    parameter WORD_WIDTH                = 0,
    parameter RAMSTYLE                  = ""
)
(
    input   wire                        clock,
    input   wire                        branch_reached,
    input   wire                        branch_taken,
    input   wire                        configuration_wren,
    input   wire    [WORD_WIDTH-1:0]    configuration_data,
    output  reg                         done
);

    initial begin
        done = 0;
    end

    localparam RUN_WIDTH        = 1;
    localparam TAKEN_WIDTH      = 1;
    localparam COUNTER_WIDTH    = WORD_WIDTH - TAKEN_WIDTH;
    // One larger than WORD_WIDTH
    localparam MEM_WIDTH        = COUNTER_WIDTH + TAKEN_WIDTH + RUN_WIDTH;

    localparam COUNTER_ZERO     = {COUNTER_WIDTH{1'b0}};
    localparam COUNTER_ONE      = {{(COUNTER_WIDTH-1){1'b0}},1'b1};

// --------------------------------------------------------------------

    // Define the counter data structure in a memory word.

    wire    [MEM_WIDTH-1:0]     mem_read_data;
    reg     [COUNTER_WIDTH-1:0] count           = 0
    reg                         taken           = 0;
    reg                         run             = 0;

    always @(*) begin
        {run,count,taken} = mem_read_data;
    end

// --------------------------------------------------------------------

    // The configuration data of course must have the same structure.
    // Note the dropped most-significant bit!!!
    // That bit contains the internal run bit.

    reg     [COUNTER_WIDTH-1:0]  config_count   = 0
    reg                          config_taken   = 0;

    always @(*) begin
        {config_count,config_taken} = configuration_data;
    end

// --------------------------------------------------------------------

    // And write the same structure back to memory.

    reg     [MEM_WIDTH-1:0]     mem_write_data  = 0;
    reg     [COUNTER_WIDTH-1:0] mem_count       = 0;
    reg                         mem_taken       = 0;
    reg                         mem_run         = 0;

    always @(*) begin
        mem_write_data = {mem_run,mem_count,mem_taken};
    end

// --------------------------------------------------------------------

    // Now select what to write to memory: the decremented count and its
    // condition and run bits, or the new configuration data.
    // Note the automatically set run bit on configuration write.

    reg                     count_is_zero   = 0;
    reg [COUNTER_WIDTH-1:0] new_count       = 0;
    reg                     mem_wren        = 0;

    always @(*) begin
        count_is_zero = (count == COUNTER_ZERO);
        new_count     = count - COUNTER_ONE;

        {mem_run,mem_count,mem_taken} = (count_is_zero      == 1'b1) ? {1'b0,COUNTER_ZERO,1'b0}         : {run,new_count,taken};
        {mem_run,mem_count,mem_taken} = (configuration_wren == 1'b1) ? {1'b1,config_count,config_taken} : {mem_run,mem_count,mem_taken};

        mem_wren = (branch_reached == 1'b1) & (branch_taken == taken);
        mem_wren = (configuration_wren == 1'b1) ? 1'b1 : mem_wren;;

        done = (count_is_zero == 1'b1) & (run == 1'b1); 
    end

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

    // Store the count value, run, and condition bits
    // One word per thread.

    RAM_SDP 
    #(
        .WORD_WIDTH     (MEM_WIDTH),
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
        .wren           (mem_wren),
        .write_addr     (thread_number_write),
        .write_data     (mem_write_data),
        .rden           (1'b1),
        .read_addr      (thread_number_read), 
        .read_data      (mem_read_data)
    );

endmodule

