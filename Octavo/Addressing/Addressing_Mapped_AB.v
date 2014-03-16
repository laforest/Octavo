
// Wraps Addressing with data and address memory map info, for A/B memories

module Addressing_Mapped_AB
#(
    parameter   WORD_WIDTH                                  = 0,
    parameter   ADDR_WIDTH                                  = 0,
    parameter   D_OPERAND_WIDTH                             = 0,

    parameter   INITIAL_THREAD                              = 0,
    parameter   THREAD_COUNT                                = 0,
    parameter   THREAD_ADDR_WIDTH                           = 0,

    parameter   IO_READ_PORT_COUNT                          = 0,
    parameter   IO_READ_PORT_BASE_ADDR                      = 0,
    parameter   IO_READ_PORT_ADDR_WIDTH                     = 0,

    parameter   DEFAULT_OFFSET_WRITE_WORD_OFFSET            = 0,
    parameter   DEFAULT_OFFSET_WRITE_ADDR_OFFSET            = 0,
    parameter   DEFAULT_OFFSET_WORD_WIDTH                   = 0,
    parameter   DEFAULT_OFFSET_ADDR_WIDTH                   = 0,
    parameter   DEFAULT_OFFSET_DEPTH                        = 0,
    parameter   DEFAULT_OFFSET_RAMSTYLE                     = 0,
    parameter   DEFAULT_OFFSET_INIT_FILE                    = 0,

    parameter   PO_INC_READ_BASE_ADDR                       = 0,
    parameter   PO_INC_COUNT                                = 0,
    parameter   PO_INC_COUNT_ADDR_WIDTH                     = 0,

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

    // Does the address access indirected memory? (the read mapping of the programmed offsets)
    wire    indirect_memory;

    Address_Decoder
    #(
        .ADDR_COUNT     (PO_INC_COUNT),
        .ADDR_BASE      (PO_INC_READ_BASE_ADDR),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .REGISTERED     (`TRUE)
    )
    indirect
    (
        .clock          (clock),
        .addr           (addr_in),
        .hit            (indirect_memory)
    );

// -----------------------------------------------------------

    // Does the address access this memory's IO read ports?
    wire    IO_read_memory;

    Address_Decoder
    #(
        .ADDR_COUNT     (IO_READ_PORT_COUNT),
        .ADDR_BASE      (IO_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .REGISTERED     (`TRUE)
    )
    IO_read
    (
        .clock          (clock),
        .addr           (addr_in),
        .hit            (IO_read_memory)
    );

// -----------------------------------------------------------

    // Does the address access shared hardware? (unique instance, shared by all threads at same addr)
    // For A/B memories, this includes only I/O for now.
    reg     shared_hardware_memory;

    always @(*) begin
        shared_hardware_memory <= IO_read_memory;
    end

