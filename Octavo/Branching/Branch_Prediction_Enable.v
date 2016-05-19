
// Contains the cancelling branch prediction *enable* bit:
// 1: Enable Cancelling Branches, following Branch Prediction bit
// 0: Disable Cancelling Branches: the delay slot instruction always executes.
// See: Branch_Prediction.v

module Branch_Prediction_Enable
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
    output  wire    [WORD_WIDTH-1:0]    branch_prediction_enable
);
    wire    [WORD_WIDTH-1:0]    branch_prediction_enable_raw;

    RAM_SDP_no_fw
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    BPE_Memory
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (write_addr),
        .write_data         (write_data),
        .rden               (`HIGH),
        .read_addr          (read_addr),
        .read_data          (branch_prediction_enable_raw)
    );

// -----------------------------------------------------------

    // Outputs at stage 2

    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (WORD_WIDTH)
    )
    BPE_pipeline
    (
        .clock  (clock),
        .in     (branch_prediction_enable_raw),
        .out    (branch_prediction_enable)
    );

endmodule

