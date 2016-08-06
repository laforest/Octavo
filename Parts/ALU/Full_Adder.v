
// A full-adder. Used as a building block for more complex extended Boolean
// functions, but without using the carry-chain logic of an FPGA, which will
// be more efficient for small word widths.

module Full_Adder
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire                        carry_in,
    input   wire    [WORD_WIDTH-1:0]    A,
    input   wire    [WORD_WIDTH-1:0]    B,
    output  wire    [WORD_WIDTH-1:0]    sum,
    output  reg                         carry_out
);

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] base_sum;
    wire [WORD_WIDTH-1:0] base_carries;

    Half_Adder
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Add_Numbers
    (
        .A          (A),
        .B          (B),
        .sum        (base_sum),
        .carry_out  (base_carries)
    );

// --------------------------------------------------------------------

    // This is where we transition from Boolean vectors to binary numbers, by
    // adding the carries from one digit to the next to create a positional
    // numbering system.

    reg [WORD_WIDTH-1:0] all_carries;
    reg [WORD_WIDTH-1:0] shifted_carries;

    always @(*) begin
        shifted_carries <= {all_carries[WORD_WIDTH-2:0],carry_in};
    end

// --------------------------------------------------------------------

    wire [WORD_WIDTH-1:0] sum_carries;

    Half_Adder
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Add_Carries
    (
        .A          (base_sum),
        .B          (shifted_carries),
        .sum        (sum),
        .carry_out  (sum_carries)
    );

// --------------------------------------------------------------------

    always @(*) begin
        all_carries = base_carries | sum_carries;
        carry_out   = all_carries[WORD_WIDTH-1];
    end

endmodule

