
// Contains different increments added back to the Programmed_Offset values.

// ECL XXX Because, for simplicity, the Addressing module for D operands works
// with 12 bits instead of 10 once the A/B/D Programmed Offsets are placed in
// the same memory word, only 4 bits remain, so we can only have 1-bit
// increments for now. 

module Increments
#(
    parameter   WORD_WIDTH             = 0,
    parameter   ADDR_WIDTH             = 0,
    parameter   DEPTH                  = 0,
    parameter   RAMSTYLE               = 0,
    parameter   INIT_FILE              = 0
)
(
    input   wire                       clock,
    input   wire                       wren,
    input   wire    [ADDR_WIDTH-1:0]   write_addr,
    input   wire    [WORD_WIDTH-1:0]   write_data,
    input   wire    [ADDR_WIDTH-1:0]   read_addr,
    output  wire    [WORD_WIDTH-1:0]   increment
);
    wire    [WORD_WIDTH-1:0]    increment_raw;

    RAM_SDP_no_fw
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    Increments
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (write_addr),
        .write_data         (write_data),
        .rden               (`HIGH),
        .read_addr          (read_addr),
        .read_data          (increment_raw)
    );
// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    )
    increments_pipeline
    (
        .clock  (clock),
        .in     (increment_raw),
        .out    (increment)
    );
endmodule
