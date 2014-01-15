// Memory providing one of multiple per-thread values.
// Useful for offsets, increments, and other repeated values

module Thread_Value
#(
    parameter   WORD_WIDTH              = 0,
    parameter   ADDR_WIDTH              = 0,
    parameter   DEPTH                   = 0,
    parameter   RAMSTYLE                = 0,
    parameter   INIT_FILE               = 0,

    parameter   INITIAL_THREAD          = 0,
    parameter   THREAD_COUNT            = 0,
    parameter   THREAD_ADDR_WIDTH       = 0
)
(
    input   wire                        clock,
    input   wire                        wren,
    input   wire    [ADDR_WIDTH-1:0]    write_addr,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_addr,
    output  reg     [WORD_WIDTH-1:0]    read_data
);
    wire    [THREAD_ADDR_WIDTH-1:0] current_thread;
    wire    [THREAD_ADDR_WIDTH-1:0] next_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        (next_thread)
    );

    reg     [ADDR_WIDTH-1:0]    final_read_addr;
    reg     [ADDR_WIDTH-1:0]    final_write_addr;

    always @(*) begin
        final_read_addr  <= {next_thread,    read_addr [ADDR_WIDTH-THREAD_ADDR_WIDTH-1:0]};
        final_write_addr <= {current_thread, write_addr[ADDR_WIDTH-THREAD_ADDR_WIDTH-1:0]};
    end

    wire    [WORD_WIDTH-1:0]    thread_value;

    RAM_SDP
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    Values
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (final_write_addr),
        .write_data         (write_data),
        .read_addr          (final_read_addr),
        .read_data          (thread_value)
    );

    // Always necessary after a RAM_SDP: gets retimed into block ram for speed
    always @(posedge clock) begin
        read_data <= thread_value;
    end
endmodule

