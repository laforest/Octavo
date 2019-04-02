
// Triadic ALU Feedback Path

// Returns previous result (R) and stored previous result (S) to ALU Forward
// Path, as well as some flags if R is zero or negative.

`default_nettype none

module Triadic_ALU_Feedback_Path
#(
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    // S register
    parameter       S_WRITE_ADDR        = 0,
    parameter       S_RAMSTYLE          = "",
    parameter       S_READ_NEW_DATA     = 0,
    // Multithreading
    parameter       THREAD_COUNT        = 0,
    parameter       THREAD_COUNT_WIDTH  = 0
)
(
    input   wire                        clock,

    input   wire    [WORD_WIDTH-1:0]    Ra,         // ALU First Result
    input   wire    [WORD_WIDTH-1:0]    Rb,         // ALU Second Result
    input   wire    [ADDR_WIDTH-1:0]    DB,         // Write Address for Rb, used for S
    input   wire                        IO_Ready,
    input   wire                        Cancel,

    output  wire    [WORD_WIDTH-1:0]    R,          // Previous Result (Ra from prev instr.)
    output  wire                        R_zero,     // Is R zero? (all-1 if true)
    output  wire                        R_negative, // Is R negative? (all-1 if true)
    output  wire    [WORD_WIDTH-1:0]    S           // Stored Previous Result (from Rb)
);

// --------------------------------------------------------------------

    localparam INPUT_SYNC_DEPTH  = 2;
    localparam INPUT_SYNC_WIDTH  = 1 + 1 + ADDR_WIDTH + WORD_WIDTH + WORD_WIDTH;

    localparam OUTPUT_SYNC_DEPTH = 1;
    localparam OUTPUT_SYNC_WIDTH = 1 + 1 + WORD_WIDTH + WORD_WIDTH;

// --------------------------------------------------------------------
// Stage 3 (going backwards)

    // Synchronize inputs to Stage 2

    wire                    IO_Ready_stage2;
    wire                    Cancel_stage2;
    wire [ADDR_WIDTH-1:0]   DB_stage2;
    wire [WORD_WIDTH-1:0]   Ra_stage2;
    wire [WORD_WIDTH-1:0]   Rb_stage2;

    Delay_Line 
    #(
        .DEPTH  (INPUT_SYNC_DEPTH-1), 
        .WIDTH  (INPUT_SYNC_WIDTH)
    ) 
    Input_Sync_Stage3
    (
        .clock  (clock),
        .in     ({IO_Ready,          Cancel,         DB,         Ra,         Rb}),
        .out    ({IO_Ready_stage2,   Cancel_stage2,  DB_stage2,  Ra_stage2,  Rb_stage2})
    );

// --------------------------------------------------------------------
// Stage 2 (going backwards)

    // Store Rb into S if DB matches S_WRITE_ADDR and not a NOP

    reg not_nop = 0;

    always @(*) begin
        not_nop = (IO_Ready_stage2 == 1'b1) & (Cancel_stage2 == 1'b0);
    end

// --------------------------------------------------------------------

    wire S_wren_stage2;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH     (ADDR_WIDTH),
        .ADDR_BASE      (S_WRITE_ADDR),
        .ADDR_BOUND     (S_WRITE_ADDR) 
    )
    S_ADDR_MATCH
    (
        .enable         (not_nop),
        .addr           (DB_stage2),
        .hit            (S_wren_stage2)   
    );

// --------------------------------------------------------------------

    // Synchronize inputs to Stage 1
    // Drop DB address and replace with write enable derived from it.

    wire                    S_wren_stage1;
    wire [WORD_WIDTH-1:0]   Ra_stage1;
    wire [WORD_WIDTH-1:0]   Rb_stage1;

    Delay_Line 
    #(
        .DEPTH  (1), 
        .WIDTH  (WORD_WIDTH + WORD_WIDTH + 1)
    ) 
    Input_Sync_Stage2
    (
        .clock  (clock),
        .in     ({S_wren_stage2,  Ra_stage2,  Rb_stage2}),
        .out    ({S_wren_stage1,  Ra_stage1,  Rb_stage1})
    );

// --------------------------------------------------------------------
// Stage 1

    // S Register, once instance per thread. 
    // Like R, but memory-addressed and persistent.
    // For now, S is only a single register
    // Expressing it this way leaves the door open to expansion

    wire [THREAD_COUNT_WIDTH-1:0] S_thread_write;
    wire [THREAD_COUNT_WIDTH-1:0] S_thread_read;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TN_S
    (
        .clock              (clock),
        .current_thread     (S_thread_write),
        .next_thread        (S_thread_read)
    );

    // Read address leads by one cycle to have value read out 
    // by the time we need it and (maybe) overwrite it.

    wire [WORD_WIDTH-1:0] S_stage0;

    RAM_SDP 
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (THREAD_COUNT_WIDTH),
        .DEPTH          (THREAD_COUNT),
        .RAMSTYLE       (S_RAMSTYLE),
        .READ_NEW_DATA  (S_READ_NEW_DATA),
        .USE_INIT_FILE  (0),
        .INIT_FILE      ()
    )
    S_Register
    (
        .clock          (clock),
        .wren           (S_wren_stage1),
        .write_addr     (S_thread_write),
        .write_data     (Rb_stage1),
        .rden           (1'b1),
        .read_addr      (S_thread_read), 
        .read_data      (S_stage0)
    );

// --------------------------------------------------------------------

    // Compute R flags

    wire R_zero_raw;
    wire R_negative_raw;

    R_Flags
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    R_Flags
    (
        .R          (Ra_stage1),
        .R_zero     (R_zero_raw),
        .R_negative (R_negative_raw)
    );

    reg  R_zero_stage0      = 0;
    reg  R_negative_stage0  = 0;

    always @(posedge clock) begin
        R_zero_stage0       <= R_zero_raw;
        R_negative_stage0   <= R_negative_raw;
    end

// --------------------------------------------------------------------

    // Pass along Ra_stage1

    reg [WORD_WIDTH-1:0] Ra_stage0 = 0;

    always @(posedge clock) begin
        Ra_stage0 <= Ra_stage1;
    end

// --------------------------------------------------------------------
// Stage 0

    // Synchronize outputs

    Delay_Line 
    #(
        .DEPTH  (OUTPUT_SYNC_DEPTH), 
        .WIDTH  (OUTPUT_SYNC_WIDTH)
    ) 
    Output_Sync
    (
        .clock  (clock),
        .in     ({Ra_stage0, R_zero_stage0,  R_negative_stage0,  S_stage0}),
        .out    ({R,         R_zero,         R_negative,         S})
    );

endmodule

