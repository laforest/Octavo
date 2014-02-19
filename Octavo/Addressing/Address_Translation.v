
module Address_Translation
#(
    parameter   PC_WIDTH                                    = 0,
    parameter   WORD_WIDTH                                  = 0,
    parameter   D_OPERAND_WIDTH                             = 0,
    parameter   A_OPERAND_WIDTH                             = 0,
    parameter   B_OPERAND_WIDTH                             = 0,

    parameter   INITIAL_THREAD                              = 0,
    parameter   THREAD_COUNT                                = 0,
    parameter   THREAD_ADDR_WIDTH                           = 0,

// -----------------------------------------------------------

    parameter   A_BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET     = 0,
    parameter   A_BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET     = 0,
    parameter   A_BASIC_BLOCK_COUNTER_WORD_WIDTH            = 0,
    parameter   A_BASIC_BLOCK_COUNTER_ADDR_WIDTH            = 0,
    parameter   A_BASIC_BLOCK_COUNTER_DEPTH                 = 0,
    parameter   A_BASIC_BLOCK_COUNTER_RAMSTYLE              = 0,
    parameter   A_BASIC_BLOCK_COUNTER_INIT_FILE             = 0,

    parameter   A_CONTROL_MEMORY_WRITE_WORD_OFFSET          = 0,
    parameter   A_CONTROL_MEMORY_WRITE_ADDR_OFFSET          = 0,
    parameter   A_CONTROL_MEMORY_WORD_WIDTH                 = 0,
    parameter   A_CONTROL_MEMORY_ADDR_WIDTH                 = 0,
    parameter   A_CONTROL_MEMORY_DEPTH                      = 0,
    parameter   A_CONTROL_MEMORY_RAMSTYLE                   = 0,
    parameter   A_CONTROL_MEMORY_INIT_FILE                  = 0,
    parameter   A_CONTROL_MEMORY_MATCH_WIDTH                = 0,
    parameter   A_CONTROL_MEMORY_COND_WIDTH                 = 0,
    parameter   A_CONTROL_MEMORY_LINK_WIDTH                 = 0,

    parameter   A_DEFAULT_OFFSET_WRITE_WORD_OFFSET          = 0,
    parameter   A_DEFAULT_OFFSET_WRITE_ADDR_OFFSET          = 0,
    parameter   A_DEFAULT_OFFSET_WORD_WIDTH                 = 0,
    parameter   A_DEFAULT_OFFSET_ADDR_WIDTH                 = 0,
    parameter   A_DEFAULT_OFFSET_DEPTH                      = 0,
    parameter   A_DEFAULT_OFFSET_RAMSTYLE                   = 0,
    parameter   A_DEFAULT_OFFSET_INIT_FILE                  = 0,

    parameter   A_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET      = 0,
    parameter   A_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET      = 0,
    parameter   A_PROGRAMMED_OFFSETS_WORD_WIDTH             = 0,
    parameter   A_PROGRAMMED_OFFSETS_ADDR_WIDTH             = 0,
    parameter   A_PROGRAMMED_OFFSETS_DEPTH                  = 0,
    parameter   A_PROGRAMMED_OFFSETS_RAMSTYLE               = 0,
    parameter   A_PROGRAMMED_OFFSETS_INIT_FILE              = 0,

    parameter   A_INCREMENTS_WRITE_WORD_OFFSET              = 0,
    parameter   A_INCREMENTS_WRITE_ADDR_OFFSET              = 0,
    parameter   A_INCREMENTS_WORD_WIDTH                     = 0,
    parameter   A_INCREMENTS_ADDR_WIDTH                     = 0,
    parameter   A_INCREMENTS_DEPTH                          = 0,
    parameter   A_INCREMENTS_RAMSTYLE                       = 0,
    parameter   A_INCREMENTS_INIT_FILE                      = 0,

