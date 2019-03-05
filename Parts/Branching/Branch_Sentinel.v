
// Branch Sentinel Value Check
// Checks if the result of the previous instruction matches
// a sentinel value: a test for equality, with masking.

// Multi-threaded: one sentinel and mask value per thread.
// Make sure R and the configuration writes are properly synchronized
// to the same thread.

`default_nettype none

module Branch_Sentinel
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
    input   wire    [WORD_WIDTH-1:0]    R,
    input   wire                        configuration_wren,
    input   wire                        configuration_addr, // 0/1 for sentinel/mask
    input   wire    [WORD_WIDTH-1:0]    configuration_data,
    output  wire                        match
);

// --------------------------------------------------------------------

    wire [THREAD_COUNT_WIDTH-1:0] thread_addr;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    BS_TN
    (
        .clock              (clock),
        .current_thread     (thread_addr),
        // verilator lint_off PINCONNECTEMPTY
        .next_thread        ()
        // verilator lint_on  PINCONNECTEMPTY
    );

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 0

    // Sentinel value. One word per thread.

    wire    [WORD_WIDTH-1:0]    sentinel;
    reg                         sentinel_wren   = 0;

    always @(*) begin
        sentinel_wren = (configuration_addr == 1'b0) & (configuration_wren == 1'b1);
    end

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
    BS_sentinel
    (
        .clock          (clock),
        .wren           (sentinel_wren),
        .write_addr     (thread_addr),
        .write_data     (configuration_data),
        .rden           (1'b1),
        .read_addr      (thread_addr),
        .read_data      (sentinel)
    );

// --------------------------------------------------------------------

    // Mask value. One word per thread.

    wire    [WORD_WIDTH-1:0]    mask;
    reg                         mask_wren   = 0;

    always @(*) begin
        mask_wren = (configuration_addr == 1'b1) & (configuration_wren == 1'b1);
    end

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
    BS_mask
    (
        .clock          (clock),
        .wren           (mask_wren),
        .write_addr     (thread_addr),
        .write_data     (configuration_data),
        .rden           (1'b1),
        .read_addr      (thread_addr),
        .read_data      (mask)
    );

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 1

    // This logic pulled out of Sentinel_Value_Check for timing.
    // Mask is inverted so the default of 0 masks nothing (exact match).

    reg [WORD_WIDTH-1:0] sentinel_masked = 0;

    always @(*) begin
        sentinel_masked = sentinel & ~mask;
    end

// ---------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] sentinel_masked_sync;
    wire [WORD_WIDTH-1:0] mask_sync;

    Delay_Line 
    #(
        .DEPTH  (1), 
        .WIDTH  (WORD_WIDTH + WORD_WIDTH)
    ) 
    DL_BS
    (
        .clock  (clock),
        .in     ({sentinel_masked,      mask}),
        .out    ({sentinel_masked_sync, mask_sync})
    );

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 2 (unregistered)

    Sentinel_Value_Check
    #(
        .WORD_WIDTH         (WORD_WIDTH)
    )
    BS_SVC
    (
        .data_in            (R),
        .sentinel_masked    (sentinel_masked_sync),
        .mask               (mask_sync),
        .match              (match)
    );

endmodule

