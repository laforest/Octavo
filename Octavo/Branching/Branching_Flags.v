
// Takes the previous result from Thread 6 (arriving in stage 2, in synch with
// the current Thread 6), and computes all 8 branch condition flags.

// ECL XXX I borrowed the flag code from the Controller. It'll need to be
// factored out into a common library.

// -----------------------------------------------------------

module R_zero
#(
    parameter   WORD_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    R,
    output  reg                         R_zero
);
    always @(posedge clock) begin
        if (R === {WORD_WIDTH{`LOW}}) begin
            R_zero <= `HIGH;
        end
        else begin
            R_zero <= `LOW;
        end
    end

    initial begin
        R_zero = 0;
    end
endmodule

// -----------------------------------------------------------

module R_positive
#(
    parameter   WORD_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    R,
    output  reg                         R_positive
);
    always @(posedge clock) begin
        if (R[WORD_WIDTH-1] === `LOW) begin
            R_positive <= `HIGH;
        end
        else begin
            R_positive <= `LOW;
        end
    end

    initial begin
        R_positive = 0;
    end
endmodule

// -----------------------------------------------------------

// ECL XXX Branch on even as special support for calculating hailstone numbers
// An example of simple custom branch conditions.

module R_even
#(
    parameter   WORD_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    R,
    output  reg                         R_even
);
    always @(posedge clock) begin
        if (R[0] === `LOW) begin
            R_even <= `HIGH;
        end
        else begin
            R_even <= `LOW;
        end
    end

    initial begin
        R_even = 0;
    end
endmodule

// -----------------------------------------------------------

module Branching_Flags
#(
    parameter   WORD_WIDTH              = 0,
    parameter   COND_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    R_prev,
    output  wire    [COND_WIDTH-1:0]    flags
);
    wire    R_zero;

    R_zero
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    zero
    (
        .clock          (clock),
        .R              (R_prev),
        .R_zero         (R_zero)
    );

// -----------------------------------------------------------

    wire    R_positive;

    R_positive
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    positive
    (
        .clock          (clock),
        .R              (R_prev),
        .R_positive     (R_positive)
    );

// -----------------------------------------------------------

    wire    R_even;

    R_even
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    even
    (
        .clock          (clock),
        .R              (R_prev),
        .R_even         (R_even)
    );

// -----------------------------------------------------------

    // Even, undef, undef, negative, positive, non-zero, zero, always
    always @(*) begin
        flags <= {R_even, `LOW, `LOW, !R_positive, R_positive, !R_zero, R_zero, `HIGH},
    end

endmodule