// -----------------------------------------------------------

    parameter   B_BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET     = 0,
    parameter   B_BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET     = 0,
    parameter   B_BASIC_BLOCK_COUNTER_WORD_WIDTH            = 0,
    parameter   B_BASIC_BLOCK_COUNTER_ADDR_WIDTH            = 0,
    parameter   B_BASIC_BLOCK_COUNTER_DEPTH                 = 0,
    parameter   B_BASIC_BLOCK_COUNTER_RAMSTYLE              = 0,
    parameter   B_BASIC_BLOCK_COUNTER_INIT_FILE             = 0,

    parameter   B_CONTROL_MEMORY_WRITE_WORD_OFFSET          = 0,
    parameter   B_CONTROL_MEMORY_WRITE_ADDR_OFFSET          = 0,
    parameter   B_CONTROL_MEMORY_WORD_WIDTH                 = 0,
    parameter   B_CONTROL_MEMORY_ADDR_WIDTH                 = 0,
    parameter   B_CONTROL_MEMORY_DEPTH                      = 0,
    parameter   B_CONTROL_MEMORY_RAMSTYLE                   = 0,
    parameter   B_CONTROL_MEMORY_INIT_FILE                  = 0,
    parameter   B_CONTROL_MEMORY_MATCH_WIDTH                = 0,
    parameter   B_CONTROL_MEMORY_COND_WIDTH                 = 0,
    parameter   B_CONTROL_MEMORY_LINK_WIDTH                 = 0,

    parameter   B_DEFAULT_OFFSET_WRITE_WORD_OFFSET          = 0,
    parameter   B_DEFAULT_OFFSET_WRITE_ADDR_OFFSET          = 0,
    parameter   B_DEFAULT_OFFSET_WORD_WIDTH                 = 0,
    parameter   B_DEFAULT_OFFSET_ADDR_WIDTH                 = 0,
    parameter   B_DEFAULT_OFFSET_DEPTH                      = 0,
    parameter   B_DEFAULT_OFFSET_RAMSTYLE                   = 0,
    parameter   B_DEFAULT_OFFSET_INIT_FILE                  = 0,

    parameter   B_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET      = 0,
    parameter   B_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET      = 0,
    parameter   B_PROGRAMMED_OFFSETS_WORD_WIDTH             = 0,
    parameter   B_PROGRAMMED_OFFSETS_ADDR_WIDTH             = 0,
    parameter   B_PROGRAMMED_OFFSETS_DEPTH                  = 0,
    parameter   B_PROGRAMMED_OFFSETS_RAMSTYLE               = 0,
    parameter   B_PROGRAMMED_OFFSETS_INIT_FILE              = 0,

    parameter   B_INCREMENTS_WRITE_WORD_OFFSET              = 0,
    parameter   B_INCREMENTS_WRITE_ADDR_OFFSET              = 0,
    parameter   B_INCREMENTS_WORD_WIDTH                     = 0,
    parameter   B_INCREMENTS_ADDR_WIDTH                     = 0,
    parameter   B_INCREMENTS_DEPTH                          = 0,
    parameter   B_INCREMENTS_RAMSTYLE                       = 0,
    parameter   B_INCREMENTS_INIT_FILE                      = 0,

