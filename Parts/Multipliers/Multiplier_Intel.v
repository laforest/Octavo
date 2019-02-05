
// Encapsulate the Altera/Intel DSP Block into an optionally pipelined
// full-word multiplier, signed or unsigned.

// {R_high, R_low} = A * B;

module Multiplier_Intel
#(
    parameter WORD_WIDTH                = 0,
    // See DSP Block documentation for details.
    // Generally, only the input and output are necessary,
    // unless you are aiming for maximum speed.
    parameter USE_INPUT_REGISTER        = 0,
    parameter USE_MIDDLE_REGISTER       = 0,
    parameter USE_OUTPUT_REGISTER       = 0,
    // Only for behavioural simulation/modeling. Not documented.
    // See: <quartus install>/quartus/eda/fv_lib/verilog/altera_mf_macros.i
    // for the possible valid strings. The obvious guess will likely work:
    // "Stratix IV", "Arria 10", "Cyclone IV", etc....
    parameter DEVICE_FAMILY             = "Cyclone V"
)
(
    input   wire                        clock,
    input   wire                        is_signed,
    input   wire    [WORD_WIDTH-1:0]    A,
    input   wire    [WORD_WIDTH-1:0]    B,
    output  wire    [WORD_WIDTH-1:0]    R_low,
    output  wire    [WORD_WIDTH-1:0]    R_high
);

// --------------------------------------------------------------------------
// Translate our boolean flags into what the vendor code expects.

    localparam INPUT_REG  = (USE_INPUT_REGISTER  == 1) ? "CLOCK0" : "UNREGISTERED";
    localparam MIDDLE_REG = (USE_MIDDLE_REGISTER == 1) ? "CLOCK0" : "UNREGISTERED";
    localparam OUTPUT_REG = (USE_OUTPUT_REGISTER == 1) ? "CLOCK0" : "UNREGISTERED";

    localparam OUTPUT_WIDTH = WORD_WIDTH * 2;

    altmult_add 
    #(
        .intended_device_family         (DEVICE_FAMILY),
        .number_of_multipliers          (1),
        .width_a                        (WORD_WIDTH),
        .width_b                        (WORD_WIDTH),
        .width_result                   (OUTPUT_WIDTH),
        .input_register_a0              (INPUT_REG),
        .input_register_b0              (INPUT_REG),
        .port_signa                     ("PORT_USED"),
        .port_signb                     ("PORT_USED"),
        .signed_register_a              (INPUT_REG),
        .signed_register_b              (INPUT_REG),
        .signed_pipeline_register_a     (MIDDLE_REG),
        .signed_pipeline_register_b     (MIDDLE_REG),
        .multiplier_register0           (MIDDLE_REG),
        .output_register                (OUTPUT_REG),
        .dedicated_multiplier_circuitry ("YES")
    )
    altmult_add 
    (
        .clock0                         (clock),
        .datab                          (B),
        .signa                          (is_signed),
        .dataa                          (A),
        .signb                          (is_signed),
        .result                         ({R_high, R_low})
    );

endmodule

