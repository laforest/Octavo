
// Octavo Control Path. For each thread:  calculates branches, the Program
// Counter, and fetches the corresponding instruction along with its decoded
// control bits.

`default_nettype none

module Controlpath
#(
    parameter       ADDR_WIDTH              = 0,
    parameter       WORD_WIDTH              = 0,
    // Flow Control
    parameter       PC_WIDTH                = 0,
    parameter       FLAGS_WIDTH             = 0,
    parameter       BRANCH_COUNT            = 0,
    parameter       FC_RAMSTYLE             = 0,
    parameter       FC_READ_NEW_DATA        = 0,
    // Controller: initial PC values
    parameter       PC_INIT_FILE            = "",
    parameter       PC_PREV_INIT_FILE       = "",
    // Instruction format
    parameter       OPCODE_WIDTH            = 0,
    parameter       D_OPERAND_WIDTH         = 0,
    parameter       A_OPERAND_WIDTH         = 0,
    parameter       B_OPERAND_WIDTH         = 0,
    // Instruction Memory (shared)
    parameter       IM_WORD_WIDTH           = 0,
    parameter       IM_ADDR_WIDTH           = 0,
    parameter       IM_READ_NEW             = 0,
    parameter       IM_DEPTH                = 0,
    parameter       IM_RAMSTYLE             = "",
    parameter       IM_INIT_FILE            = "",
    // Opcode Decoder Memory (multithreaded)
    parameter       OD_WORD_WIDTH           = 0,
    parameter       OD_ADDR_WIDTH           = 0,
    parameter       OD_READ_NEW             = 0,
    parameter       OD_THREAD_DEPTH         = 0,
    parameter       OD_RAMSTYLE             = "",
    parameter       OD_INIT_FILE            = "",
    parameter       OD_INITIAL_THREAD_READ  = 0,
    parameter       OD_INITIAL_THREAD_WRITE = 0,
    // Memory-mapping
    parameter       FC_BASE_ADDR_WRITE      = 0,
    parameter       DB_BASE_ADDR            = 0,
    parameter       IM_BASE_ADDR_WRITE      = 0,
    parameter       OD_BASE_ADDR_WRITE      = 0,
    // Multithreading
    parameter       THREAD_COUNT            = 0,
    parameter       THREAD_COUNT_WIDTH      = 0
)
(
    input   wire                            clock,

    // Common
    input   wire                            IOR_previous,
    input   wire                            cancel_previous,
    input   wire    [ADDR_WIDTH-1:0]        config_addr,
    input   wire    [WORD_WIDTH-1:0]        config_data,

    // Flow Control
    input   wire                            IOR,
    input   wire                            carryout,
    input   wire                            overflow,
    input   wire                            A_external,
    input   wire                            B_external,
    input   wire    [WORD_WIDTH-1:0]        R_previous,
    output  wire                            cancel,

    // Instruction Fetch/Decode
    output  wire    [OD_WORD_WIDTH-1:0]     ALU_control,
    output  wire    [D_OPERAND_WIDTH-1:0]   DA,
    output  wire    [D_OPERAND_WIDTH-1:0]   DB,
    output  wire    [A_OPERAND_WIDTH-1:0]   A,
    output  wire    [B_OPERAND_WIDTH-1:0]   B

);

// --------------------------------------------------------------------

    // Generate the other flags

    wire negative;

    R_Flags
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    RF_OTHER
    (
        .R          (R_previous),
        .R_zero     (),
        .R_negative (negative)
    );

    reg lessthan = 0;

    always @(*) begin
        lessthan <= overflow ^ negative;
    end

// --------------------------------------------------------------------

    wire [PC_WIDTH-1:0] PC;

    Flow_Control
    #(
        .BRANCH_COUNT       (BRANCH_COUNT),
        .CONFIG_ADDR_BASE   (FC_BASE_ADDR_WRITE),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .WORD_WIDTH         (WORD_WIDTH),
        .PC_WIDTH           (PC_WIDTH),
        .RAMSTYLE           (FC_RAMSTYLE),
        .READ_NEW_DATA      (FC_READ_NEW_DATA),
        .PC_INIT_FILE       (PC_INIT_FILE),
        .PC_PREV_INIT_FILE  (PC_PREV_INIT_FILE),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    FC
    (
        .clock              (clock),
        .IOR                (IOR),
        .IOR_previous       (IOR_previous),
        .cancel_previous    (cancel_previous),
        .A_negative         (negative),
        .A_carryout         (carryout),
        .A_external         (A_external),
        .B_lessthan         (lessthan),
        .B_external         (B_external),
        .R_previous         (R_previous),
        .config_addr        (config_addr),
        .config_data        (config_data),
        .cancel             (cancel),
        .PC                 (PC)
    );

// --------------------------------------------------------------------

    Instruction_Fetch_Decode_Mapped
    #(
        .WORD_WIDTH                 (WORD_WIDTH),
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .OPCODE_WIDTH               (OPCODE_WIDTH),
        .D_OPERAND_WIDTH            (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH            (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH            (B_OPERAND_WIDTH),
        .IM_WORD_WIDTH              (IM_WORD_WIDTH),
        .IM_ADDR_WIDTH              (IM_ADDR_WIDTH),
        .IM_READ_NEW                (IM_READ_NEW),
        .IM_DEPTH                   (IM_DEPTH),
        .IM_RAMSTYLE                (IM_RAMSTYLE),
        .IM_INIT_FILE               (IM_INIT_FILE),
        .OD_WORD_WIDTH              (OD_WORD_WIDTH),
        .OD_ADDR_WIDTH              (OD_ADDR_WIDTH),
        .OD_READ_NEW                (OD_READ_NEW),
        .OD_THREAD_DEPTH            (OD_THREAD_DEPTH),
        .OD_RAMSTYLE                (OD_RAMSTYLE),
        .OD_INIT_FILE               (OD_INIT_FILE),
        .OD_INITIAL_THREAD_READ     (OD_INITIAL_THREAD_READ),
        .OD_INITIAL_THREAD_WRITE    (OD_INITIAL_THREAD_WRITE),
        .DB_BASE_ADDR               (DB_BASE_ADDR),
        .IM_BASE_ADDR_WRITE         (IM_BASE_ADDR_WRITE),
        .OD_BASE_ADDR_WRITE         (OD_BASE_ADDR_WRITE),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH)
    )
    IFDM
    (
        .clock                      (clock),

        .IOR_previous               (IOR_previous),
        .cancel_previous            (cancel_previous),

        .im_write_addr              (config_addr),
        .im_write_data              (config_data),
        .im_read_addr               (PC),

        .od_write_addr              (config_addr),
        .od_write_data              (config_data),

        .ALU_control                (ALU_control),
        .DA                         (DA),
        .DB                         (DB),
        .A                          (A),
        .B                          (B)
    );

endmodule

