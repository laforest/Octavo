
// Wraps Addressing with data and address memory map info

module Addressing_Mapped
#(
    parameter   PC_WIDTH                                    = 0,
    parameter   WORD_WIDTH                                  = 0,
    parameter   ADDR_WIDTH                                  = 0,
    parameter   D_OPERAND_WIDTH                             = 0,

    parameter   INITIAL_THREAD                              = 0,
    parameter   THREAD_COUNT                                = 0,
    parameter   THREAD_ADDR_WIDTH                           = 0,

    parameter   BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET       = 0,
    parameter   BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET       = 0,
    parameter   BASIC_BLOCK_COUNTER_WORD_WIDTH              = 0,
    parameter   BASIC_BLOCK_COUNTER_ADDR_WIDTH              = 0,
    parameter   BASIC_BLOCK_COUNTER_DEPTH                   = 0,
    parameter   BASIC_BLOCK_COUNTER_RAMSTYLE                = 0,
    parameter   BASIC_BLOCK_COUNTER_INIT_FILE               = 0,

    parameter   CONTROL_MEMORY_WRITE_WORD_OFFSET            = 0,
    parameter   CONTROL_MEMORY_WRITE_ADDR_OFFSET            = 0,
    parameter   CONTROL_MEMORY_WORD_WIDTH                   = 0,
    parameter   CONTROL_MEMORY_ADDR_WIDTH                   = 0,
    parameter   CONTROL_MEMORY_DEPTH                        = 0,
    parameter   CONTROL_MEMORY_RAMSTYLE                     = 0,
    parameter   CONTROL_MEMORY_INIT_FILE                    = 0,
    parameter   CONTROL_MEMORY_MATCH_WIDTH                  = 0,
    parameter   CONTROL_MEMORY_COND_WIDTH                   = 0,
    parameter   CONTROL_MEMORY_LINK_WIDTH                   = 0,

    parameter   DEFAULT_OFFSET_WRITE_WORD_OFFSET            = 0,
    parameter   DEFAULT_OFFSET_WRITE_ADDR_OFFSET            = 0,
    parameter   DEFAULT_OFFSET_WORD_WIDTH                   = 0,
    parameter   DEFAULT_OFFSET_ADDR_WIDTH                   = 0,
    parameter   DEFAULT_OFFSET_DEPTH                        = 0,
    parameter   DEFAULT_OFFSET_RAMSTYLE                     = 0,
    parameter   DEFAULT_OFFSET_INIT_FILE                    = 0,

    parameter   PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET        = 0,
    parameter   PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET        = 0,
    parameter   PROGRAMMED_OFFSETS_WORD_WIDTH               = 0,
    parameter   PROGRAMMED_OFFSETS_ADDR_WIDTH               = 0,
    parameter   PROGRAMMED_OFFSETS_DEPTH                    = 0,
    parameter   PROGRAMMED_OFFSETS_RAMSTYLE                 = 0,
    parameter   PROGRAMMED_OFFSETS_INIT_FILE                = 0,

    parameter   INCREMENTS_WRITE_WORD_OFFSET                = 0,
    parameter   INCREMENTS_WRITE_ADDR_OFFSET                = 0,
    parameter   INCREMENTS_WORD_WIDTH                       = 0,
    parameter   INCREMENTS_ADDR_WIDTH                       = 0,
    parameter   INCREMENTS_DEPTH                            = 0,
    parameter   INCREMENTS_RAMSTYLE                         = 0,
    parameter   INCREMENTS_INIT_FILE                        = 0
)
(
    input   wire                                            clock,

    // from ControlPath
    input   wire    [PC_WIDTH-1:0]                          PC,

    // from stage 1
    input   wire    [ADDR_WIDTH-1:0]                        addr_in,

    // from I/O Predication, stage 3
    input   wire                                            IO_ready,

    // from DataPath ALU output
    input   wire    [D_OPERAND_WIDTH-1:0]                   ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]                        ALU_write_data,

    // from stage 3, to stage 4 (the Memory subsystem)
    output  wire    [ADDR_WIDTH-1:0]                        addr_out
);

