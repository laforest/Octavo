
// Wraps Branch_Check with memory mapping hardware.

module Branch_Check_Mapped
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

    parameter   PREDICTION_WRITE_WORD_OFFSET        = 0,
    parameter   PREDICTION_WRITE_ADDR_OFFSET        = 0,
    parameter   PREDICTION_WORD_WIDTH               = 0,
    parameter   PREDICTION_ADDR_WIDTH               = 0,
    parameter   PREDICTION_DEPTH                    = 0,
    parameter   PREDICTION_RAMSTYLE                 = 0,
    parameter   PREDICTION_INIT_FILE                = 0,

    parameter   PREDICTION_ENABLE_WRITE_WORD_OFFSET = 0,
    parameter   PREDICTION_ENABLE_WRITE_ADDR_OFFSET = 0,
    parameter   PREDICTION_ENABLE_WORD_WIDTH        = 0,
    parameter   PREDICTION_ENABLE_ADDR_WIDTH        = 0,
    parameter   PREDICTION_ENABLE_DEPTH             = 0,
    parameter   PREDICTION_ENABLE_RAMSTYLE          = 0,
    parameter   PREDICTION_ENABLE_INIT_FILE         = 0,

    parameter   FLAGS_WORD_WIDTH                    = 0,
    parameter   FLAGS_ADDR_WIDTH                    = 0
)
(
    input   wire                                    clock,
    input   wire    [PC_WIDTH-1:0]                  PC,
    input   wire    [FLAGS_WORD_WIDTH-1:0]          flags,
    input   wire                                    IO_ready_previous,

    input   wire    [D_OPERAND_WIDTH-1:0]           ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]                ALU_write_data,

    output  wire    [PC_WIDTH-1:0]                  branch_destination,
    output  wire                                    jump,
    output  wire                                    cancel
);

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]  ALU_write_data_reg;

    // Sync with regsitered address decoders and translators

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (WORD_WIDTH)
    )
    write_data_synchronizer
    (
        .clock  (clock),
        .in     (ALU_write_data),
        .out    (ALU_write_data_reg)
    );


// -----------------------------------------------------------

    // Subsets of above, so we can align multiple memories along a single word.
    // We want to keep all memory map knowledge in *this* module.
    reg     [ORIGIN_WORD_WIDTH-1:0]         ALU_write_data_BO;
    reg     [DESTINATION_WORD_WIDTH-1:0]    ALU_write_data_BD;
    reg     [CONDITION_WORD_WIDTH-1:0]      ALU_write_data_BC;
    reg     [PREDICTION_WORD_WIDTH-1:0]     ALU_write_data_BP;
    reg     [PREDICTION_ENABLE_WORD_WIDTH-1:0]     ALU_write_data_BPE;

    always @(*) begin
        ALU_write_data_BO  <= ALU_write_data_reg[ORIGIN_WORD_WIDTH + ORIGIN_WRITE_WORD_OFFSET-1:ORIGIN_WRITE_WORD_OFFSET];
        ALU_write_data_BD  <= ALU_write_data_reg[DESTINATION_WORD_WIDTH + DESTINATION_WRITE_WORD_OFFSET-1:DESTINATION_WRITE_WORD_OFFSET];
        ALU_write_data_BC  <= ALU_write_data_reg[CONDITION_WORD_WIDTH + CONDITION_WRITE_WORD_OFFSET-1:CONDITION_WRITE_WORD_OFFSET];
        ALU_write_data_BP  <= ALU_write_data_reg[PREDICTION_WORD_WIDTH + PREDICTION_WRITE_WORD_OFFSET-1:PREDICTION_WRITE_WORD_OFFSET];
        ALU_write_data_BPE <= ALU_write_data_reg[PREDICTION_ENABLE_WORD_WIDTH + PREDICTION_ENABLE_WRITE_WORD_OFFSET-1:PREDICTION_ENABLE_WRITE_WORD_OFFSET];
    end

