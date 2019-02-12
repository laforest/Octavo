
// Multi-threaded Accumulator: per-thread writes accumulate, a read clears the
// accumulated value. Simultaneous read/write gets current total and starts
// new accumulation.

`default_nettype none

module Accumulator
#(
    parameter WORD_WIDTH   = 0,
    parameter THREAD_COUNT = 0
)
(
    input   wire                        clock,
    input   wire                        write_addend,
	input   wire    [WORD_WIDTH-1:0]    addend,
    input   wire                        read_total,
	output  wire    [WORD_WIDTH-1:0]    total
);

// --------------------------------------------------------------------------
// The adder takes 2 cycles, and there are 3 delay lines total in-line before
// and after. Split the thread count amongst the delay lines.
// Assumes an evenly divisible number after adder cycles accounted (e.g. (8 - 2) / 3 = 2
// ECL FIXME needs a more flexible calculation

    localparam PIPELINE_DEPTH = (THREAD_COUNT - 2) / 3;

// --------------------------------------------------------------------------
// Delay the new value added to accumulated sum
// If we are not writing a new value to accumulate, add zero instead.

    wire     [WORD_WIDTH-1:0]    addend_delayed;

    Delay_Line 
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

// --

    wire     [WORD_WIDTH-1:0]    masked_addend;

    Annuller
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Addend_Mask
    (
        .annul      (write_addend_delayed == 1'b0),
        .in         (addend_delayed),
        .out        (masked_addend)
    );

// --

    wire                        write_addend_delayed;

    Delay_Line 
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

// --------------------------------------------------------------------------
// Delay the read request for the current total sum (sync with addend write)

    wire                        read_total_delayed;

    Delay_Line 
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

// --------------------------------------------------------------------------
// Sync the current total sum to the addend for later accumulation.
// If we are reading the total sum, zero it out to restart the accumulation.

    wire     [WORD_WIDTH-1:0]    total_delayed;

    Delay_Line 
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

// --

    wire     [WORD_WIDTH-1:0]    masked_total;

    Annuller
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Total_Mask
    (
        .annul      (read_total_delayed == 1'b1),
        .in         (total_delayed),
        .out        (masked_total)
    );

// --------------------------------------------------------------------------
// Delay the masked addend and masked total (again) before addition.

    wire     [WORD_WIDTH-1:0]    masked_addend_delayed;

    Delay_Line 
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

// --

    wire     [WORD_WIDTH-1:0]    masked_total_delayed;

    Delay_Line 
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

// --------------------------------------------------------------------------
// Add sum and addend together

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

// --------------------------------------------------------------------------
// Add final pipeline stages after adder and before feedback into inputs
// above.

    Delay_Line 
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

