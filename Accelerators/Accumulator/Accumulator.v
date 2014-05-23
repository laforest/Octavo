
// Multi-threaded Accumulator: per-thread writes accumulate, a read clears the accumulated value.
// simultaneous read/write gets current total and starts new accumulation

module Accumulator
#(
    parameter WORD_WIDTH   = 36,
    parameter THREAD_COUNT = 8
)
(
    input   wire                                    clock,
    input   wire                                    write_addend,
	input   wire    [WORD_WIDTH-1:0]                addend,
    input   wire                                    read_total,
	output  wire    [WORD_WIDTH-1:0]                total
);

// -----------------------------------------------------------

    wire     [WORD_WIDTH-1:0]    masked_addend;

    Instruction_Annuller
    #(
        .INSTR_WIDTH    (WORD_WIDTH)
    )
    Addend_Mask
    (
        .instr_in       (addend),
        .annul          (~write_addend),
        .instr_out      (masked_addend)
    );

// -----------------------------------------------------------

    wire     [WORD_WIDTH-1:0]    masked_total;

    Instruction_Annuller
    #(
        .INSTR_WIDTH    (WORD_WIDTH)
    )
    Total_Mask
    (
        .instr_in       (total),
        .annul          (read_total),
        .instr_out      (masked_total)
    );

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]    total_raw;

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Adder
    (
        .clock      (clock),
        .add_sub    (`HIGH),
        .cin        (`LOW),
        .dataa      (masked_addend),
        .datab      (masked_total),
        .cout       (),
        .result     (total_raw)
    );

// -----------------------------------------------------------

    localparam ADDSUB_DEPTH = 2;

    delay_line 
    #(
        .DEPTH  (THREAD_COUNT - ADDSUB_DEPTH),
        .WIDTH  (WORD_WIDTH)
    ) 
    thread_pipeline
    (
        .clock  (clock),
        .in     (total_raw),
        .out    (total)
    );

endmodule

