
// Memory Mapper: Takes an address and returns a valid signal and the
// necessary Least-Significant Bits (LSBs), translated to a 0-based address
// range, to address the target hardware.

// Unfortunately, since there is no way to specify the port width as the
// outcome of a constant function defined in the same module, nor tell the
// enclosing module the resulting port width, we have to calculate some
// parameters in the enclosing module.

// It is assumed here that the decoded address range fits inside the
// ADDR_WIDTH_LSB, provided from enclosing module as:
// max(1, ceil(log_2(ADDR_BASE-ADDR_BOUND+1)))
// (force degenerate case of one location to use one address bit, 
// which will always be zero)

`default_nettype none

module Memory_Mapper
#(
    parameter       ADDR_WIDTH              = 0,
    parameter       ADDR_BASE               = 0,
    parameter       ADDR_BOUND              = 0,
    parameter       ADDR_WIDTH_LSB          = 0,
    parameter       REGISTERED              = 0 // clock not used if zero

)
(
    input   wire                            clock,
    input   wire                            enable,
    input   wire    [ADDR_WIDTH-1:0]        addr,
    output  wire    [ADDR_WIDTH_LSB-1:0]    addr_translated_lsb,
    output  reg                             addr_valid
);

// -----------------------------------------------------------

    initial begin
        addr_valid = 1'b0;
    end

// -----------------------------------------------------------

    // Translate the LSBs of the address to a zero-based index.

    localparam ADDR_COUNT    = ADDR_BOUND - ADDR_BASE + 1;
    localparam ADDR_BASE_LSB = ADDR_BASE [ADDR_WIDTH_LSB-1:0];

    Address_Range_Translator
    #(
        .ADDR_COUNT         (ADDR_COUNT),
        .ADDR_BASE          (ADDR_BASE_LSB),
        .ADDR_WIDTH         (ADDR_WIDTH_LSB),
        .REGISTERED         (REGISTERED)
    )
    ART
    (
        .clock              (clock),
        .raw_address        (addr [ADDR_WIDTH_LSB-1:0]),
        .translated_address (addr_translated_lsb)
    );

// -----------------------------------------------------------

    // Decode the full address to see if we are within the BASE and BOUND,
    // inclusive.

    wire addr_valid_raw;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ADDR_BASE  (ADDR_BASE),
        .ADDR_BOUND (ADDR_BOUND)
    )
    ARDS
    (
        .enable     (enable),
        .addr       (addr),
        .hit        (addr_valid_raw)
    );

// -----------------------------------------------------------

    // This exists because of the odd way the Address_Range_Translator must
    // be registered. See its implementation.

    generate
        if (REGISTERED == 1'b1) begin
            always @(posedge clock) begin
                addr_valid <= addr_valid_raw;
            end
        end
        else begin
            always @(*) begin
                addr_valid = addr_valid_raw;
            end
        end
    endgenerate

endmodule