// -----------------------------------------------------------

    parameter   D_BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET     = 0,
    parameter   D_BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET     = 0,
    parameter   D_BASIC_BLOCK_COUNTER_WORD_WIDTH            = 0,
    parameter   D_BASIC_BLOCK_COUNTER_ADDR_WIDTH            = 0,
    parameter   D_BASIC_BLOCK_COUNTER_DEPTH                 = 0,
    parameter   D_BASIC_BLOCK_COUNTER_RAMSTYLE              = 0,
    parameter   D_BASIC_BLOCK_COUNTER_INIT_FILE             = 0,

    parameter   D_CONTROL_MEMORY_WRITE_WORD_OFFSET          = 0,
    parameter   D_CONTROL_MEMORY_WRITE_ADDR_OFFSET          = 0,
    parameter   D_CONTROL_MEMORY_WORD_WIDTH                 = 0,
    parameter   D_CONTROL_MEMORY_ADDR_WIDTH                 = 0,
    parameter   D_CONTROL_MEMORY_DEPTH                      = 0,
    parameter   D_CONTROL_MEMORY_RAMSTYLE                   = 0,
    parameter   D_CONTROL_MEMORY_INIT_FILE                  = 0,
    parameter   D_CONTROL_MEMORY_MATCH_WIDTH                = 0,
    parameter   D_CONTROL_MEMORY_COND_WIDTH                 = 0,
    parameter   D_CONTROL_MEMORY_LINK_WIDTH                 = 0,

    parameter   D_DEFAULT_OFFSET_WRITE_WORD_OFFSET          = 0,
    parameter   D_DEFAULT_OFFSET_WRITE_ADDR_OFFSET          = 0,
    parameter   D_DEFAULT_OFFSET_WORD_WIDTH                 = 0,
    parameter   D_DEFAULT_OFFSET_ADDR_WIDTH                 = 0,
    parameter   D_DEFAULT_OFFSET_DEPTH                      = 0,
    parameter   D_DEFAULT_OFFSET_RAMSTYLE                   = 0,
    parameter   D_DEFAULT_OFFSET_INIT_FILE                  = 0,

    parameter   D_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET      = 0,
    parameter   D_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET      = 0,
    parameter   D_PROGRAMMED_OFFSETS_WORD_WIDTH             = 0,
    parameter   D_PROGRAMMED_OFFSETS_ADDR_WIDTH             = 0,
    parameter   D_PROGRAMMED_OFFSETS_DEPTH                  = 0,
    parameter   D_PROGRAMMED_OFFSETS_RAMSTYLE               = 0,
    parameter   D_PROGRAMMED_OFFSETS_INIT_FILE              = 0,

    parameter   D_INCREMENTS_WRITE_WORD_OFFSET              = 0,
    parameter   D_INCREMENTS_WRITE_ADDR_OFFSET              = 0,
    parameter   D_INCREMENTS_WORD_WIDTH                     = 0,
    parameter   D_INCREMENTS_ADDR_WIDTH                     = 0,
    parameter   D_INCREMENTS_DEPTH                          = 0,
    parameter   D_INCREMENTS_RAMSTYLE                       = 0,
    parameter   D_INCREMENTS_INIT_FILE                      = 0
)
(
    input   wire                                            clock,

    // from ControlPath
    input   wire    [PC_WIDTH-1:0]                          PC,

    // from stage 1
    input   wire    [A_OPERAND_WIDTH-1:0]                   A_addr_in,
    input   wire    [B_OPERAND_WIDTH-1:0]                   B_addr_in,
    input   wire    [D_OPERAND_WIDTH-1:0]                   D_addr_in,

    // from I/O Predication, stage 3
    input   wire                                            IO_ready,

    // from DataPath ALU output
    input   wire    [D_OPERAND_WIDTH-1:0]                   ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]                        ALU_write_data,

    // from stage 3, to stage 4 (the Memory subsystem)
    output  wire    [A_OPERAND_WIDTH-1:0]                   A_addr_out,
    output  wire    [B_OPERAND_WIDTH-1:0]                   B_addr_out,
    output  wire    [D_OPERAND_WIDTH-1:0]                   D_addr_out
);

