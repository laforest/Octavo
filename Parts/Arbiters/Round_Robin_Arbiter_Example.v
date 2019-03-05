
module Round_Robin_Arbiter_Example
#(
    parameter WORD_WIDTH                = 17
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    requests,
    output  reg     [WORD_WIDTH-1:0]    grant
);

    Round_Robin_Arbiter
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Example
    (
        .clock      (clock),
        .requests   (requests),
        .grant      (grant)
    );

endmodule

