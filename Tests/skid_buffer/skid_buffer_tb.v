
// Skid Buffer Test Bench

`default_nettype none

`timescale 1 ns / 1 ps

module TB
#(
    parameter WORD_WIDTH    = 64,
    parameter CLOCK_PERIOD  = 10
)
(
);

// --------------------------------------------------------------------------

    wire clock;

    simulation_clock
    #(
        .CLOCK_PERIOD    (CLOCK_PERIOD)
    )
    main_clock
    (
        .clock          (clock)
    );

// --------------------------------------------------------------------------

    localparam WORD_ZERO = {WORD_WIDTH{1'b0}};

    reg  [WORD_WIDTH-1:0]   s_data  = WORD_ZERO;
    wire [WORD_WIDTH-1:0]   m_data;

    reg                     s_valid = 1'b0;
    wire                    s_ready;

    wire                    m_valid;
    reg                     m_ready = 1'b0;

    skid_buffer
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    DUT
    (
        .clock          (clock),

        .s_valid        (s_valid),
        .s_ready        (s_ready),
        .s_data         (s_data),

        .m_valid        (m_valid),
        .m_ready        (m_ready),
        .m_data         (m_data)
    );

// --------------------------------------------------------------------------

    `define WAIT_CYCLES(n) repeat (n) begin @(posedge clock); end
    `define UNTIL_CYCLE(n) wait (cycle == n);

    time cycle = 0; 

    always @(posedge clock) begin
        cycle = cycle + 1;
    end

    always begin
        // Fill it up then drain it
        `WAIT_CYCLES(1)
        s_valid = 1'b1;
        s_data  = 64'hFEEDFACEDEADBEEF;
        `WAIT_CYCLES(1)
        s_data  = 64'hCAFEBABEABBABABE;
        `WAIT_CYCLES(1)
        s_valid = 1'b0;
        s_data  = 64'h0123456789ABCDEF;
        `WAIT_CYCLES(1)
        m_ready = 1'b1;
        `WAIT_CYCLES(5)
        // Now do a steady state transfer
        s_valid = 1'b1;

        s_data  = 64'hFEEDFACEDEADBEEF;
        `WAIT_CYCLES(1)
        s_data  = 64'hCAFEBABEABBABABE;
        `WAIT_CYCLES(1)
        s_data  = 64'h0123456789ABCDEF;
        `WAIT_CYCLES(1)

        s_data  = 64'hFEEDFACEDEADBEEF;
        `WAIT_CYCLES(1)
        s_data  = 64'hCAFEBABEABBABABE;
        `WAIT_CYCLES(1)
        s_data  = 64'h0123456789ABCDEF;
        `WAIT_CYCLES(1)

        // And check for master stall handling
        // Data will be lost here, since the
        // slave isn't stopping.
        m_ready = 1'b0;
        `WAIT_CYCLES(5)
        m_ready = 1'b1;

        s_data  = 64'hFEEDFACEDEADBEEF;
        `WAIT_CYCLES(1)
        s_data  = 64'hCAFEBABEABBABABE;
        `WAIT_CYCLES(1)
        s_data  = 64'h0123456789ABCDEF;
        `WAIT_CYCLES(1)

        s_data  = 64'hFEEDFACEDEADBEEF;
        `WAIT_CYCLES(1)
        s_data  = 64'hCAFEBABEABBABABE;
        `WAIT_CYCLES(1)
        s_data  = 64'h0123456789ABCDEF;
        `WAIT_CYCLES(1)
        s_valid = 1'b0;

        `WAIT_CYCLES(5)
        $stop();
    end

endmodule