// -----------------------------------------------------------

    Addressing_Mapped
    #(
        .PC_WIDTH                                   (PC_WIDTH),
        .WORD_WIDTH                                 (WORD_WIDTH),
        .ADDR_WIDTH                                 (A_OPERAND_WIDTH),
        .D_OPERAND_WIDTH                            (D_OPERAND_WIDTH),

        .INITIAL_THREAD                             (INITIAL_THREAD),
        .THREAD_COUNT                               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH                          (THREAD_ADDR_WIDTH),

        .BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET      (A_BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET),
        .BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET      (A_BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET),
        .BASIC_BLOCK_COUNTER_WORD_WIDTH             (A_BASIC_BLOCK_COUNTER_WORD_WIDTH),
        .BASIC_BLOCK_COUNTER_ADDR_WIDTH             (A_BASIC_BLOCK_COUNTER_ADDR_WIDTH),
        .BASIC_BLOCK_COUNTER_DEPTH                  (A_BASIC_BLOCK_COUNTER_DEPTH),
        .BASIC_BLOCK_COUNTER_RAMSTYLE               (A_BASIC_BLOCK_COUNTER_RAMSTYLE),
        .BASIC_BLOCK_COUNTER_INIT_FILE              (A_BASIC_BLOCK_COUNTER_INIT_FILE),

        .CONTROL_MEMORY_WRITE_WORD_OFFSET           (A_CONTROL_MEMORY_WRITE_WORD_OFFSET),
        .CONTROL_MEMORY_WRITE_ADDR_OFFSET           (A_CONTROL_MEMORY_WRITE_ADDR_OFFSET),
        .CONTROL_MEMORY_WORD_WIDTH                  (A_CONTROL_MEMORY_WORD_WIDTH),
        .CONTROL_MEMORY_ADDR_WIDTH                  (A_CONTROL_MEMORY_ADDR_WIDTH),
        .CONTROL_MEMORY_DEPTH                       (A_CONTROL_MEMORY_DEPTH),
        .CONTROL_MEMORY_RAMSTYLE                    (A_CONTROL_MEMORY_RAMSTYLE),
        .CONTROL_MEMORY_INIT_FILE                   (A_CONTROL_MEMORY_INIT_FILE),
        .CONTROL_MEMORY_MATCH_WIDTH                 (A_CONTROL_MEMORY_MATCH_WIDTH),
        .CONTROL_MEMORY_COND_WIDTH                  (A_CONTROL_MEMORY_COND_WIDTH),
        .CONTROL_MEMORY_LINK_WIDTH                  (A_CONTROL_MEMORY_LINK_WIDTH),

        .DEFAULT_OFFSET_WRITE_WORD_OFFSET           (A_DEFAULT_OFFSET_WRITE_WORD_OFFSET),
        .DEFAULT_OFFSET_WRITE_ADDR_OFFSET           (A_DEFAULT_OFFSET_WRITE_ADDR_OFFSET),
        .DEFAULT_OFFSET_WORD_WIDTH                  (A_DEFAULT_OFFSET_WORD_WIDTH),
        .DEFAULT_OFFSET_ADDR_WIDTH                  (A_DEFAULT_OFFSET_ADDR_WIDTH),
        .DEFAULT_OFFSET_DEPTH                       (A_DEFAULT_OFFSET_DEPTH),
        .DEFAULT_OFFSET_RAMSTYLE                    (A_DEFAULT_OFFSET_RAMSTYLE),
        .DEFAULT_OFFSET_INIT_FILE                   (A_DEFAULT_OFFSET_INIT_FILE),

        .PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET       (A_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET),
        .PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET       (A_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET),
        .PROGRAMMED_OFFSETS_WORD_WIDTH              (A_PROGRAMMED_OFFSETS_WORD_WIDTH),
        .PROGRAMMED_OFFSETS_ADDR_WIDTH              (A_PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .PROGRAMMED_OFFSETS_DEPTH                   (A_PROGRAMMED_OFFSETS_DEPTH),
        .PROGRAMMED_OFFSETS_RAMSTYLE                (A_PROGRAMMED_OFFSETS_RAMSTYLE),
        .PROGRAMMED_OFFSETS_INIT_FILE               (A_PROGRAMMED_OFFSETS_INIT_FILE),

        .INCREMENTS_WRITE_WORD_OFFSET               (A_INCREMENTS_WRITE_WORD_OFFSET),
        .INCREMENTS_WRITE_ADDR_OFFSET               (A_INCREMENTS_WRITE_ADDR_OFFSET),
        .INCREMENTS_WORD_WIDTH                      (A_INCREMENTS_WORD_WIDTH),
        .INCREMENTS_ADDR_WIDTH                      (A_INCREMENTS_ADDR_WIDTH),
        .INCREMENTS_DEPTH                           (A_INCREMENTS_DEPTH),
        .INCREMENTS_RAMSTYLE                        (A_INCREMENTS_RAMSTYLE),
        .INCREMENTS_INIT_FILE                       (A_INCREMENTS_INIT_FILE)
    )
    A
    (
        .clock                                      (clock),
        .PC                                         (PC),
        .addr_in                                    (A_addr_in),
        .IO_ready                                   (IO_ready),
        .ALU_write_addr                             (ALU_write_addr),
        .ALU_write_data                             (ALU_write_data),
        .addr_out                                   (A_addr_out)
    );

