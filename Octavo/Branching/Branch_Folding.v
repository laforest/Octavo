
// Matches multiple branch origins and conditions in parallel and returns the
// branch destination and jump signal for a (single) match. Multiple successful
// matches yield the bitwise OR of their destinations...likely garbage.

// ECL XXX Nothing prevents multiple origin matches, but it only makes sense if
// they have mutually exclusive conditions, creating a multiway branch out of a
// basic block.

module Branch_Folding
#(
    parameter   PC_WIDTH                            = 0,
    parameter   D_OPERAND_WIDTH                     = 0,
    parameter   WORD_WIDTH                          = 0,

    parameter   INITIAL_THREAD                      = 0,
    parameter   THREAD_COUNT                        = 0,
    parameter   THREAD_ADDR_WIDTH                   = 0,

    parameter   ORIGIN_WRITE_WORD_OFFSET            = 0,
    parameter   ORIGIN_WRITE_ADDR_OFFSET            = 0,
    parameter   ORIGIN_WORD_WIDTH                   = 0,
    parameter   ORIGIN_ADDR_WIDTH                   = 0,
    parameter   ORIGIN_DEPTH                        = 0,
    parameter   ORIGIN_RAMSTYLE                     = 0,
    parameter   ORIGIN_INIT_FILE                    = 0,

    parameter   BRANCH_COUNT                        = 0,

    parameter   DESTINATION_WRITE_WORD_OFFSET       = 0,
    parameter   DESTINATION_WRITE_ADDR_OFFSET       = 0,
    parameter   DESTINATION_WORD_WIDTH              = 0,
    parameter   DESTINATION_ADDR_WIDTH              = 0,
    parameter   DESTINATION_DEPTH                   = 0,
    parameter   DESTINATION_RAMSTYLE                = 0,
    parameter   DESTINATION_INIT_FILE               = 0,

    parameter   CONDITION_WRITE_WORD_OFFSET         = 0,
    parameter   CONDITION_WRITE_ADDR_OFFSET         = 0,
    parameter   CONDITION_WORD_WIDTH                = 0,
    parameter   CONDITION_ADDR_WIDTH                = 0,
    parameter   CONDITION_DEPTH                     = 0,
    parameter   CONDITION_RAMSTYLE                  = 0,
    parameter   CONDITION_INIT_FILE                 = 0,

    parameter   FLAGS_WORD_WIDTH                    = 0,
    parameter   FLAGS_ADDR_WIDTH                    = 0
)
(
    input   wire                                    clock,
    input   wire    [PC_WIDTH-1:0]                  PC,
    input   wire    [WORD_WIDTH-1:0]                R_prev,
    input   wire                                    IO_ready,

    input   wire    [D_OPERAND_WIDTH-1:0]           ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]                ALU_write_data,

    output  wire    [PC_WIDTH-1:0]                  branch_destination,
    output  wire                                    jump
);

// -----------------------------------------------------------

    wire    [FLAGS_WORD_WIDTH-1:0]  flags;

    Branching_Flags
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .COND_WIDTH (FLAGS_WORD_WIDTH)
    )
    BF
    (
        clock       (clock),
        R_prev      (R_prev),
        flags       (flags)
    );

// -----------------------------------------------------------

    wire    IO_ready_previous;

    delay_line
    #(
        .DEPTH  (8), // ECL XXX hardcoded...
        .WIDTH  (1)
    )
    IO_ready_pipeline
    (
        .clock  (clock),
        .in     (IO_ready),
        .out    (IO_ready_previous)
    );