// -----------------------------------------------------------

    wire    ALU_wren_BO; // Branch Origin

    Address_Decoder
    #(
        .ADDR_COUNT     (ORIGIN_DEPTH),
        .ADDR_BASE      (ORIGIN_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`TRUE)
    )
    BO
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_BO)
    );

// -----------------------------------------------------------

    wire    ALU_wren_BD; // Branch Destination

    Address_Decoder
    #(
        .ADDR_COUNT     (DESTINATION_DEPTH),
        .ADDR_BASE      (DESTINATION_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`TRUE)
    )
    BD
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_BD)
    );

// -----------------------------------------------------------

    wire    ALU_wren_BC; // Branch Condition

    Address_Decoder
    #(
        .ADDR_COUNT     (CONDITION_DEPTH),
        .ADDR_BASE      (CONDITION_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`TRUE)
    )
    BC
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_BC)
    );

// -----------------------------------------------------------

    wire    ALU_wren_BP; // Branch Prediction

    Address_Decoder
    #(
        .ADDR_COUNT     (PREDICTION_DEPTH),
        .ADDR_BASE      (PREDICTION_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`TRUE)
    )
    BP
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_BP)
    );

// -----------------------------------------------------------

    wire    ALU_wren_BPE; // Branch Prediction Enable

    Address_Decoder
    #(
        .ADDR_COUNT     (PREDICTION_ENABLE_DEPTH),
        .ADDR_BASE      (PREDICTION_ENABLE_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`TRUE)
    )
    BPE
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_BPE)
    );

// -----------------------------------------------------------

    // Translates the original address LSB to internal zero-based address
    // Cancels-out non-aligned memory mappings.
    wire    [ORIGIN_ADDR_WIDTH-1:0]     ALU_write_addr_BO;

    Address_Translator
    #(
        .ADDR_COUNT         (ORIGIN_DEPTH),
        .ADDR_BASE          (ORIGIN_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH         (ORIGIN_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    BO_addr
    (
        .clock              (clock),
        .raw_address        (ALU_write_addr[ORIGIN_ADDR_WIDTH-1:0]),
        .translated_address (ALU_write_addr_BO)
    );

// -----------------------------------------------------------

    wire    [DESTINATION_ADDR_WIDTH-1:0]     ALU_write_addr_BD;

    Address_Translator
    #(
        .ADDR_COUNT         (DESTINATION_DEPTH),
        .ADDR_BASE          (DESTINATION_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH         (DESTINATION_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    BD_addr
    (
        .clock              (clock),
        .raw_address        (ALU_write_addr[DESTINATION_ADDR_WIDTH-1:0]),
        .translated_address (ALU_write_addr_BD)
    );

// -----------------------------------------------------------

    wire    [CONDITION_ADDR_WIDTH-1:0]     ALU_write_addr_BC;

    Address_Translator
    #(
        .ADDR_COUNT         (CONDITION_DEPTH),
        .ADDR_BASE          (CONDITION_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH         (CONDITION_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    BC_addr
    (
        .clock              (clock),
        .raw_address        (ALU_write_addr[CONDITION_ADDR_WIDTH-1:0]),
        .translated_address (ALU_write_addr_BC)
    );

// -----------------------------------------------------------

    wire    [PREDICTION_ADDR_WIDTH-1:0]     ALU_write_addr_BP;

    Address_Translator
    #(
        .ADDR_COUNT         (PREDICTION_DEPTH),
        .ADDR_BASE          (PREDICTION_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH         (PREDICTION_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    BP_addr
    (
        .clock              (clock),
        .raw_address        (ALU_write_addr[PREDICTION_ADDR_WIDTH-1:0]),
        .translated_address (ALU_write_addr_BP)
    );

// -----------------------------------------------------------

    wire    [PREDICTION_ENABLE_ADDR_WIDTH-1:0]     ALU_write_addr_BPE;

    Address_Translator
    #(
        .ADDR_COUNT         (PREDICTION_ENABLE_DEPTH),
        .ADDR_BASE          (PREDICTION_ENABLE_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH         (PREDICTION_ENABLE_ADDR_WIDTH),
        .REGISTERED         (`TRUE)
    )
    BPE_addr
    (
        .clock              (clock),
        .raw_address        (ALU_write_addr[PREDICTION_ENABLE_ADDR_WIDTH-1:0]),
        .translated_address (ALU_write_addr_BPE)
    );

