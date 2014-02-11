
// Contains extracted sub-graph skeleton: PC match, branch condition, link target.

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
    wire    [MATCH_WIDTH-1:0]   match;
    wire    [COND_WIDTH-1:0]    condition;
    wire    [LINK_WIDTH-1:0]    link;

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
        .read_data      ({match, condition, link})
    );

// -----------------------------------------------------------

    always @(*) begin
        PC_match <= match;
    end

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (LINK_WIDTH)
    )
    condition_pipeline
    (
        .clock  (clock),
        .in     (condition),
        .out    (branch_condition)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (3),
        .WIDTH  (LINK_WIDTH)
    )
    link_pipeline
    (
        .clock  (clock),
        .in     (link),
        .out    (BBC_link)
    );
endmodule

