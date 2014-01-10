// Adds a per-thread offset to non High-Mem and non-I/O addresses to make
// shared code access per-thread private data.

module Addressing
#(
    parameter   OFFSETS_WORD_WIDTH          = 0,
    parameter   OFFSETS_ADDR_WIDTH          = 0,
    parameter   OFFSETS_COUNT               = 0,
    parameter   OFFSETS_RAMSTYLE            = 0,
    parameter   OFFSETS_INIT_FILE           = 0,

    parameter   OFFSETS_H_ADDR_BASE         = 0,
    parameter   OFFSETS_WRITE_DELAY         = 0,

    parameter   WORD_WIDTH                  = 0,
    parameter   READ_ADDR_WIDTH             = 0,
    parameter   WRITE_ADDR_WIDTH            = 0,

    parameter   H_WRITE_ADDR_OFFSET         = 0,
    parameter   H_DEPTH                     = 0,

    parameter   IO_ADDR_BASE                = 0,
    parameter   IO_ADDR_COUNT               = 0,

    parameter   INITIAL_THREAD              = 0,
    parameter   THREAD_COUNT                = 0,
    parameter   THREAD_ADDR_WIDTH           = 0
)
(
    input   wire                            clock,
    input   wire    [READ_ADDR_WIDTH-1:0]   addr_in,
    input   wire    [WRITE_ADDR_WIDTH-1:0]  write_addr,
    input   wire    [WORD_WIDTH-1:0]        write_data,
    output  wire    [READ_ADDR_WIDTH-1:0]   addr_out
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

    wire    [THREAD_ADDR_WIDTH-1:0]     offsets_current_thread;

    delay_line 
    #(
        .DEPTH  (OFFSETS_WRITE_DELAY),
        .WIDTH  (THREAD_ADDR_WIDTH)
    ) 
    TID_sync
    (
        .clock  (clock),
        .in     (next_thread),
        .out    (offsets_current_thread)
    );

    wire    [WRITE_ADDR_WIDTH-1:0]    offsets_write_addr;

    delay_line 
    #(
        .DEPTH  (OFFSETS_WRITE_DELAY),
        .WIDTH  (WRITE_ADDR_WIDTH)
    ) 
    write_addr_TID_sync
    (
        .clock  (clock),
        .in     (write_addr),
        .out    (offsets_write_addr)
    );

    wire    [WORD_WIDTH-1:0]    offsets_write_data;

    delay_line 
    #(
        .DEPTH  (OFFSETS_WRITE_DELAY),
        .WIDTH  (WORD_WIDTH)
    ) 
    write_data_TID_sync
    (
        .clock  (clock),
        .in     (write_data),
        .out    (offsets_write_data)
    );

    wire                wren;

    Address_Decoder
    #(
        .ADDR_COUNT     (THREAD_COUNT), 
        .ADDR_BASE      (OFFSETS_H_ADDR_BASE),
        .ADDR_WIDTH     (WRITE_ADDR_WIDTH),
        .REGISTERED     (`FALSE)
    )
    Offsets_wren
    (
        .clock          (`LOW),
        .addr           (offsets_write_addr),
        .hit            (wren) 
    );

    reg     [OFFSETS_ADDR_WIDTH-1:0]    final_offsets_write_addr;

    always @(*) begin
        final_offsets_write_addr <= {offsets_current_thread, offsets_write_addr[OFFSETS_ADDR_WIDTH-THREAD_ADDR_WIDTH-1:0]};
    end

    reg     [READ_ADDR_WIDTH-1:0]   final_offsets_read_addr;

    // XXX ECL Multiple offsets (for indirection) will be read from here, later.
    always @(*) begin
        final_offsets_read_addr <= {next_thread, {OFFSETS_ADDR_WIDTH-THREAD_ADDR_WIDTH{1'b0}} };
    end

    wire    [OFFSETS_WORD_WIDTH-1:0]    offset;

    RAM_SDP
    #(
        .WORD_WIDTH         (OFFSETS_WORD_WIDTH),
        .ADDR_WIDTH         (OFFSETS_ADDR_WIDTH),
        .DEPTH              (OFFSETS_COUNT),
        .RAMSTYLE           (OFFSETS_RAMSTYLE),
        .INIT_FILE          (OFFSETS_INIT_FILE)
    )
    Offsets
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (final_offsets_write_addr),
        .write_data         (offsets_write_data[OFFSETS_WORD_WIDTH-1:0]),
        .read_addr          (final_offsets_read_addr),
        .read_data          (offset)
    );

    reg     [READ_ADDR_WIDTH-1:0]   raw_addr;
    reg     [READ_ADDR_WIDTH-1:0]   offset_addr;

    always @(posedge clock) begin
        raw_addr    <= addr_in;
        offset_addr <= addr_in + offset;
    end

    wire                in_highmem;

    Address_Decoder
    #(
        .ADDR_COUNT     (H_DEPTH), 
        .ADDR_BASE      (H_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (READ_ADDR_WIDTH),
        .REGISTERED     (`FALSE)
    )
    highmem
    (
        .clock          (`LOW),
        .addr           (addr_in),
        .hit            (in_highmem)   
    );

    wire                in_io;

    Address_Decoder
    #(
        .ADDR_COUNT     (IO_ADDR_COUNT), 
        .ADDR_BASE      (IO_ADDR_BASE),
        .ADDR_WIDTH     (READ_ADDR_WIDTH),
        .REGISTERED     (`FALSE)
    )
    io
    (
        .clock          (`LOW),
        .addr           (addr_in),
        .hit            (in_io)   
    );

    // IO XOR HIGHMEM addresses remain unstranslated.
    // Mutually exclusive address ranges by design. (see mem map)
    reg     use_raw_addr;

    always @(posedge clock) begin
        use_raw_addr <= in_io ^ in_highmem;
    end

    Addressed_Mux
    #(
        .WORD_WIDTH         (READ_ADDR_WIDTH),
        .ADDR_WIDTH         (1),
        .INPUT_COUNT        (2),
        .REGISTERED         (`TRUE)
    )
    Address_Select
    (
        .clock              (clock),
        .addr               (use_raw_addr),
        .data_in            ({raw_addr, offset_addr}), 
        .data_out           (addr_out)
    );

endmodule