// -----------------------------------------------------------

    // Translates the original address LSB to internal PO/INC instance order
    wire    [PO_INC_COUNT_ADDR_WIDTH-1:0]   PO_INC_index;

    Address_Translator
    #(
        .ADDR_COUNT         (PO_INC_COUNT),
        .ADDR_BASE          (PO_INC_READ_BASE_ADDR),
        .ADDR_WIDTH         (PO_INC_COUNT_ADDR_WIDTH),
        .REGISTERED         (`FALSE)
    )
    PO_addr
    (
        .clock              (clock),
        .raw_address        (addr_in[PO_INC_COUNT_ADDR_WIDTH-1:0]),
        .translated_address (PO_INC_index)
    );

// -----------------------------------------------------------

    // Generate combinationaly from the ALU_write_addr.
    wire    ALU_wren_DO;

    Address_Decoder
    #(
        .ADDR_COUNT     (1),
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

// -----------------------------------------------------------

    // Generate one per PO_INC_COUNT, consecutively mapped in write address space, thread-muxed internally
    wire    [PO_INC_COUNT-1:0]  ALU_wren_PO;
    wire    [PO_INC_COUNT-1:0]  ALU_wren_INC;

    genvar count;

    generate
        for(count = 0; count < PO_INC_COUNT; count = count + 1) begin : PO_INC_ALU_wren

            Address_Decoder
            #(
                .ADDR_COUNT     (1),
                .ADDR_BASE      (PROGRAMMED_OFFSETS_WRITE_ADDR_OFFSET + count),
                .ADDR_WIDTH     (D_OPERAND_WIDTH),
                .REGISTERED     (`FALSE)
            )
            PO
            (
                .clock          (clock),
                .addr           (ALU_write_addr),
                .hit            (ALU_wren_PO[count])
            );

            Address_Decoder
            #(
                .ADDR_COUNT     (1),
                .ADDR_BASE      (INCREMENTS_WRITE_ADDR_OFFSET + count),
                .ADDR_WIDTH     (D_OPERAND_WIDTH),
                .REGISTERED     (`FALSE)
            )
            INC
            (
                .clock          (clock),
                .addr           (ALU_write_addr),
                .hit            (ALU_wren_INC[count])
            );
        end
    endgenerate

// -----------------------------------------------------------

    // Subsets of above, so we can align multiple memories along a word.
    // We want to keep all memory map knowledge out of here.
    reg     [DEFAULT_OFFSET_WORD_WIDTH-1:0]         ALU_write_data_DO;
    reg     [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]     ALU_write_data_PO;
    reg     [INCREMENTS_WORD_WIDTH-1:0]             ALU_write_data_INC;

    always @(*) begin
        ALU_write_data_DO  <= ALU_write_data[DEFAULT_OFFSET_WORD_WIDTH + DEFAULT_OFFSET_WRITE_WORD_OFFSET-1:DEFAULT_OFFSET_WRITE_WORD_OFFSET];
        ALU_write_data_PO  <= ALU_write_data[PROGRAMMED_OFFSETS_WORD_WIDTH + PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET-1:PROGRAMMED_OFFSETS_WRITE_WORD_OFFSET];
        ALU_write_data_INC <= ALU_write_data[INCREMENTS_WORD_WIDTH + INCREMENTS_WRITE_WORD_OFFSET-1:INCREMENTS_WRITE_WORD_OFFSET];
    end

// -----------------------------------------------------------

    Addressing
    #(
        .WORD_WIDTH                         (WORD_WIDTH),
        .ADDR_WIDTH                         (ADDR_WIDTH),
        .D_OPERAND_WIDTH                    (D_OPERAND_WIDTH),

        .INITIAL_THREAD                     (INITIAL_THREAD),
        .THREAD_COUNT                       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH                  (THREAD_ADDR_WIDTH),

        .DEFAULT_OFFSET_WORD_WIDTH          (DEFAULT_OFFSET_WORD_WIDTH),
        .DEFAULT_OFFSET_ADDR_WIDTH          (DEFAULT_OFFSET_ADDR_WIDTH),
        .DEFAULT_OFFSET_DEPTH               (DEFAULT_OFFSET_DEPTH),
        .DEFAULT_OFFSET_RAMSTYLE            (DEFAULT_OFFSET_RAMSTYLE),
        .DEFAULT_OFFSET_INIT_FILE           (DEFAULT_OFFSET_INIT_FILE),

        .PO_INC_COUNT                       (PO_INC_COUNT),
        .PO_INC_COUNT_ADDR_WIDTH            (PO_INC_COUNT_ADDR_WIDTH),

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

        .addr_in                            (addr_in),

        .PO_INC_index                       (PO_INC_index),
        .indirect_memory                    (indirect_memory),
        .shared_hardware_memory             (shared_hardware_memory),

        .IO_ready                           (IO_ready),

        .ALU_wren_DO                        (ALU_wren_DO),
        .ALU_wren_PO                        (ALU_wren_PO),
        .ALU_wren_INC                       (ALU_wren_INC),

        .ALU_write_addr                     (ALU_write_addr),
        .ALU_write_data                     (ALU_write_data),

        .ALU_write_data_DO                  (ALU_write_data_DO),
        .ALU_write_data_PO                  (ALU_write_data_PO),
        .ALU_write_data_INC                 (ALU_write_data_INC),

        .addr_out                           (addr_out)
    );
endmodule
