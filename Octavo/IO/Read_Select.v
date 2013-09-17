
// Selects between data read from RAM and from I/O ports, 
// if I/O was detected earlier.

module Read_Select
#(
    parameter   A_WORD_WIDTH             = 0,
    parameter   B_WORD_WIDTH             = 0
)
(
    input   wire                        clock,

    input   wire                        A_read_is_IO,
    input   wire                        B_read_is_IO,

    input   wire    [A_WORD_WIDTH-1:0]  A_read_IO,
    input   wire    [B_WORD_WIDTH-1:0]  B_read_IO,

    input   wire    [A_WORD_WIDTH-1:0]  A_read_RAM,
    input   wire    [B_WORD_WIDTH-1:0]  B_read_RAM

    output  wire    [A_WORD_WIDTH-1:0]  A_read_data,
    output  wire    [B_WORD_WIDTH-1:0]  B_read_data,
);

    Addressed_Mux
    #(
        .WORD_WIDTH     (A_WORD_WIDTH),
        .ADDR_WIDTH     (1),
        .INPUT_COUNT    (2),
        .REGISTERED     (`TRUE)
    )
    A_read_Selector
    (
        .clock          (clock),
        .addr           (A_read_is_IO),
        .data_in        ({A_read_IO, A_read_RAM}),
        .data_out       (A_read_data)
    );

    Addressed_Mux
    #(
        .WORD_WIDTH     (B_WORD_WIDTH),
        .ADDR_WIDTH     (1),
        .INPUT_COUNT    (2),
        .REGISTERED     (`TRUE)
    )
    B_read_Selector
    (
        .clock          (clock),
        .addr           (B_read_is_IO),
        .data_in        ({B_read_IO, B_read_RAM}),
        .data_out       (B_read_data)
    );
endmodule


