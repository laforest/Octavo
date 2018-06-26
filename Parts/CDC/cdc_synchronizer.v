
// A basic Clock Domain Crossing synchronizer

// This can only ever be correct for 1 bit.
// DO NOT MAKE IT WORD-WIDE.

module cdc_synchronizer
(
    input   wire    data_from,
    input   wire    clock_to,
    output  reg     data_to
);

    // There should never be a need to change this.
    localparam DEPTH = 2;

    // Tell Vivado that these reg should be placed together (UG912),
    // and to show up as part of MTBF reports.
    (* ASYNC_REG = "TRUE" *)
    reg [DEPTH-1:0] sync_reg = 0;

    always @(posedge clock_to) begin
        sync_reg[0] <= data_from;
        sync_reg[1] <= sync_reg[0]; 
    end

    always @(*) begin
        data_to <= sync_reg[1];
    end

endmodule

