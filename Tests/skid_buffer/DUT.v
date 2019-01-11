
`default_nettype none

module DUT
#(
    parameter WORD_WIDTH = 64
)
(
    input   wire                        clock,

    // Slave interface
    input   wire                        s_valid,
    output  wire                        s_ready,
    input   wire    [WORD_WIDTH-1:0]    s_data,

    // Master interface
    output  wire                        m_valid,
    input   wire                        m_ready,
    output  wire    [WORD_WIDTH-1:0]    m_data
);

    skid_buffer
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    skid_buffer
    (
        .clock          (clock),

        .s_valid        (s_valid),
        .s_ready        (s_ready),
        .s_data         (s_data),

        .m_valid        (m_valid),
        .m_ready        (m_ready),
        .m_data         (m_data)
    );

endmodule

