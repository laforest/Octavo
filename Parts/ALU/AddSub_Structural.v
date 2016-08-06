
// Describes and Adder/Substractor using structural logic, rather than
// inference via an +/- operator.

// This should synthesize without using the carry-chain logic, and thus
// synthesize using plain LUT logic, which for short word widths can be an
// advantage.

// Same interface as AddSub_Ripple_Carry

module AddSub_Structural
#(
    parameter WORD_WIDTH                        = 0
)
(
    input   wire                                sub_add,    // 1/0 A-B/A+B
    input   wire                                carry_in,
    input   wire    signed  [WORD_WIDTH-1:0]    A,
    input   wire    signed  [WORD_WIDTH-1:0]    B,
    output  wire    signed  [WORD_WIDTH-1:0]    sum,
    output  wire                                carry_out
);

// --------------------------------------------------------------------

    localparam zero = {WORD_WIDTH{1'b0}};

// --------------------------------------------------------------------

    // ~B = -B-1

    wire [WORD_WIDTH-1:0] B_inverted;

    Inverter
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    B_invert
    (
        .invert (sub_add),
        .in     (B),
        .out    (B_inverted)
    );

// --------------------------------------------------------------------

    // ~B+1 = -B

    wire [WORD_WIDTH-1:0] B_negated;

    Full_Adder
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Negate_B
    (
        .carry_in   (sub_add),
        .A          (zero),
        .B          (B_inverted),
        .sum        (B_negated),
        .carry_out  ()
    );

// --------------------------------------------------------------------

    // A+/-B

    Full_Adder
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    AddSub
    (
        .carry_in   (carry_in),
        .A          (A),
        .B          (B_negated),
        .sum        (sum),
        .carry_out  (carry_out)
    );

endmodule