// -----------------------------------------------------------

    Addressing_Mapped
    #(
        .PC_WIDTH                                   (PC_WIDTH),
        .WORD_WIDTH                                 (WORD_WIDTH),
        .ADDR_WIDTH                                 (B_OPERAND_WIDTH),
        .D_OPERAND_WIDTH                            (D_OPERAND_WIDTH),

        .INITIAL_THREAD                             (INITIAL_THREAD),
        .THREAD_COUNT                               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH                          (THREAD_ADDR_WIDTH),

        .BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET      (B_BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET),
        .BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET      (B_BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET),
        .BASIC_BLOCK_COUNTER_WORD_WIDTH             (B_BASIC_BLOCK_COUNTER_WORD_WIDTH),
        .BASIC_BLOCK_COUNTER_ADDR_WIDTH             (B_BASIC_BLOCK_COUNTER_ADDR_WIDTH),
        .BASIC_BLOCK_COUNTER_DEPTH                  (B_BASIC_BLOCK_COUNTER_DEPTH),
        .BASIC_BLOCK_COUNTER_RAMSTYLE               (B_BASIC_BLOCK_COUNTER_RAMSTYLE),
        .BASIC_BLOCK_COUNTER_INIT_FILE              (B_BASIC_BLOCK_COUNTER_INIT_FILE),

        .CONTROL_MEMORY_WRITE_WORD_OFFSET           (B_CONTROL_MEMORY_WRITE_WORD_OFFSET),
        .CONTROL_MEMORY_WRITE_ADDR_OFFSET           (B_CONTROL_MEMORY_WRITE_ADDR_OFFSET),
        .CONTROL_MEMORY_WORD_WIDTH                  (B_CONTROL_MEMORY_WORD_WIDTH),
        .CONTROL_MEMORY_ADDR_WIDTH                  (B_CONTROL_MEMORY_ADDR_WIDTH),
        .CONTROL_MEMORY_DEPTH                       (B_CONTROL_MEMORY_DEPTH),
        .CONTROL_MEMORY_RAMSTYLE                    (B_CONTROL_MEMORY_RAMSTYLE),
        .CONTROL_MEMORY_INIT_FILE                   (B_CONTROL_MEMORY_INIT_FILE),
        .CONTROL_MEMORY_MATCH_WIDTH                 (B_CONTROL_MEMORY_MATCH_WIDTH),
        .CONTROL_MEMORY_COND_WIDTH                  (B_CONTROL_MEMORY_COND_WIDTH),
        .CONTROL_MEMORY_LINK_WIDTH                  (B_CONTROL_MEMORY_LINK_WIDTH),

        .DEFAULT_OFFSET_WRITE_WORD_OFFSET           (B_DEFAULT_OFFSET_WRITE_WORD_OFFSET),
        .DEFAULT_OFFSET_WRITE_ADDR_OFFSET           (B_DEFAULT_OFFSET_WRITE_ADDR_OFFSET),
        .DEFAULT_OFFSET_WORD_WIDTH                  (B_DEFAULT_OFFSET_WORD_WIDTH),
        .DEFAULT_OFFSET_ADDR_WIDTH                  (B_DEFAULT_OFFSET_ADDR_WIDTH),
        .DEFAULT_OFFSET_DEPTH                       (B_DEFAULT_OFFSET_DEPTH),
        .DEFAULT_OFFSET_RAMSTYLE                    (B_DEFAULT_OFFSET_RAMSTYLE),
        .DEFAULT_OFFSET_INIT_FILE                   (B_DEFAULT_OFFSET_INIT_FILE),

        .PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET       (B_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET),
        .PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET       (B_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET),
        .PROGRAMMED_OFFSETS_WORD_WIDTH              (B_PROGRAMMED_OFFSETS_WORD_WIDTH),
        .PROGRAMMED_OFFSETS_ADDR_WIDTH              (B_PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .PROGRAMMED_OFFSETS_DEPTH                   (B_PROGRAMMED_OFFSETS_DEPTH),
        .PROGRAMMED_OFFSETS_RAMSTYLE                (B_PROGRAMMED_OFFSETS_RAMSTYLE),
        .PROGRAMMED_OFFSETS_INIT_FILE               (B_PROGRAMMED_OFFSETS_INIT_FILE),

        .INCREMENTS_WRITE_WORD_OFFSET               (B_INCREMENTS_WRITE_WORD_OFFSET),
        .INCREMENTS_WRITE_ADDR_OFFSET               (B_INCREMENTS_WRITE_ADDR_OFFSET),
        .INCREMENTS_WORD_WIDTH                      (B_INCREMENTS_WORD_WIDTH),
        .INCREMENTS_ADDR_WIDTH                      (B_INCREMENTS_ADDR_WIDTH),
        .INCREMENTS_DEPTH                           (B_INCREMENTS_DEPTH),
        .INCREMENTS_RAMSTYLE                        (B_INCREMENTS_RAMSTYLE),
        .INCREMENTS_INIT_FILE                       (B_INCREMENTS_INIT_FILE)
    )
    B
    (
        .clock                                      (clock),
        .PC                                         (PC),
        .addr_in                                    (B_addr_in),
        .IO_ready                                   (IO_ready),
        .ALU_write_addr                             (ALU_write_addr),
        .ALU_write_data                             (ALU_write_data),
        .addr_out                                   (B_addr_out)
    );

