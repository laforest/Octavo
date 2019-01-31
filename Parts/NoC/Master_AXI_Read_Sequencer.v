
// Master AXI Sequencer: Read

// The sequencer enables the read address and read data AXI transactions in
// turn, as the AXI and system interface complete their parts.
// The completion of each transaction is denoted by a high-to-low transition
// on its control_busy signal.

module Master_AXI_Sequencer_Read
// No parameters
(
    wire    input       clock,

    wire    output      ar_control_start,
    wire    input       ar_control_busy,

    wire    output      r_control_start,
    wire    input       r_control_busy
);

// --------------------------------------------------------------------------
// States for AXI reads

    localparam STATE_BITS = 1;

    localparam [STATE_BITS-1:0] ADDR = 'd0; // 
    localparam [STATE_BITS-1:0] DATA = 'd1;

