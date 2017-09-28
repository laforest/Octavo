
// Simple Multithreaded Dual Port RAM. One write port and one read port,
// separately addressed, with common clock.  Common data width on both ports.

// Replicated the address space for each of multiple round-robin fixed-order
// threads. One thread each clock cycle. Each thread gets a memory of
// THREAD_DEPTH entries.

// The INIT_FILE initialises memory for all threads. Must be of RAM_DEPTH
// depth.

// Set the initial read and write thread number value to synchronize with rest
// of pipeline.

// See RAM_SDP.v for further parameter and operation documentation.

`default_nettype none

module RAM_SDP_Multithreaded
#(
    parameter       WORD_WIDTH              = 0,
    parameter       ADDR_WIDTH              = 0,
    parameter       THREAD_DEPTH            = 0,
    parameter       RAMSTYLE                = "",
    parameter       READ_NEW_DATA           = 0,
    parameter       USE_INIT_FILE           = 0,
    parameter       INIT_FILE               = "",
    // Multithreading
    parameter       THREAD_COUNT            = 0,
    parameter       THREAD_COUNT_WIDTH      = 0,
    parameter       INITIAL_THREAD_READ     = 0,
    parameter       INITIAL_THREAD_WRITE    = 0
)
(
    input  wire                             clock,
    input  wire                             wren,
    input  wire     [ADDR_WIDTH-1:0]        write_addr,
    input  wire     [WORD_WIDTH-1:0]        write_data,
    input  wire                             rden,
    input  wire     [ADDR_WIDTH-1:0]        read_addr, 
    output wire     [WORD_WIDTH-1:0]        read_data
);

// -----------------------------------------------------------

    localparam RAM_ADDR_WIDTH = ADDR_WIDTH   + THREAD_COUNT_WIDTH;
    localparam RAM_DEPTH      = THREAD_DEPTH * THREAD_COUNT;

// -----------------------------------------------------------

    wire [THREAD_COUNT_WIDTH-1:0] read_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD_READ),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TN_READ
    (
        .clock              (clock),
        .current_thread     (read_thread),
        .next_thread        ()
    );

    wire [THREAD_COUNT_WIDTH-1:0] write_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD_WRITE),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TN_WRITE
    (
        .clock              (clock),
        .current_thread     (write_thread),
        .next_thread        ()
    );

// --------------------------------------------------------------------

    reg [RAM_ADDR_WIDTH-1:0] ram_read_addr  = 0;
    reg [RAM_ADDR_WIDTH-1:0] ram_write_addr = 0;

    always @(*) begin
        ram_read_addr   <= {read_thread,  read_addr};
        ram_write_addr  <= {write_thread, write_addr};
    end

// --------------------------------------------------------------------

    RAM_SDP
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (RAM_ADDR_WIDTH),
        .DEPTH          (RAM_DEPTH),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        .USE_INIT_FILE  (USE_INIT_FILE),
        .INIT_FILE      (INIT_FILE)
    )
    RAM
    (
        .clock          (clock),
        .wren           (wren),
        .write_addr     (ram_write_addr),
        .write_data     (write_data),
        .rden           (rden),
        .read_addr      (ram_read_addr), 
        .read_data      (read_data)
    );

endmodule

