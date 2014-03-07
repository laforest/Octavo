
// Generate the instruction cancellation signal
// Used later to adjust IO_ready instruction annullment

module Branch_Cancel
// #(
// )
(
    input   wire        clock,
    input   wire        branch_prediction,
    input   wire        branch_prediction_enable,
    input   wire        branch_origin_hit,
    input   wire        flag,
    output  reg         cancel
);

    initial begin
        cancel = 0;
    end

    // Basically, if we *can* branch and predict, then cancel if the branch
    // prediction and the branch flag don't agree.

    // Inputs from stage 2, outputs at stage 3
    always @(posedge clock) begin
        cancel <= (branch_prediction ^ flag) & (branch_origin_hit & branch_prediction_enable);
    end

endmodule

