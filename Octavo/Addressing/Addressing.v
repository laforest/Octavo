
// Adds a per-thread offset to addresses to make shared code access per-thread
// private data. This includes the shared I/O and high-mem areas.

// Generic version needing external offset enable.  wren moved to higher level
// to abstract away operand width

module Addressing
#(
    parameter   DEFAULT_OFFSET_WORD_WIDTH   = 0,
    parameter   DEFAULT_OFFSET_ADDR_WIDTH   = 0,
    parameter   DEFAULT_OFFSET_DEPTH        = 0,
    parameter   DEFAULT_OFFSET_RAMSTYLE     = 0,
    parameter   DEFAULT_OFFSET_INIT_FILE    = 0,

    parameter   INITIAL_THREAD              = 0,
    parameter   THREAD_COUNT                = 0,
    parameter   THREAD_ADDR_WIDTH           = 0
)
(
    input   wire                        					clock,
    input   wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0] 	addr_in,
    input   wire                        					default_offset_wren,
    input   wire    [DEFAULT_OFFSET_ADDR_WIDTH-1:0]   write_addr,
    input   wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]   write_data,
    output  reg     [DEFAULT_OFFSET_WORD_WIDTH-1:0]   addr_out
);
    wire    [THREAD_ADDR_WIDTH-1:0] read_thread_BBC;
    wire    [THREAD_ADDR_WIDTH-1:0] write_thread;

    Addressing_Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .read_thread        (read_thread_BBC),
        .write_thread       (write_thread)
    );

    reg     [THREAD_ADDR_WIDTH-1:0] read_thread_MEM;

    initial begin
        read_thread_MEM = 0;
    end

    // synchronize read_thread with Basic Block Counter output
    always @(posedge clock) begin
        read_thread_MEM <= read_thread_BBC;
    end

    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]    default_offset;

    RAM_SDP_no_fw
    #(
        .WORD_WIDTH         (DEFAULT_OFFSET_WORD_WIDTH),
        .ADDR_WIDTH         (DEFAULT_OFFSET_ADDR_WIDTH),
        .DEPTH              (DEFAULT_OFFSET_DEPTH),
        .RAMSTYLE           (DEFAULT_OFFSET_RAMSTYLE),
        .INIT_FILE          (DEFAULT_OFFSET_INIT_FILE)
    )
    Default_Offset
    (
        .clock              (clock),
        .wren               (default_offset_wren),
        .write_addr         (write_thread),
        .write_data         (write_data),
        .read_addr          (read_thread_MEM),
        .read_data          (default_offset)
    );

    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]    default_offset_final;

    delay_line 
    #(
        .DEPTH  (2),
        .WIDTH  (DEFAULT_OFFSET_WORD_WIDTH)
    ) 
    default_offset_pipeline
    (    
        .clock  (clock),
        .in     (default_offset),
        .out    (default_offset_final)
    );

    reg    [DEFAULT_OFFSET_WORD_WIDTH-1:0]    offset_final;

    // Mux goes here later
    always @(*) begin
        offset_final <= default_offset_final;
    end

    reg     [DEFAULT_OFFSET_WORD_WIDTH-1:0]    raw_addr;

    always @(posedge clock) begin
        raw_addr <= addr_in;
        addr_out <= raw_addr + offset_final;
    end
endmodule

