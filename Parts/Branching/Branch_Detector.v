
// Branch Detector: compares the Program Counter and some ALU result flags
// (from the previous instruction) to pre-set values.  If conditions are met,
// outputs a branch destination address, a jump signal, and a cancellation
// signal (which turns the current parallel ALU operation into a NOP).

module Branch_Detector
#(
    parameter WORD_WIDTH    = 0,  // Must be larger than CONFIG_WIDTH
    parameter PC_WIDTH      = 0,
    parameter RAMSTYLE      = ""
)
(
    input   wire                            clock,
    input   wire    [PC_WIDTH-1:0]          pc,
    input   wire    [`COND_FLAG_COUNT-1:0]  flags_previous,
    input   wire                            configuration_wren,
    input   wire    [WORD_WIDTH-1:0]        configuration_data,
    input   wire                            IO_ready_previous, // Enters Stage 4
    output  wire    [PC_WIDTH-1:0]          destination,
    output  reg                             jump,
    output  reg                             cancel
);

// --------------------------------------------------------------------

    initial begin
        jump    = 0;
        cancel  = 0;
    end

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 0

    wire [PC_WIDTH-1:0] pc_stage2;

    Delay_Line
    #(
        .DEPTH  (2),
        .WIDTH  (PC_WIDTH)
    )
    DL_pc
    (
        .clock  (clock),
        .in     (pc),
        .out    (pc_stage2)
    );

// --------------------------------------------------------------------

    wire [PC_WIDTH-1:0] flags_previous_stage2;

    Delay_Line
    #(
        .DEPTH  (2),
        .WIDTH  (`COND_FLAG_COUNT)
    )
    DL_pc
    (
        .clock  (clock),
        .in     (flags_previous),
        .out    (flags_previous_stage2)
    );

