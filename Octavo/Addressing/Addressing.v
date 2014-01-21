
// Memory providing one of multiple per-thread values.
// Useful for offsets, increments, and other repeated values

// ECL Since we are using MLAB here, the normal SDP_RAM behaviour
// won't work: no write forwarding.
// Also, we want a synchronous clear on the output.

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
    input  wire                         read_clear,
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

        if(read_clear == `HIGH) begin
            read_data <= 0;
        end
        else begin
            read_data <= ram[read_addr];
        end
    end

    initial begin
        read_data = 0;
    end
endmodule


// Adds a per-thread offset to non High-Mem and non-I/O addresses to make
// shared code access per-thread private data.

// Generic version needing external offset enable
// wren moved to higher level to abstract away operand width

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
    input   wire                        use_raw_addr,
    input   wire    [WORD_WIDTH-1:0]    addr_in,
    input   wire                        wren,
    input   wire    [ADDR_WIDTH-1:0]    write_addr,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    output  reg     [WORD_WIDTH-1:0]    addr_out
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
        final_read_addr  <= {next_thread,    addr_in[ADDR_WIDTH-THREAD_ADDR_WIDTH-1:0]};
        final_write_addr <= {current_thread, write_addr[ADDR_WIDTH-THREAD_ADDR_WIDTH-1:0]};
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
        .read_clear         (use_raw_addr),
        .write_addr         (final_write_addr),
        .write_data         (write_data),
        .read_addr          (final_read_addr),
        .read_data          (offset)
    );

    reg     [WORD_WIDTH-1:0]    raw_addr_1;
    reg     [WORD_WIDTH-1:0]    raw_addr_2;

    always @(posedge clock) begin
        raw_addr_1  <= addr_in;
        raw_addr_2  <= raw_addr_1;
    end

    always @(*) begin
        addr_out <= raw_addr_2 + offset;
    end
endmodule

