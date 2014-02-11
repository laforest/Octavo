
// Adds a per-thread offset to addresses to make shared code access per-thread
// private data. This includes the shared I/O and high-mem areas.

// Generic version needing external offset enable.  wren moved to higher level
// to abstract away operand width

module Addressing
#(
    parameter   BASIC_BLOCK_COUNTER_WORD_WIDTH          = 0,
    parameter   BASIC_BLOCK_COUNTER_ADDR_WIDTH          = 0,
    parameter   BASIC_BLOCK_COUNTER_DEPTH               = 0,
    parameter   BASIC_BLOCK_COUNTER_RAMSTYLE            = 0,
    parameter   BASIC_BLOCK_COUNTER_INIT_FILE           = 0,

    parameter   DEFAULT_OFFSET_WORD_WIDTH               = 0,
    parameter   DEFAULT_OFFSET_ADDR_WIDTH               = 0,
    parameter   DEFAULT_OFFSET_DEPTH                    = 0,
    parameter   DEFAULT_OFFSET_RAMSTYLE                 = 0,
    parameter   DEFAULT_OFFSET_INIT_FILE                = 0,

    parameter   INITIAL_THREAD                          = 0,
    parameter   THREAD_COUNT                            = 0,
    parameter   THREAD_ADDR_WIDTH                       = 0
)
(
    // ECL XXX We can get away with using DEFAULT_OFFSET_WORD_WIDTH as that is
    // the largest data value. This will break if the control logic gets wider
    // than that.
    input   wire                                        clock,
    input   wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]     addr_in,
    input   wire                                        basic_block_counter_wren,
    input   wire                                        default_offset_wren,
    input   wire    [DEFAULT_OFFSET_ADDR_WIDTH-1:0]     write_addr,
    input   wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]     write_data,
    output  wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]     addr_out
);
    wire    [THREAD_ADDR_WIDTH-1:0] read_thread_BBC;
    wire    [THREAD_ADDR_WIDTH-1:0] read_thread_MEM;
    wire    [THREAD_ADDR_WIDTH-1:0] write_thread;

    Addressing_Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .read_thread_MEM    (read_thread_MEM),
        .write_thread       (write_thread)
    );

// -----------------------------------------------------------

module Basic_Block_Counter
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
    input   wire    [ADDR_WIDTH-1:0]    write_thread,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_thread,
    output  wire    [WORD_WIDTH-1:0]    block_number,
    output  wire    [WORD_WIDTH-1:0]    block_number_post_incr
);

// -----------------------------------------------------------

module Control_Memory
#(
    parameter   WORD_WIDTH              = 0,
    parameter   ADDR_WIDTH              = 0,
    parameter   DEPTH                   = 0,
    parameter   RAMSTYLE                = 0,
    parameter   INIT_FILE               = 0,

    parameter   MATCH_WIDTH             = 0,
    parameter   COND_WIDTH              = 0,
    parameter   LINK_WIDTH              = 0,
)
(
    input   wire                        clock,
    input   wire                        wren,
    input   wire    [ADDR_WIDTH-1:0]    write_thread,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_thread,
    output  wire    [MATCH_WIDTH-1:0]   PC_match,
    output  reg     [COND_WIDTH-1:0]    branch_condition,
    output  wire    [LINK_WIDTH-1:0]    BBC_link
);

// -----------------------------------------------------------

module Basic_Block_End
#(
    parameter WORD_WIDTH                = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    PC_LSB,
    input   wire    [WORD_WIDTH-1:0]    match,
    output  wire                        block_end_stage_2,
    output  wire                        block_end_stage_3
);

// -----------------------------------------------------------

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

// -----------------------------------------------------------

module Default_Offset
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
    input   wire    [ADDR_WIDTH-1:0]    write_thread,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_thread,
    output  wire    [WORD_WIDTH-1:0]    offset,
);


// -----------------------------------------------------------

module Programmed_Offsets
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
    input   wire    [ADDR_WIDTH-1:0]    write_thread,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_thread,
    output  wire    [WORD_WIDTH-1:0]    offset_pre_incr,
    output  wire    [WORD_WIDTH-1:0]    offset_addr_adder
);

// -----------------------------------------------------------

module Increments
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
    input   wire    [ADDR_WIDTH-1:0]    write_thread,
    input   wire    [WORD_WIDTH-1:0]    write_data,
    input   wire    [ADDR_WIDTH-1:0]    read_thread,
    output  wire    [WORD_WIDTH-1:0]    increment
);

// -----------------------------------------------------------

module Increment_Adder
#(
    parameter   WORD_WIDTH              = 0
)
(
    input   wire                        clock,
    input   wire    [WORD_WIDTH-1:0]    offset_in,
    input   wire    [WORD_WIDTH-1:0]    increment,
    output  wire    [WORD_WIDTH-1:0]    offset_out
);

// -----------------------------------------------------------

    reg    [DEFAULT_OFFSET_WORD_WIDTH-1:0]    offset_final;

    // Addressed_Mux goes here later
    always @(*) begin
        offset_final <= default_offset_final;
    end

    module Addressed_Mux
    #(
        parameter       WORD_WIDTH                          = 0,
        parameter       ADDR_WIDTH                          = 0,
        parameter       INPUT_COUNT                         = 0,
        parameter       REGISTERED                          = `FALSE
    )
    (
        input   wire                                        clock,
        input   wire    [ADDR_WIDTH-1:0]                    addr,
        input   wire    [(WORD_WIDTH * INPUT_COUNT)-1:0]    data_in,
        output  reg     [WORD_WIDTH-1:0]                    data_out
    );

// -----------------------------------------------------------

    Address_Adder
    #(
        .WORD_WIDTH (DEFAULT_OFFSET_WORD_WIDTH)
    )
    Address_Adder
    (
        .clock      (clock),
        .addr_in    (addr_in),
        .offset     (offset_final),
        .addr_out   (addr_out)
    );

endmodule

