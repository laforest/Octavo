
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

    // ECL XXX Only works for 8 threads!!!
    localparam PIPELINE_DEPTH = 2;

// -----------------------------------------------------------

    wire     [WORD_WIDTH-1:0]    addend_delayed;

    delay_line 
    #(
        .DEPTH  (PIPELINE_DEPTH),
        .WIDTH  (WORD_WIDTH)
    ) 
    addend_pipeline
    (
        .clock  (clock),
        .in     (addend),
        .out    (addend_delayed)
    );

// -----------------------------------------------------------

    wire                        read_total_delayed;

    delay_line 
    #(
        .DEPTH  (PIPELINE_DEPTH),
        .WIDTH  (1)
    ) 
    read_total_pipeline
    (
        .clock  (clock),
        .in     (read_total),
        .out    (read_total_delayed)
    );

// -----------------------------------------------------------

    wire                        write_addend_delayed;

    delay_line 
    #(
        .DEPTH  (PIPELINE_DEPTH),
        .WIDTH  (1)
    ) 
    write_addend_pipeline
    (
        .clock  (clock),
        .in     (write_addend),
        .out    (write_addend_delayed)
    );

// -----------------------------------------------------------

    wire     [WORD_WIDTH-1:0]    masked_addend;

    Instruction_Annuller
    #(
        .INSTR_WIDTH    (WORD_WIDTH)
    )
    Addend_Mask
    (
        .instr_in       (addend_delayed),
        .annul          (~write_addend_delayed),
        .instr_out      (masked_addend)
    );

// -----------------------------------------------------------

    wire     [WORD_WIDTH-1:0]    total_delayed;

    delay_line 
    #(
        .DEPTH  (PIPELINE_DEPTH),
        .WIDTH  (WORD_WIDTH)
    ) 
    total_pipeline
    (
        .clock  (clock),
        .in     (total),
        .out    (total_delayed)
    );


// -----------------------------------------------------------

    wire     [WORD_WIDTH-1:0]    masked_total;

    Instruction_Annuller
    #(
        .INSTR_WIDTH    (WORD_WIDTH)
    )
    Total_Mask
    (
        .instr_in       (total_delayed),
        .annul          (read_total_delayed),
        .instr_out      (masked_total)
    );

// -----------------------------------------------------------

    wire     [WORD_WIDTH-1:0]    masked_addend_delayed;

    delay_line 
    #(
        .DEPTH  (PIPELINE_DEPTH),
        .WIDTH  (WORD_WIDTH)
    ) 
    masked_addend_pipeline
    (
        .clock  (clock),
        .in     (masked_addend),
        .out    (masked_addend_delayed)
    );

// -----------------------------------------------------------

    wire     [WORD_WIDTH-1:0]    masked_total_delayed;

    delay_line 
    #(
        .DEPTH  (PIPELINE_DEPTH),
        .WIDTH  (WORD_WIDTH)
    ) 
    masked_total_pipeline
    (
        .clock  (clock),
        .in     (masked_total),
        .out    (masked_total_delayed)
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
        .dataa      (masked_addend_delayed),
        .datab      (masked_total_delayed),
        .cout       (),
        .result     (total_raw)
    );

// -----------------------------------------------------------

    delay_line 
    #(
        .DEPTH  (PIPELINE_DEPTH),
        .WIDTH  (WORD_WIDTH)
    ) 
    thread_pipeline
    (
        .clock  (clock),
        .in     (total_raw),
        .out    (total)
    );

endmodule

