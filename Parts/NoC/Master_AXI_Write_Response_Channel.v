
// Master AXI Write Response Channel

// A read channel with connects an AXI write response channel to a system
// register read.

// The control interface enables the read channel by pulsing control_start
// high for one cycle. The skid buffer then accepts one or two write response
// transactions from the AXI interface. The channel then raises system_valid
// to indicate a response can be read out.

// The system interface reads out a write response by raising system_ready for
// one cycle. The response is only valid if read while system_valid is high,
// else it is old or undefined data. Once a single response is read out, the
// transaction is done and the control interface must enable the read channel
// again.

// The system and control interfaces will not respond while a transaction
// is in progress (control_busy is high).

`default_nettype none

module Master_AXI_Write_Response_Channel
#(
    // Do not alter at instantiation. Set by AXI4 spec.
    parameter BRESP_WIDTH = 2
)
(
    input   wire                        clock,

    // System interface
    input   wire                        system_ready,
    output  wire    [BRESP_WIDTH-1:0]   system_response,
    output  wire                        system_valid,

    // Control interface
    input   wire                        control_start,
    output  wire                        control_busy,

    // AXI interface
    input   wire    [BRESP_WIDTH-1:0]   bresp,
    input   wire                        bvalid,
    output  wire                        bready
);

// --------------------------------------------------------------------------
// Selectively disconnect the master and slave interfaces of the skid buffer.
// This is used to enforce an idle state (accept nothing from AXI and
// system interfaces).

    reg  enable_system  = 1'b0;
    reg  enable_axi     = 1'b0;

// ---- Slave interface to AXI

    wire s_valid;
    wire s_ready;

    Annuller
    #(
        .WORD_WIDTH (1)
    )
    slave_valid
    (
        .annul      (enable_axi == 1'b0),
        .in         (bvalid),
        .out        (s_valid)
    );

    Annuller
    #(
        .WORD_WIDTH (1)
    )
    slave_ready
    (
        .annul      (enable_axi == 1'b0),
        .in         (s_ready),
        .out        (bready)
    );

// ---- Master interface to system

    wire m_ready;

    Annuller
    #(
        .WORD_WIDTH (1)
    )
    master_valid
    (
        .annul      (enable_system == 1'b0),
        .in         (m_valid),
        .out        (system_valid)
    );

    Annuller
    #(
        .WORD_WIDTH (1)
    )
    master_ready
    (
        .annul      (enable_system == 1'b0),
        .in         (system_ready),
        .out        (m_ready)
    );

// --------------------------------------------------------------------------
// Receive and buffer the AXI write response

    skid_buffer
    #(
        .WORD_WIDTH (BRESP_WIDTH)
    )
    read_channel
    (
        .clock      (clock),

        .s_valid    (s_valid),
        .s_ready    (s_ready),
        .s_data     (bresp),

        .m_valid    (m_valid),
        .m_ready    (m_ready),
        .m_data     (system_response)
    );


// --------------------------------------------------------------------------
// Latch the start of the transaction until one system read is done.

    reg transaction_start = 1'b0;
    reg transaction_done  = 1'b0;

    always @(*) begin
        transaction_start <= (control_start == 1'b1) && (control_busy == 1'b0);
        transaction_done  <= (m_valid       == 1'b1) && (m_ready      == 1'b1);
    end

    pulse_to_level
    transaction_busy
    (
        .clock      (clock),
        .clear      (transaction_done),
        .pulse_in   (transaction_start),
        .level_out  (control_busy)
    );

// --------------------------------------------------------------------------
// Disconnect AXI and system interfaces when idle. 

    always @(*) begin
        enable_axi    = (control_busy == 1'b1);
        enable_system = (control_busy == 1'b1);
    end

endmodule

