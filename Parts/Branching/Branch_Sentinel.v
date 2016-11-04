
// Branch Sentinel Value Check
// Checks if the result of the previous instruction matches
// a sentinel value: a test for equality, with masking.

// Multi-threaded

module Branch_Sentinel
#(
    parameter       WORD_WIDTH          = 0,
    parameter       RAMSTYLE            = ""
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    R,
    input   wire                        configuration_wren,
    input   wire                        configuration_addr,
    input   wire    [WORD_WIDTH-1:0]    configuration_data,
    output  wire                        match
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
    BS_TN
    (
        .clock              (clock),
        .current_thread     (thread_number_write),
        .next_thread        (thread_number_read)
    );

// --------------------------------------------------------------------

    // Sentinel value. One word per thread.

    wire    [WORD_WIDTH-1:0]    sentinel;
    reg                         sentinel_wren   = 0;

    always @(*) begin
        sentinel_wren <= (configuration_addr == 1'b0) & (configuration_wren == 1'b1);
    end

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
    BS_sentinel
    (
        .clock          (clock),
        .wren           (sentinel_wren),
        .write_addr     (thread_number_write),
        .write_data     (configuration_data),
        .rden           (1'b1),
        .read_addr      (thread_number_read),
        .read_data      (sentinel)
    );

// --------------------------------------------------------------------

    // Mask value. One word per thread.

    wire    [WORD_WIDTH-1:0]    mask        = 0;
    reg                         mask_wren   = 0;

    always @(*) begin
        mask_wren <= (configuration_addr == 1'b1) & (configuration_wren == 1'b1);
    end


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
    BS_mask
    (
        .clock          (clock),
        .wren           (mask_wren),
        .write_addr     (thread_number_write),
        .write_data     (configuration_data),
        .rden           (1'b1),
        .read_addr      (thread_number_read),
        .read_data      (mask)
    );

// --------------------------------------------------------------------

    Sentinel_Value_Check
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    BS_SVC
    (
        .in         (R),
        .sentinel   (sentinel),
        .mask       (mask),
        .match      (match)
    );

endmodule