// -----------------------------------------------------------

    // Generate these combinationaly from the ALU_write_addr.
    wire    ALU_wren_BBC;
    wire    ALU_wren_CTL;
    wire    ALU_wren_DO;
    wire    ALU_wren_PO;
    wire    ALU_wren_INC;

    Address_Decoder
    #(
        .ADDR_COUNT     (BASIC_BLOCK_COUNTER_DEPTH),
        .ADDR_BASE      (BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    BBC
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_BBC)
    );

    Address_Decoder
    #(
        .ADDR_COUNT     (CONTROL_MEMORY_DEPTH),
        .ADDR_BASE      (CONTROL_MEMORY_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    CTL
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_CTL)
    );

    Address_Decoder
    #(
        .ADDR_COUNT     (DEFAULT_OFFSET_DEPTH),
        .ADDR_BASE      (DEFAULT_OFFSET_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    DO
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_DO)
    );

    Address_Decoder
    #(
        .ADDR_COUNT     (PROGRAMMED_OFFSETS_DEPTH),
        .ADDR_BASE      (PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    PO
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_PO)
    );

    Address_Decoder
    #(
        .ADDR_COUNT     (INCREMENTS_DEPTH),
        .ADDR_BASE      (INCREMENTS_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    INC
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_INC)
    );


