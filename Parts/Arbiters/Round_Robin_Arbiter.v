
// Returns a single bit set from all set request bits, in a round-robin order
// going from LSB to MSB and back around. Requests can be added or dropped
// on-the-fly, but synchronously.

`default_nettype none

module Round_Robin_Arbiter
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    requests,
    output  reg     [WORD_WIDTH-1:0]    grant
);

    localparam zero = {WORD_WIDTH{1'b0}};

// --------------------------------------------------------------------

    // Grant a request in priority order (LSB has higest priority)

    wire [WORD_WIDTH-1:0] grant_raw;

    Priority_Arbiter
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Raw
    (
        .requests   (requests),
        .grant      (grant_raw)
    );

// --------------------------------------------------------------------

    // Mask-off all requests of higher priority 
    // than the request granted in the previous cycle.

    wire [WORD_WIDTH-1:0] mask;

    Thermometer_Mask
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Grant_Mask
    (
        .bitvector  (grant),
        .mask       (mask)
    );

    reg [WORD_WIDTH-1:0] requests_masked;

    always @(*) begin
        requests_masked = requests & mask;
    end

// --------------------------------------------------------------------

    // Grant a request in priority order, but from the masked requests
    // (equal or lower priority to the request granted last cycle)

    wire [WORD_WIDTH-1:0] grant_masked;

    Priority_Arbiter
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Masked
    (
        .requests   (requests_masked),
        .grant      (grant_masked)
    );

// --------------------------------------------------------------------

    // If no granted requests remain after masking, then grant from the
    // unmasked requests, which starts over granting from the highest (LSB)
    // priority. This also resets the mask. And the process begins again.

    always @(posedge clock) begin
        grant <= (grant_masked == zero) ? grant_raw : grant_masked; 
    end

endmodule

