
// Triadic ALU: computes opcode applied to A, B, and either the result of the
// previous thread instruction (R), or a stored result from an even earlier
// thread instruction (S).

module Triadic_ALU
#(
    parameter       WORD_WIDTH                  = 0,
    parameter       ADDR_WIDTH                  = 0,
    // S register
    parameter       S_WRITE_ADDR                = 0,
    parameter       S_RAMSTYLE                  = "",
    parameter       S_READ_NEW_DATA             = 0,
    // Multithreading
    parameter       THREAD_COUNT                = 0,
    parameter       THREAD_COUNT_WIDTH          = 0
)
(
    input   wire                                clock,
    input   wire                                IO_Ready,
    input   wire                                Cancel,
    input   wire    [ADDR_WIDTH-1:0]            DB,         // Write address operand for Rb
    input   wire    [`TRIADIC_CTRL_WIDTH-1:0]   control,    // Bits defining various sub-operations
    input   wire    [WORD_WIDTH-1:0]            A,          // First source argument
    input   wire    [WORD_WIDTH-1:0]            B,          // Second source argument
    output  reg     [WORD_WIDTH-1:0]            Ra,         // First result
    output  reg     [WORD_WIDTH-1:0]            Rb,         // Second result
    output  wire                                carry_out,  // predicate from +/-A+/-B
    output  wire                                overflow    // predicate from +/-A+/-B
);

// --------------------------------------------------------------------

    // The forward path (4 cycles) computes the results Ra and Rb.

    wire [WORD_WIDTH-1:0]   R;
    wire                    R_zero;
    wire                    R_negative;
    wire [WORD_WIDTH-1:0]   S;

    Triadic_ALU_Forward_Path
    #(
        .WORD_WIDTH  (WORD_WIDTH)
    )
    TALU_FWD
    (
        .clock      (clock),
        .control    (control),      // Bits defining various sub-operations
        .A          (A),            // First source argument
        .B          (B),            // Second source argument
        .R          (R),            // Third source argument  (previous Ra result)
        .R_zero     (R_zero),       // Computed flag in feedback pipeline (Ra->R)
        .R_negative (R_negative),   // Computed flag in feedback pipeline (Ra->R)
        .S          (S),            // Fourth source argument (saved Rb result)
        .Ra         (Ra),           // First result
        .Rb         (Rb),           // Second result
        .carry_out  (carry_out),    // predicate from +/-A+/-B
        .overflow   (overflow)      // predicate from +/-A+/-B
    );

// --------------------------------------------------------------------

    // The feedback path (4 cycles) takes Ra and feeds it back as R or S, and
    // computes some flags. It starts at the end of the forward path and goes
    // backwards.

    Triadic_ALU_Feedback_Path
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .S_WRITE_ADDR       (S_WRITE_ADDR),
        .S_RAMSTYLE         (S_RAMSTYLE),
        .S_READ_NEW_DATA    (S_READ_NEW_DATA),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TALU_FBK
    (
        .clock          (clock),

        .Ra             (Ra),           // ALU First Result
        .Rb             (Rb),           // ALU Second Result
        .DB             (DB),           // Write Address for Rb
        .IO_Ready       (IO_Ready),
        .Cancel         (Cancel),

        .R              (R),            // Previous Result (Ra from prev instr.)
        .R_zero,        (R_zero)        // Is R zero? (all-1 if true)
        .R_negative     (R_negative),   // Is R negative? (all-1 if true)
        .S              (S)             // Stored Previous Result (from Rb)
    );

endmodule