// -----------------------------------------------------------

    // Subsets of above, so we can align multiple Addressing instances along a word.
    // We want to keep all memory map knowledge in here.
    reg     [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    ALU_write_data_BBC;
    reg     [CONTROL_MEMORY_WORD_WIDTH-1:0]         ALU_write_data_CTL;
    reg     [DEFAULT_OFFSET_WORD_WIDTH-1:0]         ALU_write_data_DO;
    reg     [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]     ALU_write_data_PO;
    reg     [INCREMENTS_WORD_WIDTH-1:0]             ALU_write_data_INC;

    always @(*) begin
        ALU_write_data_BBC <= ALU_write_data[BASIC_BLOCK_COUNTER_WORD_WIDTH + BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET-1:BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET];
        ALU_write_data_CTL <= ALU_write_data[CONTROL_MEMORY_WORD_WIDTH + CONTROL_MEMORY_WRITE_WORD_OFFSET-1:CONTROL_MEMORY_WRITE_WORD_OFFSET];
        ALU_write_data_DO  <= ALU_write_data[DEFAULT_OFFSET_WORD_WIDTH + DEFAULT_OFFSET_WRITE_WORD_OFFSET-1:DEFAULT_OFFSET_WRITE_WORD_OFFSET];
        ALU_write_data_PO  <= ALU_write_data[PROGRAMMED_OFFSETS_WORD_WIDTH + PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET-1:PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET];
        ALU_write_data_INC <= ALU_write_data[INCREMENTS_WORD_WIDTH + INCREMENTS_WRITE_WORD_OFFSET-1:INCREMENTS_WRITE_WORD_OFFSET];
    end

// -----------------------------------------------------------

    Addressing
    #(
        .PC_WIDTH                           (PC_WIDTH),
        .WORD_WIDTH                         (WORD_WIDTH),
        .ADDR_WIDTH                         (ADDR_WIDTH),
        .D_OPERAND_WIDTH                    (D_OPERAND_WIDTH),

        .INITIAL_THREAD                     (INITIAL_THREAD),
        .THREAD_COUNT                       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH                  (THREAD_ADDR_WIDTH),

        .BASIC_BLOCK_COUNTER_WORD_WIDTH     (BASIC_BLOCK_COUNTER_WORD_WIDTH),
        .BASIC_BLOCK_COUNTER_ADDR_WIDTH     (BASIC_BLOCK_COUNTER_ADDR_WIDTH),
        .BASIC_BLOCK_COUNTER_DEPTH          (BASIC_BLOCK_COUNTER_DEPTH),
        .BASIC_BLOCK_COUNTER_RAMSTYLE       (BASIC_BLOCK_COUNTER_RAMSTYLE),
        .BASIC_BLOCK_COUNTER_INIT_FILE      (BASIC_BLOCK_COUNTER_INIT_FILE),

        .CONTROL_MEMORY_WORD_WIDTH          (CONTROL_MEMORY_WORD_WIDTH),
        .CONTROL_MEMORY_ADDR_WIDTH          (CONTROL_MEMORY_ADDR_WIDTH),
        .CONTROL_MEMORY_DEPTH               (CONTROL_MEMORY_DEPTH),
        .CONTROL_MEMORY_RAMSTYLE            (CONTROL_MEMORY_RAMSTYLE),
        .CONTROL_MEMORY_INIT_FILE           (CONTROL_MEMORY_INIT_FILE),
        .CONTROL_MEMORY_MATCH_WIDTH         (CONTROL_MEMORY_MATCH_WIDTH),
        .CONTROL_MEMORY_COND_WIDTH          (CONTROL_MEMORY_COND_WIDTH),
        .CONTROL_MEMORY_LINK_WIDTH          (CONTROL_MEMORY_LINK_WIDTH),

        .DEFAULT_OFFSET_WORD_WIDTH          (DEFAULT_OFFSET_WORD_WIDTH),
        .DEFAULT_OFFSET_ADDR_WIDTH          (DEFAULT_OFFSET_ADDR_WIDTH),
        .DEFAULT_OFFSET_DEPTH               (DEFAULT_OFFSET_DEPTH),
        .DEFAULT_OFFSET_RAMSTYLE            (DEFAULT_OFFSET_RAMSTYLE),
        .DEFAULT_OFFSET_INIT_FILE           (DEFAULT_OFFSET_INIT_FILE),

        .PROGRAMMED_OFFSETS_WORD_WIDTH      (PROGRAMMED_OFFSETS_WORD_WIDTH),
        .PROGRAMMED_OFFSETS_ADDR_WIDTH      (PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .PROGRAMMED_OFFSETS_DEPTH           (PROGRAMMED_OFFSETS_DEPTH),
        .PROGRAMMED_OFFSETS_RAMSTYLE        (PROGRAMMED_OFFSETS_RAMSTYLE),
        .PROGRAMMED_OFFSETS_INIT_FILE       (PROGRAMMED_OFFSETS_INIT_FILE),

        .INCREMENTS_WORD_WIDTH              (INCREMENTS_WORD_WIDTH),
        .INCREMENTS_ADDR_WIDTH              (INCREMENTS_ADDR_WIDTH),
        .INCREMENTS_DEPTH                   (INCREMENTS_DEPTH),
        .INCREMENTS_RAMSTYLE                (INCREMENTS_RAMSTYLE),
        .INCREMENTS_INIT_FILE               (INCREMENTS_INIT_FILE)
    )
    Addressing
    (
        .clock                              (clock),
        .PC                                 (PC),

        .addr_in                            (addr_in),

        .IO_ready                           (IO_ready),

        .ALU_wren_BBC                       (ALU_wren_BBC),
        .ALU_wren_CTL                       (ALU_wren_CTL),
        .ALU_wren_DO                        (ALU_wren_DO),
        .ALU_wren_PO                        (ALU_wren_PO),
        .ALU_wren_INC                       (ALU_wren_INC),

        .ALU_write_addr                     (ALU_write_addr),
        .ALU_write_data                     (ALU_write_data),

        .ALU_write_data_BBC                 (ALU_write_data_BBC),
        .ALU_write_data_CTL                 (ALU_write_data_CTL),
        .ALU_write_data_DO                  (ALU_write_data_DO),
        .ALU_write_data_PO                  (ALU_write_data_PO),
        .ALU_write_data_INC                 (ALU_write_data_INC),

        .addr_out                           (addr_out)
    );
endmodule
