// Selects between raw address and adding an offset

module Offset_Selector
#(
    parameter   WORD_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    addr_in,
    input   wire    [WORD_WIDTH-1:0]    offset,
    input   wire                        use_raw_addr,
    output  wire    [WORD_WIDTH-1:0]    addr_out
);
    reg     [WORD_WIDTH-1:0]    raw_addr;
    reg     [WORD_WIDTH-1:0]    offset_addr;
    reg                         selector;

    always @(posedge clock) begin
        raw_addr    <= addr_in;
        offset_addr <= addr_in + offset;
        selector    <= use_raw_addr;
    end

    Addressed_Mux
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (1),
        .INPUT_COUNT        (2),
        .REGISTERED         (`TRUE)
    )
    raw_or_offset
    (
        .clock              (clock),
        .addr               (selector),
        .data_in            ({raw_addr, offset_addr}), 
        .data_out           (addr_out)
    );
endmodule