// -----------------------------------------------------------

    Branch_Check
    #(
        .PC_WIDTH                   (PC_WIDTH),
        .D_OPERAND_WIDTH            (D_OPERAND_WIDTH),
        .WORD_WIDTH                 (WORD_WIDTH),

        .INITIAL_THREAD             (INITIAL_THREAD),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH          (THREAD_ADDR_WIDTH),

        .ORIGIN_WORD_WIDTH          (ORIGIN_WORD_WIDTH),
        .ORIGIN_ADDR_WIDTH          (ORIGIN_ADDR_WIDTH),
        .ORIGIN_DEPTH               (ORIGIN_DEPTH),
        .ORIGIN_RAMSTYLE            (ORIGIN_RAMSTYLE),
        .ORIGIN_INIT_FILE           (ORIGIN_INIT_FILE),

        .DESTINATION_WORD_WIDTH     (DESTINATION_WORD_WIDTH),
        .DESTINATION_ADDR_WIDTH     (DESTINATION_ADDR_WIDTH),
        .DESTINATION_DEPTH          (DESTINATION_DEPTH),
        .DESTINATION_RAMSTYLE       (DESTINATION_RAMSTYLE),
        .DESTINATION_INIT_FILE      (DESTINATION_INIT_FILE),

        .CONDITION_WORD_WIDTH       (CONDITION_WORD_WIDTH),
        .CONDITION_ADDR_WIDTH       (CONDITION_ADDR_WIDTH),
        .CONDITION_DEPTH            (CONDITION_DEPTH),
        .CONDITION_RAMSTYLE         (CONDITION_RAMSTYLE),
        .CONDITION_INIT_FILE        (CONDITION_INIT_FILE),

        .PREDICTION_WORD_WIDTH      (PREDICTION_WORD_WIDTH),
        .PREDICTION_ADDR_WIDTH      (PREDICTION_ADDR_WIDTH),
        .PREDICTION_DEPTH           (PREDICTION_DEPTH),
        .PREDICTION_RAMSTYLE        (PREDICTION_RAMSTYLE),
        .PREDICTION_INIT_FILE       (PREDICTION_INIT_FILE),

        .PREDICTION_ENABLE_WORD_WIDTH   (PREDICTION_ENABLE_WORD_WIDTH),
        .PREDICTION_ENABLE_ADDR_WIDTH   (PREDICTION_ENABLE_ADDR_WIDTH),
        .PREDICTION_ENABLE_DEPTH        (PREDICTION_ENABLE_DEPTH),
        .PREDICTION_ENABLE_RAMSTYLE     (PREDICTION_ENABLE_RAMSTYLE),
        .PREDICTION_ENABLE_INIT_FILE    (PREDICTION_ENABLE_INIT_FILE),

        .FLAGS_WORD_WIDTH           (FLAGS_WORD_WIDTH),
        .FLAGS_ADDR_WIDTH           (FLAGS_ADDR_WIDTH)
    )
    Branch_Check
    (
        .clock                      (clock),
        .PC                         (PC),
        .flags                      (flags),
        .IO_ready_previous          (IO_ready_previous),

        .ALU_wren_BO                (ALU_wren_BO),
        .ALU_wren_BD                (ALU_wren_BD),
        .ALU_wren_BC                (ALU_wren_BC),
        .ALU_wren_BP                (ALU_wren_BP),
        .ALU_wren_BPE               (ALU_wren_BPE),

        .ALU_write_addr_BO          (ALU_write_addr_BO),
        .ALU_write_addr_BD          (ALU_write_addr_BD),
        .ALU_write_addr_BC          (ALU_write_addr_BC),
        .ALU_write_addr_BP          (ALU_write_addr_BP),
        .ALU_write_addr_BPE         (ALU_write_addr_BPE),

        .ALU_write_data_BO          (ALU_write_data_BO),
        .ALU_write_data_BD          (ALU_write_data_BD),
        .ALU_write_data_BC          (ALU_write_data_BC),
        .ALU_write_data_BP          (ALU_write_data_BP),
        .ALU_write_data_BPE         (ALU_write_data_BPE),

        .branch_destination         (branch_destination),
        .jump                       (jump),
        .cancel                     (cancel)
    );

endmodule

