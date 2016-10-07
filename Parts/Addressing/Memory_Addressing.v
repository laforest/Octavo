
// Address read/write decoders for memory ranges
// Allows different read and write memory maps
// but assumes equal read/write depth

module Memory_Addressing
#(
    parameter   READ_ADDR_WIDTH             = 0,
    parameter   WRITE_ADDR_WIDTH            = 0,
    parameter   MEM_READ_BASE_ADDR          = 0,
    parameter   MEM_WRITE_BASE_ADDR         = 0,
    parameter   MEM_DEPTH                   = 0
)
(
    input   wire    [READ_ADDR_WIDTH-1:0]   read_addr,
    input   wire    [WRITE_ADDR_WIDTH-1:0]  write_addr,
    output  wire                            read_enable,
    output  wire                            write_enable
);
// --------------------------------------------------------------------

    // For base/bound address range decoding
    localparam MEM_READ_BOUND_ADDR  = MEM_READ_BASE_ADDR  + MEM_DEPTH - 1;
    localparam MEM_WRITE_BOUND_ADDR = MEM_WRITE_BASE_ADDR + MEM_DEPTH - 1;

// --------------------------------------------------------------------

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (READ_ADDR_WIDTH),
        .ADDR_BASE  (MEM_READ_BASE_ADDR),
        .ADDR_BOUND (MEM_READ_BOUND_ADDR)
    )
    Read
    (
        .enable     (1'b1),
        .addr       (read_addr),
        .hit        (read_enable)
    );

// --------------------------------------------------------------------

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (WRITE_ADDR_WIDTH),
        .ADDR_BASE  (MEM_WRITE_BASE_ADDR),
        .ADDR_BOUND (MEM_WRITE_BOUND_ADDR)
    )
    Write
    (
        .enable     (1'b1),
        .addr       (write_addr),
        .hit        (write_enable)
    );

endmodule

