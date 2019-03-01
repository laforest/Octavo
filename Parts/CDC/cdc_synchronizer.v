
// A basic Clock Domain Crossing synchronizer

// Only pass 1 synchronization bit, as a level change.
// (synchronizing more than one bit across clocks is not deterministic)

// If passing a pulse: must be from slow to fast clock, and
// pulse period must be minimum 3x longer than fast clock period.
// (three receiving fast clock edges per bit level transition)

// For passing a pulse from fast to slow clock, use a pulse synchronizer.

`default_nettype none

module cdc_synchronizer
#(
    // Must be 0 or greater.
    // See DEPTH below for meaning.
    parameter EXTRA_DEPTH = 0
)
(
    input   wire    sync_bit_from,
    input   wire    clock_to,
    output  reg     sync_bit_to
);

// --------------------------------------------------------------------------

    // Minimum valid depth is 2.
    // Add more if the platform requires it.
    // (usually near the highest operating frequencies)
    localparam DEPTH = 2 + EXTRA_DEPTH;
    localparam ZERO  = {DEPTH{1'b0}};

    // Tell Vivado that these reg should be placed together (UG912),
    // and to show up as part of MTBF reports.
    (* ASYNC_REG = "TRUE" *)
    reg [DEPTH-1:0] sync_reg = ZERO;

// --------------------------------------------------------------------------
// Pass the sync bit through DEPTH registers in the receiving clock domain.

    integer i;

    always @(posedge clock_to) begin
        sync_reg[0] <= sync_bit_from;
        for(i = 1; i < DEPTH; i = i+1) begin: cdc_stages
            sync_reg[i] <= sync_reg[i-1]; 
        end
    end

    always @(*) begin
        sync_bit_to = sync_reg[DEPTH-1];
    end

endmodule

