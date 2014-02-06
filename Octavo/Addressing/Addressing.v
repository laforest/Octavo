
// Memory providing one of multiple per-thread values.
// Useful for offsets, increments, and other repeated values

// ECL Since we are using MLAB here, the normal SDP_RAM behaviour won't work:
// no write forwarding.  Also, we don't want a synchronous clear on the output:
// any register driving it cannot be retimed.

// ECL XXX Factor this out into common file for thread offsets and PC memories.
// We'll need separate BRAM definitions for M9K and MLAB after all.

module Offset_Memory 
#(
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       DEPTH               = 0,
    parameter       RAMSTYLE            = "",
    parameter       INIT_FILE           = ""
)
(
    input  wire                         clock,
    input  wire                         wren,
    input  wire     [ADDR_WIDTH-1:0]    write_addr,
    input  wire     [WORD_WIDTH-1:0]    write_data,
    input  wire     [ADDR_WIDTH-1:0]    read_addr, 
    output reg      [WORD_WIDTH-1:0]    read_data
);
    (* ramstyle = RAMSTYLE *) 
    reg [WORD_WIDTH-1:0] ram [DEPTH-1:0];

    initial begin
        $readmemh(INIT_FILE, ram);
    end

    always @(posedge clock) begin
        if(wren == `HIGH) begin
            ram[write_addr] <= write_data;
        end
    read_data <= ram[read_addr];
    end

    initial begin
        read_data = 0;
    end
endmodule


// Adds a per-thread offset to addresses to make shared code access per-thread
// private data. This includes the shared I/O and high-mem areas.

// Generic version needing external offset enable.  wren moved to higher level
// to abstract away operand width

module Addressing
#(
    parameter   WORD_WIDTH              = 0,
    parameter   ADDR_WIDTH              = 0,
    parameter   DEPTH                   = 0,
    parameter   RAMSTYLE                = 0,
    parameter   INIT_FILE               = 0,
    parameter   BASE_ADDR               = 0,

    parameter   INITIAL_THREAD          = 0,
    parameter   THREAD_COUNT            = 0,
    parameter   THREAD_ADDR_WIDTH       = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    addr_in,
    input   wire                        wren,
    input   wire    [ADDR_WIDTH-1:0]    write_addr,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    output  reg     [WORD_WIDTH-1:0]    addr_out
);
    wire    [THREAD_ADDR_WIDTH-1:0] read_thread_BC;
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
        .read_thread        (read_thread_BC),
        .write_thread       (write_thread)
    );

    reg     [THREAD_ADDR_WIDTH-1:0] read_thread_MEM;

    initial begin
        read_thread_MEM = 0;
    end

    // synchronize read_thread with block counter output
    always @(posedge clock) begin
        read_thread_MEM <= read_thread_BC;
    end

    reg     [ADDR_WIDTH-1:0]    final_read_addr;
    reg     [ADDR_WIDTH-1:0]    final_write_addr;

    integer zero = 0;

    always @(*) begin
        final_read_addr  <= {read_thread_MEM, zero[ADDR_WIDTH-THREAD_ADDR_WIDTH-1:0]};
        final_write_addr <= {write_thread,    zero[ADDR_WIDTH-THREAD_ADDR_WIDTH-1:0]};
    end

    wire    [WORD_WIDTH-1:0]    offset;

    Offset_Memory
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    Offsets
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (final_write_addr),
        .write_data         (write_data),
        .read_addr          (final_read_addr),
        .read_data          (offset)
    );

    wire    [WORD_WIDTH-1:0]    offset_final;

    delay_line 
    #(
        .DEPTH  (2),
        .WIDTH  (WORD_WIDTH)
    ) 
    offset_pipeline
    (    
        .clock  (clock),
        .in     (offset),
        .out    (offset_final)
    );

    reg     [WORD_WIDTH-1:0]    raw_addr;

    always @(posedge clock) begin
        raw_addr  <= addr_in;
        addr_out <= raw_addr + offset_final;
    end
endmodule

