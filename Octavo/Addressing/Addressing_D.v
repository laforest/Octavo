// Adds a per-thread offset to non High-Mem and non-I/O addresses to make
// shared code access per-thread private data.

// This version works for the D write address, which can reach both A and B I/O ranges.
// wren decoding done at higher level
// ECL XXX If I Mem ever gets I/O ports, you must update this to match.

module Addressing_D
#(
    parameter   WORD_WIDTH              = 0,
    parameter   ADDR_WIDTH              = 0,
    parameter   DEPTH                   = 0,
    parameter   RAMSTYLE                = 0,
    parameter   INIT_FILE               = 0,
    parameter   BASE_ADDR               = 0,

    parameter   H_WRITE_ADDR_OFFSET     = 0,
    parameter   H_DEPTH                 = 0,

    parameter   A_IO_ADDR_BASE          = 0,
    parameter   A_IO_ADDR_COUNT         = 0,

    parameter   B_IO_ADDR_BASE          = 0,
    parameter   B_IO_ADDR_COUNT         = 0,

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
    output  wire    [WORD_WIDTH-1:0]    addr_out
);
    wire                in_highmem;

    Address_Decoder
    #(
        .ADDR_COUNT     (H_DEPTH), 
        .ADDR_BASE      (H_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (WORD_WIDTH),
        .REGISTERED     (`TRUE)
    )
    highmem
    (
        .clock          (clock),
        .addr           (addr_in),
        .hit            (in_highmem)   
    );

    wire                in_A_io;

    Address_Decoder
    #(
        .ADDR_COUNT     (A_IO_ADDR_COUNT), 
        .ADDR_BASE      (A_IO_ADDR_BASE),
        .ADDR_WIDTH     (WORD_WIDTH),
        .REGISTERED     (`TRUE)
    )
    A_io
    (
        .clock          (clock),
        .addr           (addr_in),
        .hit            (in_A_io)   
    );

    wire                in_B_io;

    Address_Decoder
    #(
        .ADDR_COUNT     (B_IO_ADDR_COUNT), 
        .ADDR_BASE      (B_IO_ADDR_BASE),
        .ADDR_WIDTH     (WORD_WIDTH),
        .REGISTERED     (`TRUE)
    )
    B_io
    (
        .clock          (clock),
        .addr           (addr_in),
        .hit            (in_B_io)   
    );

    // (IO | HIGHMEM) addresses remain unstranslated.
    // Inclusive-OR to allow for future H mem I/O write ports
    // Normaly mutually exclusive address ranges. (see mem map)

    reg     use_raw_addr;

    always @(*) begin
        use_raw_addr <= in_A_io | in_B_io | in_highmem;
    end

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
        .use_raw_addr       (use_raw_addr),
        .addr_in            (addr_in),
        .wren               (wren),
        .write_addr         (write_addr),
        .write_data         (write_data),
        .addr_out           (addr_out)
    );
endmodule

