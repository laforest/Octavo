
// The Controller holds and provides Program Counter values for each thread,
// issued in a fixed round-robin order, including the previous pc value to
// re-issue annulled instructions.

`default_nettype none

module Controller
#(
    parameter       PC_WIDTH            = 0,   
    // Common RAM parameters
    parameter       RAMSTYLE            = "",
    parameter       READ_NEW_DATA       = 0,
    parameter       PC_INIT_FILE        = "",
    parameter       PC_PREV_INIT_FILE   = "",
    // Multithreading
    parameter       THREAD_COUNT        = 0,
    parameter       THREAD_COUNT_WIDTH  = 0
)
(
    input   wire                        clock, 
    input   wire                        IO_ready,
    input   wire                        cancel,
    input   wire                        jump,
    input   wire    [PC_WIDTH-1:0]      jump_destination,
    output  reg     [PC_WIDTH-1:0]      pc
);

// ---------------------------------------------------------------------

    initial begin
        pc = 0;
    end

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 0

    wire [THREAD_COUNT_WIDTH-1:0] read_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID_READ
    (
        .clock              (clock),
        .current_thread     (read_thread),
        // verilator lint_off PINCONNECTEMPTY
        .next_thread        ()
        // verilator lint_on  PINCONNECTEMPTY
    );

// ---------------------------------------------------------------------
// Write thread number is behind read thread number by the number of pipeline 
// stages in the module, so we can write back the new pc to the same memory entry.

    localparam STAGE_COUNT = 2;

    wire [THREAD_COUNT_WIDTH-1:0] write_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (THREAD_COUNT-STAGE_COUNT),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID_WRITE
    (
        .clock              (clock),
        .current_thread     (write_thread),
        // verilator lint_off PINCONNECTEMPTY
        .next_thread        ()
        // verilator lint_on  PINCONNECTEMPTY
    );

// ---------------------------------------------------------------------
// Delay writes to memories to avoid corrupting current and previous PCs
// of "previous" threads with initial zero PC value.

    wire wren;

    Delay_Line
    #(
        .DEPTH  (STAGE_COUNT),
        .WIDTH  (1)
    )
    DL_PC_WREN
    (
        .clock  (clock),
        .in     (1'b1),
        .out    (wren)
    );

// ---------------------------------------------------------------------
// Program Counters, current and previous values

    reg  [PC_WIDTH-1:0] pc_next     = 0;
    wire [PC_WIDTH-1:0] pc_current;
    wire [PC_WIDTH-1:0] pc_previous;

    RAM_SDP
    #(
        .WORD_WIDTH     (PC_WIDTH),
        .ADDR_WIDTH     (THREAD_COUNT_WIDTH),
        .DEPTH          (THREAD_COUNT),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        .USE_INIT_FILE  (1),
        .INIT_FILE      (PC_INIT_FILE)
    )
    PC_MEM
    (
        .clock          (clock),
        .wren           (wren),
        .write_addr     (write_thread),
        .write_data     (pc_next),
        .rden           (1'b1),
        .read_addr      (read_thread),
        .read_data      (pc_current)
    );

    RAM_SDP
    #(
        .WORD_WIDTH     (PC_WIDTH),
        .ADDR_WIDTH     (THREAD_COUNT_WIDTH),
        .DEPTH          (THREAD_COUNT),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        .USE_INIT_FILE  (1),
        .INIT_FILE      (PC_PREV_INIT_FILE)
    )
    PC_PREV_MEM
    (
        .clock          (clock),
        .wren           (wren),
        .write_addr     (write_thread),
        .write_data     (pc),
        .rden           (1'b1),
        .read_addr      (read_thread),
        .read_data      (pc_previous)
    );

// ---------------------------------------------------------------------
// Sync inputs to Stage 1

    reg                 IO_ready_stage1         = 0;
    reg                 cancel_stage1           = 0;
    reg                 jump_stage1             = 0;
    reg [PC_WIDTH-1:0]  jump_destination_stage1 = 0;

    always @(posedge clock) begin
        IO_ready_stage1         <= IO_ready;
        cancel_stage1           <= cancel;
        jump_stage1             <= jump;
        jump_destination_stage1 <= jump_destination;
    end

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 1

    reg [PC_WIDTH-1:0]  pc_new  = 0;
    reg                 reissue = 0;

    // Cancelling an instruction overrides re-issuing it if IO is not ready.
    always @(*) begin
        pc_new  = (jump_stage1 == 1'b1) ? jump_destination_stage1 : pc_current;
        reissue = (IO_ready_stage1 == 1'b0) & (cancel_stage1 == 1'b0);
    end

    always @(posedge clock) begin
        pc <= (reissue == 1'b1) ? pc_previous : pc_new;
    end

// ---------------------------------------------------------------------
// Prepare PC of next instruction

    localparam PC_ONE = {{PC_WIDTH-1{1'b0}},1'b1};

    always @(*) begin
        pc_next = pc + PC_ONE;
    end

endmodule