// -----------------------------------------------------------

    Addressing_Mapped
    #(
        .PC_WIDTH                                   (PC_WIDTH),
        .WORD_WIDTH                                 (WORD_WIDTH),
        .ADDR_WIDTH                                 (D_OPERAND_WIDTH),
        .D_OPERAND_WIDTH                            (D_OPERAND_WIDTH),

        .INITIAL_THREAD                             (INITIAL_THREAD),
        .THREAD_COUNT                               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH                          (THREAD_ADDR_WIDTH),

        .BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET      (D_BASIC_BLOCK_COUNTER_WRITE_WORD_OFFSET),
        .BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET      (D_BASIC_BLOCK_COUNTER_WRITE_ADDR_OFFSET),
        .BASIC_BLOCK_COUNTER_WORD_WIDTH             (D_BASIC_BLOCK_COUNTER_WORD_WIDTH),
        .BASIC_BLOCK_COUNTER_ADDR_WIDTH             (D_BASIC_BLOCK_COUNTER_ADDR_WIDTH),
        .BASIC_BLOCK_COUNTER_DEPTH                  (D_BASIC_BLOCK_COUNTER_DEPTH),
        .BASIC_BLOCK_COUNTER_RAMSTYLE               (D_BASIC_BLOCK_COUNTER_RAMSTYLE),
        .BASIC_BLOCK_COUNTER_INIT_FILE              (D_BASIC_BLOCK_COUNTER_INIT_FILE),

        .CONTROL_MEMORY_WRITE_WORD_OFFSET           (D_CONTROL_MEMORY_WRITE_WORD_OFFSET),
        .CONTROL_MEMORY_WRITE_ADDR_OFFSET           (D_CONTROL_MEMORY_WRITE_ADDR_OFFSET),
        .CONTROL_MEMORY_WORD_WIDTH                  (D_CONTROL_MEMORY_WORD_WIDTH),
        .CONTROL_MEMORY_ADDR_WIDTH                  (D_CONTROL_MEMORY_ADDR_WIDTH),
        .CONTROL_MEMORY_DEPTH                       (D_CONTROL_MEMORY_DEPTH),
        .CONTROL_MEMORY_RAMSTYLE                    (D_CONTROL_MEMORY_RAMSTYLE),
        .CONTROL_MEMORY_INIT_FILE                   (D_CONTROL_MEMORY_INIT_FILE),
        .CONTROL_MEMORY_MATCH_WIDTH                 (D_CONTROL_MEMORY_MATCH_WIDTH),
        .CONTROL_MEMORY_COND_WIDTH                  (D_CONTROL_MEMORY_COND_WIDTH),
        .CONTROL_MEMORY_LINK_WIDTH                  (D_CONTROL_MEMORY_LINK_WIDTH),

        .DEFAULT_OFFSET_WRITE_WORD_OFFSET           (D_DEFAULT_OFFSET_WRITE_WORD_OFFSET),
        .DEFAULT_OFFSET_WRITE_ADDR_OFFSET           (D_DEFAULT_OFFSET_WRITE_ADDR_OFFSET),
        .DEFAULT_OFFSET_WORD_WIDTH                  (D_DEFAULT_OFFSET_WORD_WIDTH),
        .DEFAULT_OFFSET_ADDR_WIDTH                  (D_DEFAULT_OFFSET_ADDR_WIDTH),
        .DEFAULT_OFFSET_DEPTH                       (D_DEFAULT_OFFSET_DEPTH),
        .DEFAULT_OFFSET_RAMSTYLE                    (D_DEFAULT_OFFSET_RAMSTYLE),
        .DEFAULT_OFFSET_INIT_FILE                   (D_DEFAULT_OFFSET_INIT_FILE),

        .PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET       (D_PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET),
        .PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET       (D_PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET),
        .PROGRAMMED_OFFSETS_WORD_WIDTH              (D_PROGRAMMED_OFFSETS_WORD_WIDTH),
        .PROGRAMMED_OFFSETS_ADDR_WIDTH              (D_PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .PROGRAMMED_OFFSETS_DEPTH                   (D_PROGRAMMED_OFFSETS_DEPTH),
        .PROGRAMMED_OFFSETS_RAMSTYLE                (D_PROGRAMMED_OFFSETS_RAMSTYLE),
        .PROGRAMMED_OFFSETS_INIT_FILE               (D_PROGRAMMED_OFFSETS_INIT_FILE),

        .INCREMENTS_WRITE_WORD_OFFSET               (D_INCREMENTS_WRITE_WORD_OFFSET),
        .INCREMENTS_WRITE_ADDR_OFFSET               (D_INCREMENTS_WRITE_ADDR_OFFSET),
        .INCREMENTS_WORD_WIDTH                      (D_INCREMENTS_WORD_WIDTH),
        .INCREMENTS_ADDR_WIDTH                      (D_INCREMENTS_ADDR_WIDTH),
        .INCREMENTS_DEPTH                           (D_INCREMENTS_DEPTH),
        .INCREMENTS_RAMSTYLE                        (D_INCREMENTS_RAMSTYLE),
        .INCREMENTS_INIT_FILE                       (D_INCREMENTS_INIT_FILE)
    )
    D
    (
        .clock                                      (clock),
        .PC                                         (PC),
        .addr_in                                    (D_addr_in),
        .IO_ready                                   (IO_ready),
        .ALU_write_addr                             (ALU_write_addr),
        .ALU_write_data                             (ALU_write_data),
        .addr_out                                   (D_addr_out)
    );

endmodule

