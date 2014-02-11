
// Basic Block Counter for extracted sub-graph execution

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
    RAM_SDP_no_fw
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DEPTH          (DEPTH),
        .RAMSTYLE       (RAMSTYLE),
        .INIT_FILE      (INIT_FILE)
    )
    Basic_Block_Counter
    (
        .clock          (clock),
        .wren           (wren),
        .write_addr     (write_thread),
        .write_data     (write_data),
        .read_addr      (read_thread),
        .read_data      (block_number)
    );

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]    block_number_pre_incr;

    // Stages 0 and 1
    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (WORD_WIDTH)
    )
    block_number_raw
    (
        .clock  (clock),
        .in     (block_number),
        .out    (block_number_pre_incr)
    );

// -----------------------------------------------------------

    reg     [WORD_WIDTH-1:0]    block_number_incr;

    // ECL XXX Why? Because WORD_WIDTH'd1 isn't allowed in Verilog-2001. Yeah.
    // ECL XXX This might break/complain if block_number exceeds 32 bits. Not likely. :)
    integer one = 1;

    always @(*) begin
        block_number_incr <= block_number_pre_incr + one[WORD_WIDTH-1:0];
    end

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]    block_number_post_incr;

    // Stages 2 and 3
    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (WORD_WIDTH)
    )
    block_number_cooked
    (
        .clock  (clock),
        .in     (block_number_incr),
        .out    (block_number_post_incr)
    );
endmodule

