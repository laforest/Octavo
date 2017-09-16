
// Flow Control: Computes the next PC value based on multiple parallel programmed branches

`default_nettype none

module Flow_Control
#(
    // How many branches can run in parallel
    parameter       BRANCH_COUNT        = 0,
    // Where does their configuration start in memory?
    parameter       CONFIG_ADDR_BASE    = 0,
    // Branch Module
    parameter       ADDR_WIDTH          = 0,
    parameter       WORD_WIDTH          = 0,
    parameter       PC_WIDTH            = 0,
    parameter       FLAGS_WIDTH         = 0,
    // Let's assume all these small memories
    // have the same implementation
    parameter       RAMSTYLE            = 0,
    parameter       READ_NEW_DATA       = 0,
    // Controller: initial PC values
    parameter       PC_INIT_FILE        = "",
    parameter       PC_PREV_INIT_FILE   = "",
    // Multithreading
    parameter       THREAD_COUNT        = 0,
    parameter       THREAD_COUNT_WIDTH  = 0
)
(
    input   wire                        clock,
    input   wire                        IOR,
    input   wire                        IOR_previous,
    input   wire                        cancel_previous,
    input   wire                        A_negative,
    input   wire                        A_carryout,
    input   wire                        A_external,
    input   wire                        B_lessthan,
    input   wire                        B_external,
    input   wire    [WORD_WIDTH-1:0]    R_previous,
    input   wire    [ADDR_WIDTH-1:0]    config_addr,
    input   wire    [WORD_WIDTH-1:0]    config_data,
    output  wire                        cancel,
    output  wire    [PC_WIDTH-1:0]      PC
);

// --------------------------------------------------------------------

    // What is the range of physical addresses for configuration?
    // Zero-based addressing, so -1
    localparam CONFIG_ADDR_BOUND = CONFIG_ADDR_BASE + (BRANCH_COUNT * `BRANCH_CONFIG_ENTRIES) - 1;

// --------------------------------------------------------------------

    // Translate physical memory range into 0-based range.

    wire [ADDR_WIDTH-1:0] config_addr_translated;

    Address_Range_Translator
    #(
        ADDR_WIDTH          (ADDR_WIDTH),
        ADDR_BASE           (CONFIG_ADDR_BASE),
        ADDR_COUNT          (CONFIG_ADDR_BOUND),
        REGISTERED          (1'b0)
    )
    ART
    (
        .clock              (1'b0),
        .raw_address        (config_addr),
        .translated_address (config_addr_translated)
    );

// --------------------------------------------------------------------

    // Are we addressing the Flow Control module on a write?
    // And has the configuration writing instruction 
    // been Cancelled or Anulled? 

    reg config_write_ok = 0;

    always @(*) begin
        config_write_ok <= (IOR_previous == 1'b1) & (cancel_previous == 1'b0);
    end

    wire config_wren;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ADDR_BASE  (CONFIG_ADDR_BASE),
        .ADDR_BOUND (CONFIG_ADDR_BOUND)
    )
    ARDS
    (
        .enable     (config_write_ok),
        .addr       (config_addr),
        .hit        (config_wren)
    );

// --------------------------------------------------------------------

    // Generate one Branch Module instance for each possible parallel branch
    // Map them consecutively in write address space for configuration

    wire                jumps               [BRANCH_COUNT-1:0];
    wire                cancels             [BRANCH_COUNT-1:0];
    wire [PC_WIDTH-1:0] jump_destinations   [BRANCH_COUNT-1:0];

    generate
        genvar branch_number;
        genvar base_addr;
        for (branch_number = 0; branch_number < BRANCH_COUNT; branch_number=branch_number+1) begin: BMM_inst

            base_addr = CONFIG_ADDR_BASE + (branch_number * BRANCH_CONFIG_ENTRIES);

            Branch_Module_Mapped
            #(
                .WORD_WIDTH         (WORD_WIDTH),
                .ADDR_WIDTH         (ADDR_WIDTH),
                .PC_WIDTH           (PC_WIDTH),
                .FLAGS_WIDTH        (FLAGS_WIDTH),
                .BD_RAMSTYLE        (RAMSTYLE),
                .BS_RAMSTYLE        (RAMSTYLE),
                .BS_READ_NEW_DATA   (READ_NEW_DATA),
                .BC_RAMSTYLE        (RAMSTYLE),
                .BC_READ_NEW_DATA   (READ_NEW_DATA),
                .THREAD_COUNT       (THREAD_COUNT),
                .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH),
                .CONFIG_ADDR_BASE   (base_addr)
            )
            FC_BMM
            (
                .clock              (clock),
                .PC                 (PC_current),
                .IOR                (IOR),
                .IOR_previous       (IOR_previous),
                .A_negative         (A_negative),
                .A_carryout         (A_carryout),
                .A_external         (A_external),
                .B_lessthan         (B_lessthan),
                .B_external         (B_external),
                .R_previous         (R_previous),
                .config_wren        (config_wren),
                .config_addr        (config_addr_translated),
                .config_data        (config_data),
                .jump               (jumps              [branch_number]),
                .destination        (jump_destinations  [branch_number]),
                .cancel             (cancels            [branch_number])
            );
        end
    endgenerate

// --------------------------------------------------------------------

    // Arbitrate all parallel branches (highest priority gets through)
    // Least-Significant-Bit has highest priority.

    wire                jump;
    wire [PC_WIDTH-1:0] jump_destination;

    Branch_Arbiter
    #(
        .PC_WIDTH           (PC_WIDTH),
        .BRANCH_COUNT       (BRANCH_COUNT)
    )
    FC_BA
    (
        .clock              (clock),

        .cancels            (cancels),
        .jumps              (jumps),
        .jump_destinations  (jump_destinations),

        .cancel             (cancel),
        .jump               (jump),
        .jump_destination   (jump_destination)
    );

// --------------------------------------------------------------------

    // Issue the next PC (next in line, or branch destination)

    Controller
    #(
        .PC_WIDTH           (PC_WIDTH),   
        .RAMSTYLE           (RAMSTYLE),
        .READ_NEW_DATA      (READ_NEW_DATA),
        .PC_INIT_FILE       (PC_INIT_FILE),
        .PC_PREV_INIT_FILE  (PC_PREV_INIT_FILE),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    FC_C
    (
        .clock              (clock), 
        .IO_ready           (IO_ready),
        .cancel             (cancel),
        .jump               (jump),
        .jump_destination   (jump_destination),
        .pc                 (PC)
    );

// --------------------------------------------------------------------

    // Synchronize the PC with its fetched instruction
    // This is necessary to calculate the branch conditions
    // (i.e.: Have we arrived at the location (PC) of a branch?)

    wire [PC_WIDTH-1:0] PC_current;

    Delay_Line 
    #(
        .DEPTH  (`INSTR_FETCH_PIPE_DEPTH), 
        .WIDTH  (PC_WIDTH)
    ) 
    DL_PC
    (
        .clock  (clock),
        .in     (PC),
        .out    (PC_current)
    );

endmodule

