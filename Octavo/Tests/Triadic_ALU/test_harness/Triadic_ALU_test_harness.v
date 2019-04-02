
module Triadic_ALU_test_harness
#(
    parameter   WORD_WIDTH = 36
)
(
    input   wire    clock,
    input   wire    in,
    output  wire    out
//    input   wire     control, // Bits defining various sub-operations
//    input   wire     A,       // First source argument
//    input   wire     B,       // Second source argument
//    input   wire     R,       // Third source argument  (previous result)
//    input   wire     S,       // Fourth source argument (persistent value)
//    output  reg      Ra,      // First result
//    output  reg      Rb       // Second result
);

// --------------------------------------------------------------------

    wire [`TRIADIC_CTRL_WIDTH-1:0]  control_dut;
    wire [WORD_WIDTH-1:0]           A_dut;
    wire [WORD_WIDTH-1:0]           B_dut;
    wire [WORD_WIDTH-1:0]           R_dut;
    wire                            R_zero_dut;
    wire                            R_negative_dut;
    wire [WORD_WIDTH-1:0]           S_dut;
    wire [WORD_WIDTH-1:0]           Ra_dut;
    wire [WORD_WIDTH-1:0]           Rb_dut;
    wire                            carry_out_dut;
    wire                            overflow_dut;

    Triadic_ALU
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    DUT
    (
        .clock      (clock),
        .control    (control_dut),
        .A          (A_dut),      
        .B          (B_dut),      
        .R          (R_dut),      
        .R_zero     (R_zero_dut),
        .R_negative (R_negative_dut),
        .S          (S_dut),      
        .Ra         (Ra_dut),     
        .Rb         (Rb_dut),
        .carry_out  (carry_out_dut),
        .overflow   (overflow_dut)     
    );

// --------------------------------------------------------------------

    // Tie-off and register inputs and outputs to get a valid timing analysis.

    harness_input_register
    #(
        .WIDTH  (`TRIADIC_CTRL_WIDTH + (WORD_WIDTH * 3))
    )
    i
    (
        .clock  (clock),    
        .in     (in),
        .rden   (1'b1),
        .out    ({control_dut, A_dut, B_dut, S_dut})
    );


    harness_output_register 
    #(
        .WIDTH  ((WORD_WIDTH * 2) + 2)
    )
    o
    (
        .clock  (clock),
        .in     ({Ra_dut, Rb_dut, carry_out_dut, overflow_dut}),
        .wren   (1'b1),
        .out    (out)
    );

// --------------------------------------------------------------------

    // Loop Ra back to R, after 4 cycles.
    // So every 8th instruction can see it's previous result
    // Split to allow putting logic in the middle.

    wire [WORD_WIDTH-1:0] R_pipe_1;

    Delay_Line 
    #(
        .DEPTH  (2), 
        .WIDTH  (WORD_WIDTH)
    ) 
    R_pipeline_1
    (
        .clock  (clock),
        .in     (Ra_dut),
        .out    (R_pipe_1)
    );
 
    Delay_Line 
    #(
        .DEPTH  (2), 
        .WIDTH  (WORD_WIDTH)
    ) 
    R_pipeline_2
    (
        .clock  (clock),
        .in     (R_pipe_1),
        .out    (R_dut)
    );
 

// --------------------------------------------------------------------

    // Place in R pipeline middle to retime zero/negative flag calculations

    wire R_zero_raw;
    wire R_negative_raw;

    R_Flags
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    R_Flags
    (
        .R          (R_pipe_1),
        .R_zero     (R_zero_raw),
        .R_negative (R_negative_raw)
    );

    Delay_Line 
    #(
        .DEPTH  (2), 
        .WIDTH  (1)
    ) 
    R_zero_pipeline
    (
        .clock  (clock),
        .in     (R_zero_raw),
        .out    (R_zero_dut)
    );
 
    Delay_Line 
    #(
        .DEPTH  (2), 
        .WIDTH  (1)
    ) 
    R_negative_pipeline
    (
        .clock  (clock),
        .in     (R_negative_raw),
        .out    (R_negative_dut)
    );

endmodule

