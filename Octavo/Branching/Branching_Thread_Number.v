
// Wrap Thread_Number along with delay registers to generate correct TID
// sequence, with proper initialization of each delay stage.

// ECL XXX We should make the delay code into a self-initializing module, maybe fold into delay_line?

module Branching_Thread_Number
#(
    parameter   INITIAL_THREAD                  = 0,
    parameter   THREAD_COUNT                    = 0,
    parameter   THREAD_ADDR_WIDTH               = 0
)
(
    input   wire                                clock,
    output  reg     [THREAD_ADDR_WIDTH-1:0]     read_thread,
    output  reg     [THREAD_ADDR_WIDTH-1:0]     write_thread
);
    wire    [THREAD_ADDR_WIDTH-1:0]     current_thread;
    wire    [THREAD_ADDR_WIDTH-1:0]     next_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        (next_thread)
    );

// -----------------------------------------------------------

   // If write is on T6, then read on T0
   // ECL XXX This will break for INITIAL_THREAD < 5
   reg     [THREAD_ADDR_WIDTH-1:0]     read_delay_1;
   reg     [THREAD_ADDR_WIDTH-1:0]     read_delay_2;
   reg     [THREAD_ADDR_WIDTH-1:0]     read_delay_3;
   reg     [THREAD_ADDR_WIDTH-1:0]     read_delay_4;
   reg     [THREAD_ADDR_WIDTH-1:0]     read_delay_5;

   integer one   = 1;
   integer two   = 2;
   integer three = 3;
   integer four  = 4;
   integer five  = 5;

   initial begin
       read_delay_1    = INITIAL_THREAD - one[THREAD_ADDR_WIDTH-1:0];
       read_delay_2    = INITIAL_THREAD - two[THREAD_ADDR_WIDTH-1:0];
       read_delay_3    = INITIAL_THREAD - three[THREAD_ADDR_WIDTH-1:0];
       read_delay_4    = INITIAL_THREAD - four[THREAD_ADDR_WIDTH-1:0];
       read_delay_5    = INITIAL_THREAD - five[THREAD_ADDR_WIDTH-1:0];
   end

   always @(posedge clock) begin
       read_delay_1    <=  current_thread;
       read_delay_2    <=  read_delay_1;
       read_delay_3    <=  read_delay_2;
       read_delay_4    <=  read_delay_3;
       read_delay_5    <=  read_delay_4;
   end

// -----------------------------------------------------------

    always @(*) begin
        read_thread     <=  read_delay_5;
        write_thread    <=  next_thread;
    end
endmodule

