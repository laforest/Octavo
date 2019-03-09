
// Multiplier accelerator pipeline for Octavo.

// A simple full-word multiplier with pipeline registers before and after it
// to make it 8 threads deep, and to give retiming and placement flexibility.

// Each thread must first set a bit to define if the multiplication will be
// signed or unsigned, which takes effect next time the thread comes around.
// This configuration bit is persistent until updated.  Default is unsigned.

// Operand inputs are latched and persistent for each thread.  This allows
// code to update the data one word at a time if necessary, or to set one
// "constant" and update only the other operand.  This can maybe save power by
// setting both A/B to zero if multiple threads are not using the multiplier.

`default_nettype none

module Multiplier_Pipeline
#(
    parameter WORD_WIDTH                    = 0,
    parameter CONFIG_ADDR                   = 0,
    parameter CONFIG_ADDR_WIDTH             = 0,
    parameter THREAD_COUNT                  = 0
)
(
    input   wire                            clock,

    input   wire    [CONFIG_ADDR_WIDTH-1:0] config_addr,
    input   wire                            config_signed, // 0 is unsigned
    input   wire                            config_enable,

    input   wire    [WORD_WIDTH-1:0]        A,
    input   wire                            A_wren,
    input   wire    [WORD_WIDTH-1:0]        B,
    input   wire                            B_wren,

    output  wire    [WORD_WIDTH-1:0]        R_low,
    output  wire    [WORD_WIDTH-1:0]        R_high
);

// --------------------------------------------------------------------------
// Some global constants

    `include "clog2_function.vh"

    localparam THREAD_COUNT_WIDTH   = clog2(THREAD_COUNT);
    localparam WORD_ZERO            = {WORD_WIDTH{1'b0}};
    localparam DELAY_DEPTH          = THREAD_COUNT / 2;     // Assumes even thread count

// --------------------------------------------------------------------------
// Decode the config write address.
// Translate the config write address to a zero-based index.
// For now, there is a single config entry: signedness of multiplication (LSB
// of config word)

    wire config_index;
    wire config_valid;

    Memory_Mapper
    #(
        .ADDR_WIDTH             (CONFIG_ADDR_WIDTH),
        .ADDR_BASE              (CONFIG_ADDR),
        .ADDR_BOUND             (CONFIG_ADDR),
        .ADDR_WIDTH_LSB         (1),
        .REGISTERED             (0)             // no clock needed

    )
    config_address
    (
        .clock                  (clock),        // Not used.
        .enable                 (config_enable),
        .addr                   (config_addr),
        .addr_translated_lsb    (config_index),
        .addr_valid             (config_valid)
    );

// --------------------------------------------------------------------------
// Store the config data, once per thread.

    wire is_signed;

    RAM_SDP_Multithreaded
    #(
        .WORD_WIDTH             (1),
        .ADDR_WIDTH             (1),
        .THREAD_DEPTH           (2),
        .RAMSTYLE               ("logic"),
        .READ_NEW_DATA          (0),
        .USE_INIT_FILE          (0),
        .INIT_FILE              (),
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH),
        .INITIAL_THREAD_READ    (0),
        .INITIAL_THREAD_WRITE   (0)
    )
    config_data
    (
        .clock                  (clock),
        .wren                   (config_valid),
        .write_addr             (config_index),
        .write_data             (config_signed),
        .rden                   (1'b1),
        .read_addr              (1'b0),
        .read_data              (is_signed)
    );

// --------------------------------------------------------------------------
// Pipeline the input operands.
// Here we have one stage first to latch operands conditionally.

    wire [WORD_WIDTH-1:0] A_latched;

    RAM_SDP_Multithreaded
    #(
        .WORD_WIDTH             (WORD_WIDTH),
        .ADDR_WIDTH             (1),
        .THREAD_DEPTH           (2),
        .RAMSTYLE               ("logic"),
        .READ_NEW_DATA          (0),
        .USE_INIT_FILE          (0),
        .INIT_FILE              (),
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH),
        .INITIAL_THREAD_READ    (0),
        .INITIAL_THREAD_WRITE   (0)
    )
    A_Latch
    (
        .clock                  (clock),
        .wren                   (A_wren),
        .write_addr             (1'b0),
        .write_data             (A),
        .rden                   (1'b1),
        .read_addr              (1'b0),
        .read_data              (A_latched)
    );

// --

    wire [WORD_WIDTH-1:0] B_latched;

    RAM_SDP_Multithreaded
    #(
        .WORD_WIDTH             (WORD_WIDTH),
        .ADDR_WIDTH             (1),
        .THREAD_DEPTH           (2),
        .RAMSTYLE               ("logic"),
        .READ_NEW_DATA          (0),
        .USE_INIT_FILE          (0),
        .INIT_FILE              (),
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH),
        .INITIAL_THREAD_READ    (0),
        .INITIAL_THREAD_WRITE   (0)
    )
    B_Latch
    (
        .clock                  (clock),
        .wren                   (B_wren),
        .write_addr             (1'b0),
        .write_data             (B),
        .rden                   (1'b1),
        .read_addr              (1'b0),
        .read_data              (B_latched)
    );

// --------------------------------------------------------------------------
// And now do the rest of the input pipeline, minus one stage

    localparam INPUT_DELAY_DEPTH = DELAY_DEPTH - 1;
    localparam INPUT_DELAY_WIDTH = WORD_WIDTH + WORD_WIDTH + 1;

    wire [WORD_WIDTH-1:0] A_input;
    wire [WORD_WIDTH-1:0] B_input;
    wire                  is_signed_input;

    Delay_Line
    #(
        .DEPTH  (INPUT_DELAY_DEPTH), 
        .WIDTH  (INPUT_DELAY_WIDTH)
    ) 
    input_operands_control
    (
        .clock  (clock),
        .in     ({A_latched, B_latched, is_signed}),
        .out    ({A_input,   B_input,   is_signed_input})
    );

// --------------------------------------------------------------------------
// The multiplier itself. Likely composed of multiple DSP Blocks and adders,
// depending on word width and target device. Fed a clock even though it's
// defined without registers, as the input/output pipeline stages will get
// retimed into the multiplier as necessary.

    wire [WORD_WIDTH-1:0] R_low_internal;
    wire [WORD_WIDTH-1:0] R_high_internal;

    // We can't Verilate the vendor implementations...
    `ifdef VERILATOR
        Multiplier_Generic
        #(
            .WORD_WIDTH             (WORD_WIDTH),
            .PIPELINE_DEPTH         (0)
        )
        Multiplier
        (
            .clock                  (clock),
            .is_signed              (is_signed_input),
            .A                      (A_input),
            .B                      (B_input),
            .R_low                  (R_low_internal),
            .R_high                 (R_high_internal)
        );
    `else
        Multiplier_Intel
        #(
            .WORD_WIDTH             (WORD_WIDTH),
            .USE_INPUT_REGISTER     (0),
            .USE_MIDDLE_REGISTER    (0),
            .USE_OUTPUT_REGISTER    (0),
            .DEVICE_FAMILY          ("Cyclone V")
        )
        Multiplier
        (
            .clock                  (clock),
            .is_signed              (is_signed_input),
            .A                      (A_input),
            .B                      (B_input),
            .R_low                  (R_low_internal),
            .R_high                 (R_high_internal)
        );
    `endif

// --------------------------------------------------------------------------
// Then add the last four pipeline stages.

    localparam OUTPUT_DELAY_DEPTH = DELAY_DEPTH;
    localparam OUTPUT_DELAY_WIDTH = WORD_WIDTH + WORD_WIDTH;

    Delay_Line 
    #(
        .DEPTH  (OUTPUT_DELAY_DEPTH), 
        .WIDTH  (OUTPUT_DELAY_WIDTH)
    ) 
    output_results
    (
        .clock  (clock),
        .in     ({R_high_internal, R_low_internal}),
        .out    ({R_high,          R_low})
    );

endmodule

