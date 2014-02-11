
// Takes the previous result from Thread 6 (arriving in stage 2, in synch
// with the current Thread 6), compares it to the Control Memory branch
// condition, and tells us if the jump at the end of a basic block is taken.

// ECL XXX I borrowed the flag code from the Controller. It'll need to be
// factored out into a common library.

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


module Basic_Block_Flags
#(
    parameter   WORD_WIDTH              = 0,
    parameter   COND_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    R_prev,
    input   wire    [COND_WIDTH-1:0]    branch_condition,
    input   wire                        basic_block_end,
    output  reg                         branch_taken
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

    wire    [COND_WIDTH-1:0]    branch_condition_reg;

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (COND_WIDTH)
    )
    op_pipeline
    (
        .clock  (clock),
        .in     (branch_condition),
        .out    (branch_condition_reg)
    );

// -----------------------------------------------------------

    localparam  COND_COUNT = 2 ** COND_WIDTH;

    wire    selected_flag;

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (COND_WIDTH),
        .INPUT_COUNT    (COND_COUNT),
        .REGISTERED     (`FALSE)
    )
    (
        .clock          (clock),
        .addr           (branch_condition_reg),
        // ECL XXX SENTINEL ('h5) and COUNTERZERO ('h6) not implemented
        // ECL XXX See flag ordering in params.v
        .data_in        ({R_even, `LOW, `LOW, !R_positive, R_positive, !R_zero, R_zero, `HIGH}),
        .data_out       (selected_flag)
    );

// -----------------------------------------------------------

    always @(posedge clock) begin
        branch_taken <= selected_flag & basic_block_end;
    end
endmodule

