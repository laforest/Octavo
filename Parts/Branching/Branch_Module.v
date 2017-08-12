
// Branch Module. Each instance supports one parallel branch.
// Grouped together and arbitrated these enable multi-way branches.

`default_nettype none

module Branch_Module
#(
    parameter       WORD_WIDTH          = 0,
    parameter       PC_WIDTH            = 0,
    parameter       FLAGS_WIDTH         = 0,
    // Branch Detector RAM parameters
    parameter       BD_RAMSTYLE         = "",
    // Branch Sentinel RAM parameters
    parameter       BS_RAMSTYLE         = "",
    parameter       BS_READ_NEW_DATA    = 0,
    // Branch Counter RAM parameters
    parameter       BC_RAMSTYLE         = "",
    parameter       BC_READ_NEW_DATA    = 0,
    // Multithreading
    parameter       THREAD_COUNT        = 0,
    parameter       THREAD_COUNT_WIDTH  = 0
)
(
    input   wire                        clock,
    input   wire    [PC_WIDTH-1:0]      PC,
    input   wire                        IOR,
    input   wire                        IOR_previous,
    input   wire    [FLAGS_WIDTH-1:0]   flags_previous,
    input   wire    [WORD_WIDTH-1:0]    R_previous,
    input   wire                        bs1_config_wren,
    input   wire                        bs2_config_wren,
    input   wire                        bd_config_wren,
    input   wire                        bc_config_wren,
    input   wire                        config_addr,
    input   wire    [WORD_WIDTH-1:0]    config_data,
    output  wire                        jump,
    output  wire    [PC_WIDTH-1:0]      destination,
    output  wire                        cancel
);

// --------------------------------------------------------------------

    wire                        bs1_wren;
    wire                        bs1_addr;
    wire    [WORD_WIDTH-1:0]    bs1_config;
    wire                        bs1_match;

    Branch_Sentinel
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .RAMSTYLE           (BS_RAMSTYLE),
        .READ_NEW_DATA      (BS_READ_NEW_DATA),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    bs1
    (
        .clock              (clock),
        .R                  (R_previous),
        .configuration_wren (bs1_config_wren),
        .configuration_addr (config_addr),
        .configuration_data (config_data),
        .match              (bs1_match)
    );

// --------------------------------------------------------------------

    wire                        bs2_wren;
    wire                        bs2_addr;
    wire    [WORD_WIDTH-1:0]    bs2_config;
    wire                        bs2_match;

    Branch_Sentinel
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .RAMSTYLE           (BS_RAMSTYLE),
        .READ_NEW_DATA      (BS_READ_NEW_DATA),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    bs2
    (
        .clock              (clock),
        .R                  (R_previous),
        .configuration_wren (bs2_config_wren),
        .configuration_addr (config_addr),
        .configuration_data (config_data),
        .match              (bs2_match)
    );

// --------------------------------------------------------------------

    // Unpack/repack the flags. See Branch_Detector.v for sub-format.

    reg [`GROUP_FLAG_COUNT-1:0] flags_previous_A    = 0;
    reg [`GROUP_FLAG_COUNT-1:0] flags_previous_B    = 0;
    reg                         A_negative          = 0;
    reg                         A_carryout          = 0;
    reg                         A_external          = 0;
    reg                         B_lessthan          = 0;
    reg                         B_external          = 0;
    wire                        running_previous;

    always @(*) begin
        {A_negative, A_carryout, B_lessthan, A_external, B_external} = flags_previous;
        flags_previous_A = {A_negative, A_carryout,       bs1_match, A_external};
        flags_previous_B = {B_lessthan, running_previous, bs2_match, B_external};
    end

// --------------------------------------------------------------------

    wire branch_reached;

    Branch_Detector
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .PC_WIDTH           (PC_WIDTH),
        .RAMSTYLE           (BD_RAMSTYLE),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    BM_BD
    (
        .clock              (clock),
        .pc                 (PC),
        .flags_previous_A   (flags_previous_A),
        .flags_previous_B   (flags_previous_B),
        .IO_Ready_previous  (IOR_previous),
        .branch_config_wren (bd_config_wren),
        .branch_config_data (config_data),
        .reached            (branch_reached),
        .destination        (destination),
        .jump               (jump),
        .cancel             (cancel)
    );

// --------------------------------------------------------------------

    wire running;

    Branch_Counter
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .RAMSTYLE           (BC_RAMSTYLE),
        .READ_NEW_DATA      (BC_READ_NEW_DATA),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    (
        .clock              (clock),
        .branch_reached     (branch_reached),
        .IO_Ready           (IOR),
        .IO_Ready_previous  (IOR_previous),
        .load               (bc_config_wren),
        .load_value         (config_data),
        .running            (running)
    );

// --------------------------------------------------------------------

    // Sync counter running flag to flags from previous instruction
    // Counter has 3 stages, so add 5 to make 8.

    Delay_Line 
    #(
        .DEPTH  (5), 
        .WIDTH  (1)
    ) 
    counter_sync
    (
        .clock  (clock),
        .in     (running),
        .out    (running_previous)
    );


endmodule

