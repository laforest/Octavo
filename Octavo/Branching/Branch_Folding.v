
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

    parameter   FLAGS_WRITE_WORD_OFFSET             = 0,
    parameter   FLAGS_WRITE_ADDR_OFFSET             = 0,
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

    wire    jump_previous;

    delay_line
    #(
        .DEPTH  (7), // ECL XXX hardcoded...(-1 since jump registered out of stage 4)
        .WIDTH  (1)
    )
    jump_pipeline
    (
        .clock  (clock),
        .in     (jump),
        .out    (jump_previous)
    );




endmodule

