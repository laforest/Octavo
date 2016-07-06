
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

    localparam CTRL_WIDTH = 20; // Static. Don't change.

// --------------------------------------------------------------------

    wire [CTRL_WIDTH-1:0] control_dut;
    wire [WORD_WIDTH-1:0] A_dut;
    wire [WORD_WIDTH-1:0] B_dut;
    wire [WORD_WIDTH-1:0] R_dut;
    wire [WORD_WIDTH-1:0] S_dut;
    wire [WORD_WIDTH-1:0] Ra_dut;
    wire [WORD_WIDTH-1:0] Rb_dut;

    Triadic_ALU
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .CTRL_WIDTH (CTRL_WIDTH)
    )
    DUT
    (
        .clock      (clock),
        .control    (control_dut),
        .A          (A_dut),      
        .B          (B_dut),      
        .R          (R_dut),      
        .S          (S_dut),      
        .Ra         (Ra_dut),     
        .Rb         (Rb_dut)     
    );

// --------------------------------------------------------------------

    harness_input_register
    #(
        .WIDTH  (CTRL_WIDTH + (WORD_WIDTH * 3))
    )
    i
    (
        .clock  (clock),    
        .in     (in),
        .rden   (1'b1),
        .out    ({control_dut,A_dut,B_dut,S_dut})
    );

    // Loop Ra back to R, after 4 cycles.
    // So every 8th instruction can see it's previous result
    // Should also allow to retime zero/negative flag calculations

    Delay_Line 
    #(
        .DEPTH  (4), 
        .WIDTH  (WORD_WIDTH)
    ) 
    R_pipeline
    (
        .clock  (clock),
        .in     (Ra_dut),
        .out    (R_dut)
    );
 

    harness_output_register 
    #(
        .WIDTH  (WORD_WIDTH * 2)
    )
    o
    (
        .clock  (clock),
        .in     ({Ra_dut,Rb_dut}),
        .wren   (1'b1),
        .out    (out)
    );

endmodule