// --------------------------------------------------------------------
// Configuration of a branch, one per thread

    wire [`OCTAVO_THREAD_COUNT_WIDTH-1:0] thread_write;
    wire [`OCTAVO_THREAD_COUNT_WIDTH-1:0] thread_read;

    // Read one thread ahead of write, so at a given thread, the current value
    // is being output if/when we overwrite it.

    // The exact location in this memory doesn't matter, since there are no
    // memory-mapped reads, hence the initial thread of zero.

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (`OCTAVO_THREAD_COUNT),
        .THREAD_COUNT_WIDTH (`OCTAVO_THREAD_COUNT_WIDTH)
    )
    TN_BM
    (
        .clock              (clock),
        .current_thread     (thread_write),
        .next_thread        (thread_read)
    );

    reg     [PC_WIDTH-1:0]      branch_origin           = 0;
    reg                         branch_origin_enable    = 0;
    reg     [PC_WIDTH-1:0]      branch_destination      = 0;
    reg                         branch_predict_taken    = 0;
    reg                         branch_predict_enable   = 0;
    reg     [COND_WIDTH-1:0]    branch_condition        = 0;

    localparam CONFIG_WIDTH = (PC_WIDTH*2) + COND_WIDTH + 3;

    wire    [CONFIG_WIDTH-1:0]  branch_configuration;

    RAM_SDP
    #(
        .WORD_WIDTH     (CONFIG_WIDTH),
        .ADDR_WIDTH     (`OCTAVO_THREAD_COUNT_WIDTH),
        .DEPTH          (`OCTAVO_THREAD_COUNT),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (0),
        .USE_INIT_FILE  (0),
        .INIT_FILE      ()
    )
    Branch_Configuration
    (
        .clock          (clock),
        .wren           (configuration_wren),
        .write_addr     (thread_write),
        .write_data     (configuration_data[CONFIG_WIDTH-1:0]), // MSB unused, if any
        .rden           (1'b1),
        .read_addr      (thread_read),
        .read_data      (branch_configuration)
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 1

    // Register the output of the memory, to ensure high speed.

    always @(posedge clock) begin
        {branch_origin,branch_origin_enable,branch_destination,branch_predict_taken,branch_predict_enable,branch_condition} <= branch_configuration;
    end


// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 2

    // Check if the pc has reached a branch, or if we accept any pc value.
    // spans stages 2 and 3

    reg     branch_origin_match         = 0;
    wire    branch_origin_match_stage4;

    always @(*) begin
        branch_origin_match <= (pc_stage2 == branch_origin) | (branch_origin_enable == 0);
    end

    Delay_Line
    #(
        .DEPTH  (2),
        .WIDTH  (1)
    )
    DL_bom
    (
        .clock  (clock),
        .in     (branch_origin_match),
        .out    (branch_origin_match_stage4)
    );

// --------------------------------------------------------------------
// Condition predicate calculation, spans stages 2 and 3

    wire    [`GROUP_SELECTOR_WIDTH-1:0]     A_selector;
    wire                                    A_negative;
    wire                                    A_carryout;
    wire                                    A_sentinel;
    wire                                    A_external;
    wire    [`GROUP_SELECTOR_WIDTH-1:0]     B_selector;
    wire                                    B_lessthan;
    wire                                    B_counter;
    wire                                    B_sentinel;
    wire                                    B_external;
    wire    [`DYADIC_CTRL_WIDTH-1:0]        AB_operator;
    wire                                    predicate_stage4;

    always @(*) begin
        {A_negative,A_carryout,A_sentinel,A_external,B_lessthan,B_counter,B_sentinel,B_external} <= flags_previous_stage2;
        {A_selector,B_selector,AB_operator}                                                      <= branch_condition;
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
        .predicate      (predicate_stage4)
    );

// --------------------------------------------------------------------
// Pipeline the other signals, also along stages 2 and 3

    wire [PC_WIDTH-1:0] branch_destination_stage4;
    wire                branch_predict_taken_stage4;
    wire                branch_predict_enable_stage4;

    localparam MISC_WIDTH = PC_WIDTH + 2;

    Delay_Line
    #(
        .DEPTH  (2),
        .WIDTH  (MISC_WIDTH)
    )
    DL_misc
    (
        .clock  (clock),
        .in     ({branch_destination,        branch_predict_taken,        branch_predict_enable}),
        .out    ({branch_destination_stage4, branch_predict_taken_stage4, branch_predict_enable_stage4})
    );


// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 3

    // Nothing new here. All signals aligned to stage 4 with Delay_Lines.

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Stage 4

    // Send out the branch destination. Filtered later by jump signal.

    always @(posedge clock) begin
        destination <= branch_destination_stage4;
    end

// --------------------------------------------------------------------

    // Signal a jump if we've reached the branch origin and met its conditions.
    // If the previous instruction was annulled via IO_ready, then instead
    // return the saved jump value, since the current condition is invalid.

    wire jump_saved;

    // DEPTH: minus one since delayed version used before jump output register

    Delay_Line
    #(
        .DEPTH  (`OCTAVO_THREAD_COUNT - 1),
        .WIDTH  (1)
    )
    DL_bom
    (
        .clock  (clock),
        .in     (jump),
        .out    (jump_saved)
    );

    always @(posedge clock) begin
        jump = (predicate_stage4 == 1);
        jump = (IO_ready_previous == 0) ? jump_saved : jump;
        jump = (branch_origin_match_stage4 == 1) & (jump == 1);
    end

// --------------------------------------------------------------------

    // If we have reached the branch origin, and the branch state (taken, not
    // taken) does not match the branch prediction, and branch prediction is
    // enabled, then signal to cancel the concurrent ALU instruction.
    // Filtered later by jump signal.

    always @(posedge clock) begin
        cancel <= (branch_origin_match_stage4 == 1) & (branch_predict_taken_stage4 != predicate_stage4) & (branch_predict_enable_stage4 == 1);
    end

endmodule

