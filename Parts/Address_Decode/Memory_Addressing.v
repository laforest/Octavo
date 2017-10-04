
// Address read/write decoders for memory ranges
// Allows different read and write memory maps
// Base/Bound addresses are inclusive

`default_nettype none

module Memory_Addressing
#(
    parameter   READ_ADDR_WIDTH             = 0,
    parameter   WRITE_ADDR_WIDTH            = 0,
    parameter   MEM_READ_BASE_ADDR          = 0,
    parameter   MEM_READ_BOUND_ADDR         = 0,
    parameter   MEM_WRITE_BASE_ADDR         = 0,
    parameter   MEM_WRITE_BOUND_ADDR        = 0
)
(
    input   wire                            read_IOR,
    input   wire                            read_cancel,
    input   wire    [READ_ADDR_WIDTH-1:0]   read_addr,
    output  wire                            read_enable,

    input   wire                            write_IOR,
    input   wire                            write_cancel,
    input   wire    [WRITE_ADDR_WIDTH-1:0]  write_addr,
    output  wire                            write_enable
);

// --------------------------------------------------------------------

    // Enable reads/writes only if the instruction performing the read/write
    // was not annulled nor cancelled. 

    reg read_instruction_ok  = 0;
    reg write_instruction_ok = 0;

    always @(*) begin
        read_instruction_ok  <= (read_IOR  == 1'b1) & (read_cancel  == 1'b0);
        write_instruction_ok <= (write_IOR == 1'b1) & (write_cancel == 1'b0);
    end

// --------------------------------------------------------------------

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (READ_ADDR_WIDTH),
        .ADDR_BASE  (MEM_READ_BASE_ADDR),
        .ADDR_BOUND (MEM_READ_BOUND_ADDR)
    )
    Read
    (
        .enable     ((read_instruction_ok == 1'b1)),
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
        .enable     ((write_instruction_ok == 1'b1)),
        .addr       (write_addr),
        .hit        (write_enable)
    );

endmodule

