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
    output  wire    [WORD_WIDTH-1:0]    addr_out
);
    wire    [WORD_WIDTH-1:0]    offset;

    Thread_Value
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE),

        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    Offsets
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (write_addr),
        .write_data         (write_data),
        .read_addr          ({ADDR_WIDTH{`LOW}}),
        .read_data          (offset)
    );

    Offset_Selector
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    Offset_Selector
    (
        .clock          (clock),
        .addr_in        (addr_in),
        .offset         (offset),
        .use_raw_addr   (use_raw_addr),
        .addr_out       (addr_out)
    );
endmodule

