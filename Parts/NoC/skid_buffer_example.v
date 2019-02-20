
module skid_buffer_example
#(
    parameter WORD_WIDTH = 36
)
(
    input   wire                        clock,

    input   wire                        s_valid,
    output  wire                        s_ready,
    input   wire    [WORD_WIDTH-1:0]    s_data,

    output  wire                        m_valid,
    input   wire                        m_ready,
    output  wire    [WORD_WIDTH-1:0]    m_data
);

    skid_buffer
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    example
    (
        .clock      (clock),

        .s_valid    (s_valid),
        .s_ready    (s_ready),
        .s_data     (s_data),

        .m_valid    (m_valid),
        .m_ready    (m_ready),
        .m_data     (m_data)
    );

endmodule