// -----------------------------------------------------------

    wire    [(BRANCH_COUNT * PC_WIDTH)-1:0]     branch_destinations;
    wire    [ BRANCH_COUNT            -1:0]     jumps;

    genvar count;

    generate
        for(count = 0; count < BRANCH_COUNT; count = count + 1) begin
            Branch_Check_Mapped
            #(
                .PC_WIDTH                       (PC_WIDTH),
                .D_OPERAND_WIDTH                (D_OPERAND_WIDTH),
                .WORD_WIDTH                     (WORD_WIDTH),

                .INITIAL_THREAD                 (INITIAL_THREAD),
                .THREAD_COUNT                   (THREAD_COUNT),
                .THREAD_ADDR_WIDTH              (THREAD_ADDR_WIDTH),

                .ORIGIN_WRITE_WORD_OFFSET       (ORIGIN_WRITE_WORD_OFFSET),
                .ORIGIN_WRITE_ADDR_OFFSET       (ORIGIN_WRITE_ADDR_OFFSET +(ORIGIN_DEPTH * count)),
                .ORIGIN_WORD_WIDTH              (ORIGIN_WORD_WIDTH),
                .ORIGIN_ADDR_WIDTH              (ORIGIN_ADDR_WIDTH),
                .ORIGIN_DEPTH                   (ORIGIN_DEPTH),
                .ORIGIN_RAMSTYLE                (ORIGIN_RAMSTYLE),
                .ORIGIN_INIT_FILE               (ORIGIN_INIT_FILE),

                .DESTINATION_WRITE_WORD_OFFSET  (DESTINATION_WRITE_WORD_OFFSET),
                .DESTINATION_WRITE_ADDR_OFFSET  (DESTINATION_WRITE_ADDR_OFFSET + (DESTINATION_DEPTH * count)),
                .DESTINATION_WORD_WIDTH         (DESTINATION_WORD_WIDTH),
                .DESTINATION_ADDR_WIDTH         (DESTINATION_ADDR_WIDTH),
                .DESTINATION_DEPTH              (DESTINATION_DEPTH),
                .DESTINATION_RAMSTYLE           (DESTINATION_RAMSTYLE),
                .DESTINATION_INIT_FILE          (DESTINATION_INIT_FILE),

                .CONDITION_WRITE_WORD_OFFSET    (CONDITION_WRITE_WORD_OFFSET),
                .CONDITION_WRITE_ADDR_OFFSET    (CONDITION_WRITE_ADDR_OFFSET + (CONDITION_DEPTH * count)),
                .CONDITION_WORD_WIDTH           (CONDITION_WORD_WIDTH),
                .CONDITION_ADDR_WIDTH           (CONDITION_ADDR_WIDTH),
                .CONDITION_DEPTH                (CONDITION_DEPTH),
                .CONDITION_RAMSTYLE             (CONDITION_RAMSTYLE),
                .CONDITION_INIT_FILE            (CONDITION_INIT_FILE),

                .FLAGS_WORD_WIDTH               (FLAGS_WORD_WIDTH),
                .FLAGS_ADDR_WIDTH               (FLAGS_ADDR_WIDTH)
            )
            BCM
            (
                .clock                          (clock),
                .PC                             (PC),
                .flags                          (flags),
                .IO_ready_previous              (IO_ready_previous),

                .ALU_write_addr                 (ALU_write_addr),
                .ALU_write_data                 (ALU_write_data),

                .branch_destination             (branch_destinations),
                .jump                           (jumps)
            );
        end
    endgenerate

// -----------------------------------------------------------

    OR_Reducer
    #(
        .WORD_WIDTH     (PC_WIDTH),
        .WORD_COUNT     (BRANCH_COUNT),
        .REGISTERED     (`TRUE)
    )
    BD_reducer
    (
        .clock          (clock),
        .in             (branch_destinations),
        .out            (branch_destination)
    );

// -----------------------------------------------------------

    OR_Reducer
    #(
        .WORD_WIDTH     (1),
        .WORD_COUNT     (BRANCH_COUNT),
        .REGISTERED     (`TRUE)
    )
    jump_reducer
    (
        .clock          (clock),
        .in             (jumps),
        .out            (jump)
    );

endmodule

