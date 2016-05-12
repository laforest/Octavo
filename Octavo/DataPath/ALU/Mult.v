module Mult_element 
#(
    parameter USE_DSP                           = 0,
    parameter WORD_WIDTH                        = 0,
    parameter PIPE_DEPTH                        = 0
)
(
    input   wire                                clock,
    input   wire                                sign,
    input   wire    [WORD_WIDTH-1:0]            dataa,
    input   wire    [WORD_WIDTH-1:0]            datab,
    output  wire    [(WORD_WIDTH * 2)-1:0]      result
);

    localparam HARD_SOFT            = USE_DSP           ? "YES"             : "NO";
    localparam LATENCY_ADJUSTMENT   = (PIPE_DEPTH > 3)  ? (PIPE_DEPTH - 3)  : 0;
    localparam USE_MULT_REG         = (PIPE_DEPTH > 2)  ? "CLOCK0"          : "UNREGISTERED";

    wire    [(WORD_WIDTH * 2)-1:0]      product;

    altmult_add 
    #(
        .intended_device_family         ("Stratix IV"),
        .number_of_multipliers          (1),
        .width_a                        (WORD_WIDTH),
        .width_b                        (WORD_WIDTH),
        .width_result                   ((WORD_WIDTH * 2)),
        .input_register_a0              ("CLOCK0"),
        .input_register_b0              ("CLOCK0"),
        .port_signa                     ("PORT_USED"),
        .port_signb                     ("PORT_USED"),
        .signed_register_a              ("CLOCK0"),
        .signed_register_b              ("CLOCK0"),
        // Use there for multiplier pipeline depth of 3 or more. Saves logic.
        .signed_pipeline_register_a     (USE_MULT_REG),
        .signed_pipeline_register_b     (USE_MULT_REG),
        .multiplier_register0           (USE_MULT_REG),
        // The output register *must* be used to (nearly) meet setup/hold specs
        .output_register                ("CLOCK0"),
        .dedicated_multiplier_circuitry (HARD_SOFT)
    )
    altmult_add 
    (
        .clock0                         (clock),
        .datab                          (datab),
        .signa                          (sign),
        .dataa                          (dataa),
        .signb                          (sign),
        .result                         (product)
    );

    // Exists since the 'extra_latency' altmult_add parameter is not supported in Q11.1.
    delay_line 
    #(
        .DEPTH  (LATENCY_ADJUSTMENT), 
        .WIDTH  ((WORD_WIDTH * 2))
    )
    latency_adjuster
    (
        .clock  (clock),
        .in     (product),
        .out    (result)
    );

endmodule


module Mult_Single_Pipe 
#(
    parameter USE_DSP                           = 0,
    parameter WORD_WIDTH                        = 0,
    parameter PIPE_DEPTH                        = 0
)
(
    input   wire                                clock,
    input   wire                                sign,
    input   wire    signed  [WORD_WIDTH-1:0]    A,
    input   wire    signed  [WORD_WIDTH-1:0]    B,
    output  wire    signed  [WORD_WIDTH-1:0]    R_lo,
    output  wire    signed  [WORD_WIDTH-1:0]    R_hi
);
    Mult_element 
    #(
        .USE_DSP    (USE_DSP),
        .WORD_WIDTH (WORD_WIDTH),
        .PIPE_DEPTH (PIPE_DEPTH)
    )
    Mult_single
    (
        .clock      (clock),
        .sign       (sign),
        .dataa      (A),
        .datab      (B),
        .result     ({R_hi, R_lo})
    );
endmodule



module Mult_Double_Pipe 
#(
    parameter HETEROGENEOUS                     = 0,
    parameter USE_DSP                           = 0,
    parameter WORD_WIDTH                        = 0,
    parameter PIPE_DEPTH                        = 0
)
(
    input   wire                                clock,
    input   wire                                half_clock,
    input   wire                                sign,
    input   wire    signed  [WORD_WIDTH-1:0]    A,
    input   wire    signed  [WORD_WIDTH-1:0]    B,
    output  reg     signed  [WORD_WIDTH-1:0]    R_lo,
    output  reg     signed  [WORD_WIDTH-1:0]    R_hi
);

    reg     state;

    initial begin
        state = 0;
    end

    always @(posedge clock) begin
        state <= ~state;
    end

    wire    [WORD_WIDTH-1:0]    low_even;
    wire    [WORD_WIDTH-1:0]    high_even;

    wire    [WORD_WIDTH-1:0]    low_odd;
    wire    [WORD_WIDTH-1:0]    high_odd;

    localparam USE_DSP_EVEN = USE_DSP;
    localparam USE_DSP_ODD  = HETEROGENEOUS ? !USE_DSP : USE_DSP;

    Mult_element 
    #(
        .USE_DSP    (USE_DSP_EVEN),
        .WORD_WIDTH (WORD_WIDTH),
        .PIPE_DEPTH (PIPE_DEPTH)
    )
    Mult_Even
    (
        .clock      (half_clock),
        .sign       (sign),
        .dataa      (A),
        .datab      (B),
        .result     ({high_even, low_even})
    );
    
    Mult_element
    #(
        .USE_DSP    (USE_DSP_ODD),
        .WORD_WIDTH (WORD_WIDTH),
        .PIPE_DEPTH (PIPE_DEPTH)
    )
    Mult_Odd
    (
        .clock      (~half_clock),
        .sign       (sign),
        .dataa      (A),
        .datab      (B),
        .result     ({high_odd, low_odd})
    );

    always @(*) begin
        R_lo <= (state == `HIGH) ? low_even  : low_odd;
        R_hi <= (state == `HIGH) ? high_even : high_odd;
    end
endmodule


module Mult 
#(
    parameter DOUBLE_PIPE                       = 0,
    parameter HETEROGENEOUS                     = 0,
    parameter USE_DSP                           = 0,
    parameter WORD_WIDTH                        = 0,
    parameter PIPE_DEPTH                        = 0
)
(
    input   wire                                clock,
    input   wire                                half_clock,
    input   wire                                sign,
    input   wire    signed  [WORD_WIDTH-1:0]    A,
    input   wire    signed  [WORD_WIDTH-1:0]    B,
    output  wire    signed  [WORD_WIDTH-1:0]    R_lo,
    output  wire    signed  [WORD_WIDTH-1:0]    R_hi
);

    generate
        if (DOUBLE_PIPE) begin
            Mult_Double_Pipe 
            #(
                .HETEROGENEOUS  (HETEROGENEOUS),
                .USE_DSP        (USE_DSP),
                .WORD_WIDTH     (WORD_WIDTH),
                .PIPE_DEPTH     (PIPE_DEPTH)
            )
            Mult_Double_Pipe
            (
                .clock          (clock),
                .half_clock     (half_clock),
                .sign           (sign),
                .A              (A),
                .B              (B),
                .R_lo           (R_lo),
                .R_hi           (R_hi)
            );
        end
        else begin
            Mult_Single_Pipe 
            #(
                .USE_DSP    (USE_DSP),
                .WORD_WIDTH (WORD_WIDTH),
                .PIPE_DEPTH (PIPE_DEPTH)
            )
            Mult_Single_Pipe
            (
                .clock      (clock),
                .sign       (sign),
                .A          (A),
                .B          (B),
                .R_lo       (R_lo),
                .R_hi       (R_hi)
            );
        end
    endgenerate
endmodule

