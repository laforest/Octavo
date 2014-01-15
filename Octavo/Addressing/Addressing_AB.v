// Adds a per-thread offset to non High-Mem and non-I/O addresses to make
// shared code access per-thread private data.

// This version works for the A and B Data memories, each having one I/O port range.
// Decoding the write address is left for a higher level

module Addressing_AB
#(
    parameter   WORD_WIDTH                  = 0,
    parameter   ADDR_WIDTH                  = 0,
    parameter   DEPTH                       = 0,
    parameter   RAMSTYLE                    = 0,
    parameter   INIT_FILE                   = 0,
    parameter   BASE_ADDR                   = 0,

    parameter   IO_ADDR_BASE                = 0,
    parameter   IO_ADDR_COUNT               = 0,

    parameter   INITIAL_THREAD              = 0,
    parameter   THREAD_COUNT                = 0,
    parameter   THREAD_ADDR_WIDTH           = 0
)
(
    input   wire                            clock,
    input   wire    [WORD_WIDTH-1:0]        addr_in,
    input   wire                            wren,
    input   wire    [ADDR_WIDTH-1:0]        write_addr,
    input   wire    [WORD_WIDTH-1:0]        write_data,
    output  wire    [WORD_WIDTH-1:0]        addr_out
);
    wire                in_io;

    Address_Decoder
    #(
        .ADDR_COUNT     (IO_ADDR_COUNT), 
        .ADDR_BASE      (IO_ADDR_BASE),
        .ADDR_WIDTH     (WORD_WIDTH),
        .REGISTERED     (`FALSE)
    )
    io
    (
        .clock          (`LOW),
        .addr           (addr_in),
        .hit            (in_io)   
    );

    Addressing
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE),
        .BASE_ADDR          (BASE_ADDR),

        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    Addressing
    (
        .clock              (clock),
        .use_raw_addr       (in_io),
        .addr_in            (addr_in),
        .wren               (wren),
        .write_addr         (write_addr),
        .write_data         (write_data),
        .addr_out           (addr_out)
    );
endmodule

