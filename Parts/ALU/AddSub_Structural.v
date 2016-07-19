
// Describes and Adder/Substractor using structural logic, rather than
// inference via an +/- operator.

// This should synthesize without using the carry-chain logic, and thus
// synthesize using plain LUT logic, which for short word widths can be an
// advantage.

module AddSub_Structural
#(
    parameter WORD_WIDTH        = 0
)
(
    input   wire                        sub_add,    // 1/0 A-B/A+B
    input   wire    [WORD_WIDTH-1:0]    A,
    input   wire    [WORD_WIDTH-1:0]    B,
    output  reg     [WORD_WIDTH-1:0]    sum,
    output  reg                         carry_out
);

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] B_signed;

    Inverter
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    B_negater
    (
        .invert (sub_add),
        .in     (B),
        .out    (B_signed)
    );

// --------------------------------------------------------------------

    Full_Adder
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    AddSub
    (
        .carry_in   (sub_add),
        .A          (A),
        .B          (B_signed),
        .sum        (sum),
        .carry_out  (carry_out)
    );

endmodule

