
// Branch Detector: compares the Program Counter and some ALU result flags
// (from the previous instruction) to pre-set values.  If conditions are met,
// outputs a branch reached signal, a branch destination address, a jump
// signal, and a cancellation signal (which turns the current parallel ALU
// operation into a NOP).

module Branch_Detector
#(
    parameter WORD_WIDTH            = 0,  // Must be larger than CONFIG_WIDTH
    parameter PC_WIDTH              = 0,
    parameter RAMSTYLE              = "",
    // Multithreading
    parameter THREAD_COUNT          = 0,
    parameter THREAD_COUNT_WIDTH    = 0

)
(
    input   wire                            clock,
    input   wire    [PC_WIDTH-1:0]          PC,
    input   wire                            A_negative,
    input   wire                            A_carryout,
    input   wire                            A_sentinel,
    input   wire                            A_external,
    input   wire                            B_lessthan,
    input   wire                            B_counter,
    input   wire                            B_sentinel,
    input   wire                            B_external,
    input   wire                            IO_Ready_previous,
    input   wire                            branch_config_wren,
    input   wire    [WORD_WIDTH-1:0]        branch_config_data,
    output  reg                             reached,
    output  reg     [PC_WIDTH-1:0]          destination,
    output  reg                             jump,
    output  reg                             cancel
);

// --------------------------------------------------------------------

    initial begin
        reached     = 0;
        destination = 0;
        jump        = 0;
        cancel      = 0;
    end

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 0

// --------------------------------------------------------------------
// Configuration of a branch, one per thread

    wire [THREAD_COUNT_WIDTH-1:0] thread_write;
    wire [THREAD_COUNT_WIDTH-1:0] thread_read;

    // Read one thread ahead of write, so at a given thread, the current value
    // is being output if/when we overwrite it.

    // The exact location in this memory doesn't matter, since there are no
    // memory-mapped reads, hence the initial thread of zero.

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TN_BM
    (
        .clock              (clock),
        .current_thread     (thread_write),
        .next_thread        (thread_read)
    );

    // A branch condition selects one each from A and B flags, and applies
    // a Dyadic operation to them.

    localparam COND_WIDTH   = (`GROUP_SELECTOR_WIDTH*2) + `DYADIC_CTRL_WIDTH;
    localparam CONFIG_WIDTH = (PC_WIDTH*2) + COND_WIDTH + 3;

    reg     [PC_WIDTH-1:0]      branch_origin           = 0;
    reg                         branch_origin_enable    = 0;
    reg     [PC_WIDTH-1:0]      branch_destination      = 0;
    reg                         branch_predict_taken    = 0;
    reg                         branch_predict_enable   = 0;
    reg     [COND_WIDTH-1:0]    branch_condition        = 0;

    wire    [CONFIG_WIDTH-1:0]  branch_configuration;

    RAM_SDP
    #(
        .WORD_WIDTH     (CONFIG_WIDTH),
        .ADDR_WIDTH     (THREAD_COUNT_WIDTH),
        .DEPTH          (THREAD_COUNT),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (0),
        .USE_INIT_FILE  (0),
        .INIT_FILE      ()
    )
    Branch_Configuration
    (
        .clock          (clock),
        .wren           (branch_config_wren),
        .write_addr     (thread_write),
        .write_data     (branch_config_data[CONFIG_WIDTH-1:0]), // MSB unused, if any
        .rden           (1'b1),
        .read_addr      (thread_read),
        .read_data      (branch_configuration)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 1

    // Break-out the branch configuration signals

    always @(*) begin
        {branch_origin,branch_origin_enable,branch_destination,branch_predict_taken,branch_predict_enable,branch_condition} <= branch_configuration;
    end

// --------------------------------------------------------------------

    // Check if the PC has reached a branch, or if we accept any PC value.

    reg branch_origin_match = 0;

    always @(*) begin
        branch_origin_match <= (PC == branch_origin) | (branch_origin_enable == 0);
    end

// --------------------------------------------------------------------

    // Send out the branch destination. Filtered later by jump signal.
    // Send out the branch reached signal. Used by counters later on.

    always @(posedge clock) begin
        destination <= branch_destination;
        reached     <= branch_origin_match;
    end

// --------------------------------------------------------------------
// Condition predicate calculation

    wire    [`GROUP_SELECTOR_WIDTH-1:0]     A_selector;
    wire    [`GROUP_SELECTOR_WIDTH-1:0]     B_selector;
    wire    [`DYADIC_CTRL_WIDTH-1:0]        AB_operator;
    wire                                    predicate;

    always @(*) begin
        {A_selector, B_selector, AB_operator} <= branch_condition;
    end

    Condition_Predicate
    CP_BD
    (
        .clock          (clock),
        .A_selector     (A_selector),
        .A_negative     (A_negative),
        .A_carryout     (A_carryout),
        .A_sentinel     (A_sentinel),
        .A_external     (A_external),
        .B_selector     (B_selector),
        .B_lessthan     (B_lessthan),
        .B_counter      (B_counter),
        .B_sentinel     (B_sentinel),
        .B_external     (B_external),
        .AB_operator    (AB_operator),
        .predicate      (predicate)
    );

// --------------------------------------------------------------------

    // Signal a jump if we've reached the branch origin and met its conditions.
    // If the current instruction was previously annulled via IO_Ready, then instead
    // return the saved jump signal, since the current condition is invalid,
    // having been generated by the annulled version of the current
    // instruction instead of the instruction executed before it.

    wire jump_saved;

    // DEPTH: minus one since delayed version used one stage earlier

    Delay_Line
    #(
        .DEPTH  (THREAD_COUNT - 1),
        .WIDTH  (1)
    )
    DL_bom
    (
        .clock  (clock),
        .in     (jump),
        .out    (jump_saved)
    );

    always @(posedge clock) begin
        jump = (predicate == 1'b1);
        jump = (IO_Ready_previous == 1'b0) ? jump_saved : jump;
        jump = (branch_origin_match == 1'b1) & (jump == 1'b1);
    end

// --------------------------------------------------------------------

    // If we have reached the branch origin, and the branch state (taken, not
    // taken) does not match the branch prediction, and branch prediction is
    // enabled, then signal to cancel the ALU instruction concurrent with this
    // branch.  Filtered later by jump signal.

    always @(posedge clock) begin
        cancel <= (branch_origin_match == 1) & (branch_predict_taken != predicate) & (branch_predict_enable == 1);
    end

endmodule

