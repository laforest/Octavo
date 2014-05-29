
// Generates wiring connecting a set of I/Os in such a way as to support array
// reversal.  First I/O connects to last, second to penultimate, etc... in
// nested rings.  Special case: odd number of I/O pairs means middle set talks
// to itself.

// Use: write data from post-incr TOP and BOTTOM read pointers into a 2 stage
// queue, then read back in reverse order using post-incr TOP and BOTTOM
// post-incr write pointers:

// ADD IO, TOP, 0
// ADD IO, BOT, 0
// ADD BOT, IO, 0
// ADD TOP, IO, 0

// where IO -> stage1 -> stage2 -> IO
//              BOT       TOP

// Note the instruction order matters to allow for values to propagate through
// the queue.

module Array_Reverse_IO
#(
    parameter   WORD_WIDTH                              = 36,
    parameter   LANE_COUNT                              = 8,
    parameter   THREAD_COUNT                            = 8
)
(
    input   wire                                        clock,
    input   wire    [(WORD_WIDTH * LANE_COUNT)-1:0]     in,
    output  reg     [(WORD_WIDTH * LANE_COUNT)-1:0]     out
);

    localparam  QUEUE_DEPTH = THREAD_COUNT * 2;

    reg     [(WORD_WIDTH * LANE_COUNT)-1:0] queue [QUEUE_DEPTH-1:0];

    integer i, j;

    always @(posedge clock) begin
        for (i = 0; i < LANE_COUNT; i = i + 1) begin
            queue[0][(i * WORD_WIDTH) +: WORD_WIDTH] <= in[(i * WORD_WIDTH) +: WORD_WIDTH];
        end
        queue[1] <= queue[0];
    end

    always @(*) begin 
        for (j = LANE_COUNT-1; j >= 0; j = j - 1) begin
            out[(j * WORD_WIDTH) +: WORD_WIDTH] <= queue[1][(((LANE_COUNT-1) - j) * WORD_WIDTH) +: WORD_WIDTH];
        end
    end

endmodule

