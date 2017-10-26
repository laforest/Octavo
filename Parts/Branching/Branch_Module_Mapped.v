
// Memory-mapped wrapper for Branch Module: defines configuration addresses
// for the Branch Sentinels, Branch Detector, and Branch Counter.

`default_nettype none

module Branch_Module_Mapped
#(
    parameter       WORD_WIDTH                  = 0,
    parameter       ADDR_WIDTH                  = 0,
    parameter       PC_WIDTH                    = 0,
    parameter       FLAGS_WIDTH                 = 0,
    // Branch Detector RAM parameters
    parameter       BD_RAMSTYLE                 = "",
    // Branch Sentinel RAM parameters
    parameter       BS_RAMSTYLE                 = "",
    parameter       BS_READ_NEW_DATA            = 0,
    // Branch Counter RAM parameters
    parameter       BC_RAMSTYLE                 = "",
    parameter       BC_READ_NEW_DATA            = 0,
    // Multithreading
    parameter       THREAD_COUNT                = 0,
    parameter       THREAD_COUNT_WIDTH          = 0,
    // Physical memory base address
    parameter       CONFIG_ADDR_BASE            = 0,
    // Retiming
    parameter       WRITE_ADDR_RETIME_STAGES    = 0
)
(
    input   wire                                clock,
    input   wire    [PC_WIDTH-1:0]              PC,
    input   wire                                IOR,
    input   wire                                IOR_previous,
    input   wire                                A_negative,
    input   wire                                A_carryout,
    input   wire                                A_external,
    input   wire                                B_lessthan,
    input   wire                                B_external,
    input   wire    [WORD_WIDTH-1:0]            R_previous,
    input   wire                                config_wren,
    input   wire    [ADDR_WIDTH-1:0]            config_addr,
    input   wire    [WORD_WIDTH-1:0]            config_data,
    output  wire                                jump,
    output  wire    [PC_WIDTH-1:0]              destination,
    output  wire                                cancel
);

// --------------------------------------------------------------------

    // Lay out sub-modules in their memory range
    // Must agree with `BRANCH_CONFIG_ENTRIES in Global_Defines.vh

    localparam  BS1_CONFIG_BASE     = CONFIG_ADDR_BASE + 0; // 0: Sentinel 1: Mask
    localparam  BS1_CONFIG_BOUND    = CONFIG_ADDR_BASE + 1;
    localparam  BS2_CONFIG_BASE     = CONFIG_ADDR_BASE + 2;
    localparam  BS2_CONFIG_BOUND    = CONFIG_ADDR_BASE + 3;
    localparam  BC_CONFIG_BASE      = CONFIG_ADDR_BASE + 4;
    localparam  BC_CONFIG_BOUND     = CONFIG_ADDR_BASE + 4;
    localparam  BD_CONFIG_BASE      = CONFIG_ADDR_BASE + 5;
    localparam  BD_CONFIG_BOUND     = CONFIG_ADDR_BASE + 5;

// --------------------------------------------------------------------

    wire [ADDR_WIDTH-1:0] config_addr_retimed;

    Delay_Line 
    #(
        .DEPTH  (WRITE_ADDR_RETIME_STAGES), 
        .WIDTH  (ADDR_WIDTH)
    ) 
    DL_retime
    (
        .clock  (clock),
        .in     (config_addr),
        .out    (config_addr_retimed)
    );

// --------------------------------------------------------------------

    // We have a special case here where the config address is only used for
    // the Branch Sentinels (BS1 and BS2), which each have 2 config memory
    // locations. All other units have a single word of config memory. So we
    // only need to translate the least-significant bit of the config address.

    // Depending on the CONFIG_BASE_ADDR, this translator should resolve to
    // either a wire or an inverter, and thus likely vanish in optimization.

    wire config_addr_translated;

    Address_Range_Translator
    #(
        .ADDR_WIDTH         (1),
        .ADDR_BASE          (CONFIG_ADDR_BASE[0]),
        .ADDR_COUNT         (2),
        .REGISTERED         (1'b0)
    )
    ART
    (
        .clock              (1'b0),
        .raw_address        (config_addr_retimed[0]),
        .translated_address (config_addr_translated)
    );

// --------------------------------------------------------------------

    wire bs1_config_wren;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ADDR_BASE  (BS1_CONFIG_BASE),
        .ADDR_BOUND (BS1_CONFIG_BOUND)
    )
    ARDS_BS1
    (
        .enable     (config_wren),
        .addr       (config_addr_retimed),
        .hit        (bs1_config_wren)
    );

// --------------------------------------------------------------------

    wire bs2_config_wren;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ADDR_BASE  (BS2_CONFIG_BASE),
        .ADDR_BOUND (BS2_CONFIG_BOUND)
    )
    ARDS_BS2
    (
        .enable     (config_wren),
        .addr       (config_addr_retimed),
        .hit        (bs2_config_wren)
    );

// --------------------------------------------------------------------

    wire bc_config_wren;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ADDR_BASE  (BC_CONFIG_BASE),
        .ADDR_BOUND (BC_CONFIG_BOUND)
    )
    ARDS_BC
    (
        .enable     (config_wren),
        .addr       (config_addr_retimed),
        .hit        (bc_config_wren)
    );

// --------------------------------------------------------------------

    wire bd_config_wren;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ADDR_BASE  (BD_CONFIG_BASE),
        .ADDR_BOUND (BD_CONFIG_BOUND)
    )
    ARDS_BD
    (
        .enable     (config_wren),
        .addr       (config_addr_retimed),
        .hit        (bd_config_wren)
    );

// --------------------------------------------------------------------

    Branch_Module
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .PC_WIDTH           (PC_WIDTH),
        .BD_RAMSTYLE        (BD_RAMSTYLE),
        .BS_RAMSTYLE        (BS_RAMSTYLE),
        .BS_READ_NEW_DATA   (BS_READ_NEW_DATA),
        .BC_RAMSTYLE        (BC_RAMSTYLE),
        .BC_READ_NEW_DATA   (BC_READ_NEW_DATA),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    BM
    (
        .clock              (clock),
        .PC                 (PC),
        .IOR                (IOR),
        .IOR_previous       (IOR_previous),
        .A_negative         (A_negative),
        .A_carryout         (A_carryout),
        .A_external         (A_external),
        .B_lessthan         (B_lessthan),
        .B_external         (B_external),
        .R_previous         (R_previous),
        .bs1_config_wren    (bs1_config_wren),
        .bs2_config_wren    (bs2_config_wren),
        .bd_config_wren     (bd_config_wren),
        .bc_config_wren     (bc_config_wren),
        .config_addr        (config_addr_translated),
        .config_data        (config_data),
        .jump               (jump),
        .destination        (destination),
        .cancel             (cancel)
    );

endmodule

