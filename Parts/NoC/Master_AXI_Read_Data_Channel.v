
// Master AXI Read Data Channel

// A read channel which connects an AXI data read to a system register read.

// The control interface enables the start of a read data transaction by
// pulsing control_start for one cycle, else there is a chance that a second
// transaction will be started if the current transaction finishes before the
// control_start is released. The control_busy signal then stays high until
// all AXI data has been received and read out (or dumped). The control
// interface will not respond to control_start until control_busy goes low.

// Once started, the read channel accepts one AXI data word (and possibly
// a second internally in the skid buffer), and raises system_valid.  Once
// read by the system, the read channel accepts another data word. The
// system_valid flag stays high as long as there are consecutive data words
// available to read. (i.e. the read channel can transfer a data word every
// cycle if possible)

// If a data read error occurs on the AXI interface (SLVERR/DECERR), then
// system_valid is no longer raised (after the last successful read out), the
// read channel raises system_error (which remains high until the control
// interface starts another transaction after this transaction completes) and
// receives and dumps all the remaining data in the transaction. 

// The system interface reads one data word by raising system_ready for one
// cycle. For each consecutive cycle that system_valid and system_ready are
// both high, a new data word is presented. (It's the usual valid/ready AXI
// handshake.)

// Reading system_data (i.e. raising system_ready) while system_valid is low
// will return an old or unknown value. This happens when the read data
// channel is empty and waiting for more AXI data (returns old value), or idle
// prior to the control interface starting a transaction (returns old value),
// or during an error condition (returns unknown value).

`default_nettype none

module Master_AXI_Read_Data_Channel
#(
    parameter WORD_WIDTH    = 0,

    // Do not alter at instantiation. Set by AXI4 spec.
    parameter RRESP_WIDTH   = 2
)
(
    input   wire                        clock,

    // System interface
    input   wire                        system_ready,
    output  wire    [WORD_WIDTH-1:0]    system_data,
    output  wire                        system_valid,
    output  wire                        system_error,

    // Control interface
    input   wire                        control_start,
    output  wire                        control_busy,

    // AXI interface
    input   wire    [WORD_WIDTH-1:0]    rdata,
    input   wire    [RRESP_WIDTH-1:0]   rresp,
    input   wire                        rlast,
    input   wire                        rvalid,
    output  wire                        rready
);

// --------------------------------------------------------------------------
// Possible AXI data read responses (See AXI4 spec)

    localparam [RRESP_WIDTH-1:0] OKAY   = 'd0;
    localparam [RRESP_WIDTH-1:0] EXOKAY = 'd1;
    localparam [RRESP_WIDTH-1:0] SLVERR = 'd2;
    localparam [RRESP_WIDTH-1:0] DECERR = 'd3;

// --------------------------------------------------------------------------
// Selectively disconnect the master and slave interfaces of the skid buffer.
// This is used to either enforce an idle state (accept nothing from AXI and
// system interfaces), or an error condition (accept from AXI, but disconnect
// system interface).

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
        .in         (rvalid),
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
        .out        (rready)
    );

// ---- Master interface to system

    wire system_ready_gated;

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
        .out        (system_ready_gated)
    );

// --------------------------------------------------------------------------
// Receive and buffer the AXI read data, read response, and the last transfer
// indicator together.

    reg m_ready_gated = 1'b0;

    wire [RRESP_WIDTH-1:0]  m_rresp;
    wire                    m_rlast;

    localparam BUFFER_WIDTH = WORD_WIDTH + RRESP_WIDTH + 1;

    skid_buffer
    #(
        .WORD_WIDTH (BUFFER_WIDTH)
    )
    read_channel
    (
        .clock      (clock),

        .s_valid    (s_valid),
        .s_ready    (s_ready),
        .s_data     ({rdata, rresp, rlast}),

        .m_valid    (m_valid),
        .m_ready    (m_ready_gated),
        .m_data     ({system_data, m_rresp, m_rlast})
    );


// --------------------------------------------------------------------------
// Latch the start of the transaction until all data received.

    reg transaction_start = 1'b0;

    always @(*) begin
        transaction_start <= (control_start == 1'b1) && (control_busy == 1'b0);
    end

    pulse_to_level
    transaction_busy
    (
        .clock      (clock),
        .clear      (m_rlast),
        .pulse_in   (transaction_start),
        .level_out  (control_busy)
    );

// --------------------------------------------------------------------------
// Latch a read error condition until this transaction ends and the next
// transaction starts.

    reg error = 1'b0;

    always @(*) begin
        error <= (m_rresp == SLVERR) || (m_rresp == DECERR);
    end

    pulse_to_level
    error_condition
    (
        .clock      (clock),
        .clear      (transaction_start),
        .pulse_in   (error),
        .level_out  (system_error)
    );

// --------------------------------------------------------------------------
// Disconnect AXI and system interfaces when idle. Disconnect system interface
// when there is an error, and short-circuit its valid/ready handshake until
// all the data has been read and dumped.

    always @(*) begin
        enable_axi      = (control_busy == 1'b1);
        enable_system   = (control_busy == 1'b1) && (system_error == 1'b0);
        m_ready_gated   = (system_error == 1'b1) ? 1'b1 : system_ready_gated;
    end

endmodule

