
// Contains the cancelling branch prediction bit:
// 1: Predict Taken, cancel delay slot instruction if branch not taken.
// 0: Predict Not Taken, cancel delay slot instruction if branch taken.
// See: Branch_Prediction_Enable.v

module Branch_Prediction
#(
    parameter   WORD_WIDTH              = 0,
    parameter   ADDR_WIDTH              = 0,
    parameter   DEPTH                   = 0,
    parameter   RAMSTYLE                = 0,
    parameter   INIT_FILE               = 0
)
(
    input   wire                        clock,
    input   wire                        wren,
    input   wire    [ADDR_WIDTH-1:0]    write_addr,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_addr,
    output  wire    [WORD_WIDTH-1:0]    branch_prediction
);
    wire    [WORD_WIDTH-1:0]    branch_prediction_raw;

    RAM_SDP_no_fw
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    BP_Memory
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (write_addr),
        .write_data         (write_data),
        .read_addr          (read_addr),
        .read_data          (branch_prediction_raw)
    );

// -----------------------------------------------------------

    // Outputs at stage 3

    delay_line
    #(
        .DEPTH  (3),
        .WIDTH  (WORD_WIDTH)
    )
    BP_pipeline
    (
        .clock  (clock),
        .in     (branch_prediction_raw),
        .out    (branch_prediction)
    );

endmodule

