
// Adds a default or programmed per-thread offset to addresses to make shared
// code access per-thread private data. This includes the shared I/O and
// high-mem areas. Programmed offsets provide indirection with
// post-incrementing addressing.

module Addressing
#(
    parameter   WORD_WIDTH                                      = 0,
    parameter   ADDR_WIDTH                                      = 0,
    parameter   D_OPERAND_WIDTH                                 = 0,

    parameter   INITIAL_THREAD                                  = 0,
    parameter   THREAD_COUNT                                    = 0,
    parameter   THREAD_ADDR_WIDTH                               = 0,

    parameter   DEFAULT_OFFSET_WORD_WIDTH                       = 0,
    parameter   DEFAULT_OFFSET_ADDR_WIDTH                       = 0,
    parameter   DEFAULT_OFFSET_DEPTH                            = 0,
    parameter   DEFAULT_OFFSET_RAMSTYLE                         = 0,
    parameter   DEFAULT_OFFSET_INIT_FILE                        = 0,

    parameter   PO_INC_COUNT                                    = 0,
    parameter   PO_INC_COUNT_ADDR_WIDTH                         = 0,

    parameter   PROGRAMMED_OFFSETS_WORD_WIDTH                   = 0,
    parameter   PROGRAMMED_OFFSETS_ADDR_WIDTH                   = 0,
    parameter   PROGRAMMED_OFFSETS_DEPTH                        = 0,
    parameter   PROGRAMMED_OFFSETS_RAMSTYLE                     = 0,
    parameter   PROGRAMMED_OFFSETS_INIT_FILE                    = 0,

    parameter   INCREMENTS_WORD_WIDTH                           = 0,
    parameter   INCREMENTS_ADDR_WIDTH                           = 0,
    parameter   INCREMENTS_DEPTH                                = 0,
    parameter   INCREMENTS_RAMSTYLE                             = 0,
    parameter   INCREMENTS_INIT_FILE                            = 0
)
(
    input   wire                                                clock,

    input   wire    [ADDR_WIDTH-1:0]                            addr_in,            // from stage 1

    input   wire    [PO_INC_COUNT_ADDR_WIDTH-1:0]               PO_INC_index,       // addr_in LSB translated for consecutive internal addressing.
    input   wire                                                indirect_memory,
    input   wire                                                shared_hardware_memory,

    input   wire                                                IO_ready,           // from stage 3

    // Generate these combinationaly from the ALU D output
    input   wire                                                ALU_wren_DO,
    input   wire    [PO_INC_COUNT-1:0]                          ALU_wren_PO,
    input   wire    [PO_INC_COUNT-1:0]                          ALU_wren_INC,

    input   wire    [D_OPERAND_WIDTH-1:0]                       ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]                            ALU_write_data,

    // Subsets of above, so we can align multiple memories along a single word.
    // We want to keep all memory map knowledge in the encapsulating module.
    input   wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]             ALU_write_data_DO,
    input   wire    [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]         ALU_write_data_PO,
    input   wire    [INCREMENTS_WORD_WIDTH-1:0]                 ALU_write_data_INC,

    output  wire    [ADDR_WIDTH-1:0]                            addr_out            // from stage 3, to stage 4 (the Memory subsystem)
);

// -----------------------------------------------------------

    wire                                            ALU_wren_DO_synced;
    wire    [PO_INC_COUNT-1:0]                      ALU_wren_PO_synced;
    wire    [PO_INC_COUNT-1:0]                      ALU_wren_INC_synced;

    wire    [D_OPERAND_WIDTH-1:0]                   ALU_write_addr_synced;
    wire    [WORD_WIDTH-1:0]                        ALU_write_data_synced;

    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]         ALU_write_data_DO_synced;
    wire    [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]     ALU_write_data_PO_synced;
    wire    [INCREMENTS_WORD_WIDTH-1:0]             ALU_write_data_INC_synced;

    // This looks horribly redundant, and it is, but the alternative uses
    // parameters to offset the write data into each field, rather than just
    // doing that higher up, leaking memory map info into this module.
    // Also, the CAD tool will deduplicate equivalent pipeline stages.

    Write_Synchronize
    #(
        .PIPE_DEPTH                     (2),

        .WORD_WIDTH                     (WORD_WIDTH),
        .ADDR_WIDTH                     (D_OPERAND_WIDTH),

        .PO_INC_COUNT                   (PO_INC_COUNT),

        .DEFAULT_OFFSET_WORD_WIDTH      (DEFAULT_OFFSET_WORD_WIDTH),
        .PROGRAMMED_OFFSETS_WORD_WIDTH  (PROGRAMMED_OFFSETS_WORD_WIDTH),
        .INCREMENTS_WORD_WIDTH          (INCREMENTS_WORD_WIDTH)
    )
    Thread6to4
    (
        .clock                      (clock),

        .ALU_wren_DO                (ALU_wren_DO),
        .ALU_wren_PO                (ALU_wren_PO),
        .ALU_wren_INC               (ALU_wren_INC),

        .ALU_write_addr             (ALU_write_addr),
        .ALU_write_data             (ALU_write_data),

        .ALU_write_data_DO          (ALU_write_data_DO),
        .ALU_write_data_PO          (ALU_write_data_PO),
        .ALU_write_data_INC         (ALU_write_data_INC),

        .ALU_wren_DO_synced         (ALU_wren_DO_synced),
        .ALU_wren_PO_synced         (ALU_wren_PO_synced),
        .ALU_wren_INC_synced        (ALU_wren_INC_synced),

        .ALU_write_addr_synced      (ALU_write_addr_synced),
        .ALU_write_data_synced      (ALU_write_data_synced),

        .ALU_write_data_DO_synced   (ALU_write_data_DO_synced),
        .ALU_write_data_PO_synced   (ALU_write_data_PO_synced),
        .ALU_write_data_INC_synced  (ALU_write_data_INC_synced)
    );

// -----------------------------------------------------------

    // Use for the PO wren signals
    wire    indirect_memory_stage3;

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (1)
    )
    indirect_memory_pipeline
    (
        .clock  (clock),
        .in     (indirect_memory),
        .out    (indirect_memory_stage3)
    );


// -----------------------------------------------------------

    // Carry through around to write, so we can update the incremented PO
    wire    [PO_INC_COUNT_ADDR_WIDTH-1:0]   PO_INC_index_write;

    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (PO_INC_COUNT_ADDR_WIDTH)
    )
    PO_addr_in_write
    (
        .clock  (clock),
        .in     (PO_INC_index),
        .out    (PO_INC_index_write)
    );

// -----------------------------------------------------------

    // Write post-incr value to the same PO module we read from, if any.
    wire    [PO_INC_COUNT-1:0]  local_PO_wren_raw;

    genvar count;
    
    generate
        for(count = 0; count < PO_INC_COUNT; count = count + 1) begin : local_PO_wren_generator
            Address_Decoder
            #(
                .ADDR_COUNT     (1),
                .ADDR_BASE      (count),
                .ADDR_WIDTH     (PO_INC_COUNT_ADDR_WIDTH),
                .REGISTERED     (`FALSE)
            )
            PO_wren_local
            (
                .clock          (clock),
                .addr           (PO_INC_index_write),
                .hit            (local_PO_wren_raw[count])
            );
        end
    endgenerate

// -----------------------------------------------------------

    // No state changes for an annuled instruction (I/O not ready)
    // Same if we didn't read into the mapped PO read address space
    wire    [PO_INC_COUNT-1:0]  local_PO_wren;

    Instruction_Annuller
    #(
        .INSTR_WIDTH    (PO_INC_COUNT)
    )
    post_increment
    (
        .instr_in       (local_PO_wren_raw),
        .annul          (~(IO_ready & indirect_memory_stage3)),
        .instr_out      (local_PO_wren)
    ); 

// -----------------------------------------------------------

    wire    [THREAD_ADDR_WIDTH-1:0] read_thread;
    wire    [THREAD_ADDR_WIDTH-1:0] write_thread;

    Addressing_Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .read_thread        (read_thread),
        .write_thread       (write_thread)
    );

// -----------------------------------------------------------

    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]     default_offset;

    Default_Offset
    #(
        .WORD_WIDTH     (DEFAULT_OFFSET_WORD_WIDTH),
        .ADDR_WIDTH     (DEFAULT_OFFSET_ADDR_WIDTH),
        .DEPTH          (DEFAULT_OFFSET_DEPTH),
        .RAMSTYLE       (DEFAULT_OFFSET_RAMSTYLE),
        .INIT_FILE      (DEFAULT_OFFSET_INIT_FILE) 
    )
    DO
    (
        .clock          (clock),
        .wren           (ALU_wren_DO_synced),
        .write_addr     (ALU_write_addr_synced[DEFAULT_OFFSET_ADDR_WIDTH-1:0]),
        .write_data     (ALU_write_data_DO_synced),
        .read_addr      (read_thread),
        .offset         (default_offset)
    );

// -----------------------------------------------------------

    wire    [ PO_INC_COUNT-1:0]                                     PO_wren;
    wire    [(PO_INC_COUNT * PROGRAMMED_OFFSETS_ADDR_WIDTH)-1:0]    PO_write_addr;
    wire    [(PO_INC_COUNT * PROGRAMMED_OFFSETS_WORD_WIDTH)-1:0]    PO_write_data;
    wire    [(PO_INC_COUNT * PROGRAMMED_OFFSETS_WORD_WIDTH)-1:0]    programmed_offsets;

    Programmed_Offsets
    #(
        .WORD_WIDTH         (PROGRAMMED_OFFSETS_WORD_WIDTH),
        .ADDR_WIDTH         (PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .DEPTH              (PROGRAMMED_OFFSETS_DEPTH),
        .RAMSTYLE           (PROGRAMMED_OFFSETS_RAMSTYLE),
        // ECL XXX No real way to pass a vector of parameters...
        // ECL XXX I could use a generate loop, appending numbers to the filename...ick.
        .INIT_FILE          (PROGRAMMED_OFFSETS_INIT_FILE)
    )
    PO  [PO_INC_COUNT-1:0]
    (
        .clock              (clock),
        .wren               (PO_wren),
        .write_addr         (PO_write_addr),
        .write_data         (PO_write_data),
        .read_addr          (read_thread),
        .offset             (programmed_offsets)
    );

// -----------------------------------------------------------

    wire    [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]    programmed_offset;

    Addressed_Mux
    #(
        .WORD_WIDTH         (PROGRAMMED_OFFSETS_WORD_WIDTH),
        .ADDR_WIDTH         (PO_INC_COUNT_ADDR_WIDTH),
        .INPUT_COUNT        (PO_INC_COUNT),
        .REGISTERED         (`TRUE)
    )
    PO_selector
    (
        .clock          (clock),
        .addr           (PO_INC_index),
        .data_in        (programmed_offsets),
        .data_out       (programmed_offset)
    );

// -----------------------------------------------------------

    wire    [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]     programmed_offset_post_incr;

    Write_Priority
    #(
        .WORD_WIDTH     (PROGRAMMED_OFFSETS_WORD_WIDTH),
        .ADDR_WIDTH     (PROGRAMMED_OFFSETS_ADDR_WIDTH)
    )
    PO_wp [PO_INC_COUNT-1:0]
    (
        .clock              (clock),
        .ALU_wren           (ALU_wren_PO_synced),
        .ALU_write_addr     (ALU_write_addr_synced[PROGRAMMED_OFFSETS_ADDR_WIDTH-1:0]),
        .ALU_write_data     (ALU_write_data_PO_synced),
        .local_wren         (local_PO_wren),
        .local_write_addr   (write_thread),
        .local_write_data   (programmed_offset_post_incr),
        .wren               (PO_wren),
        .write_addr         (PO_write_addr),
        .write_data         (PO_write_data)
    );

// -----------------------------------------------------------

    wire    [(PO_INC_COUNT * INCREMENTS_WORD_WIDTH)-1:0]    increments;

    Increments
    #(
        .WORD_WIDTH     (INCREMENTS_WORD_WIDTH),
        .ADDR_WIDTH     (INCREMENTS_ADDR_WIDTH),
        .DEPTH          (INCREMENTS_DEPTH),
        .RAMSTYLE       (INCREMENTS_RAMSTYLE),
        .INIT_FILE      (INCREMENTS_INIT_FILE)
    )
    INC [PO_INC_COUNT-1:0]
    (
        .clock          (clock),
        .wren           (ALU_wren_INC_synced),
        .write_addr     (ALU_write_addr_synced[INCREMENTS_ADDR_WIDTH-1:0]),
        .write_data     (ALU_write_data_INC_synced),
        .read_addr      (read_thread),
        .increment      (increments)
    );

// -----------------------------------------------------------

    wire    [INCREMENTS_WORD_WIDTH-1:0]    increment;

    Addressed_Mux
    #(
        .WORD_WIDTH         (INCREMENTS_WORD_WIDTH),
        .ADDR_WIDTH         (PO_INC_COUNT_ADDR_WIDTH),
        .INPUT_COUNT        (PO_INC_COUNT),
        .REGISTERED         (`TRUE)
    )
    INC_selector
    (
        .clock          (clock),
        .addr           (PO_INC_index),
        .data_in        (increments),
        .data_out       (increment)
    );

// -----------------------------------------------------------

    Increment_Adder
    #(
        .OFFSET_WORD_WIDTH      (PROGRAMMED_OFFSETS_WORD_WIDTH),
        .INCREMENT_WORD_WIDTH   (INCREMENTS_WORD_WIDTH)
    )
    INC_ADD
    (
        .clock          (clock),
        .offset_in      (programmed_offset),
        .increment      (increment),
        .offset_out     (programmed_offset_post_incr)
    );

// -----------------------------------------------------------

    // output default offset, unless we access shared hardware, then output 0
    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]    default_offset_final;

    Addressed_Mux
    #(
        .WORD_WIDTH     (DEFAULT_OFFSET_WORD_WIDTH),
        .ADDR_WIDTH     (1),
        .INPUT_COUNT    (2),
        .REGISTERED     (`FALSE)
    )
    default_offset_selector
    (
        .clock          (clock),
        .addr           (shared_hardware_memory),
        .data_in        ({{DEFAULT_OFFSET_WORD_WIDTH{`LOW}}, default_offset}),
        .data_out       (default_offset_final)
    );

// -----------------------------------------------------------

    // ECL XXX Not that default and programmed should ever differ in width.
    // If we access indirect memory, then override default offset with programmed offset
    // This causes odd cases if indirect memory overlaps shared hardware like I/O ports.
    // Usable, but think twice about it first.
    // if PO/INC are 0, I/O works as usual, else gets redirected to RAM, incl. other I/O port!)
    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]    final_offset;

    Addressed_Mux
    #(
        .WORD_WIDTH     (DEFAULT_OFFSET_WORD_WIDTH),
        .ADDR_WIDTH     (1),
        .INPUT_COUNT    (2),
        .REGISTERED     (`TRUE)
    )
    PO_DO_selector
    (
        .clock          (clock),
        .addr           (indirect_memory),
        .data_in        ({programmed_offset, default_offset_final}),
        .data_out       (final_offset)
    );

// -----------------------------------------------------------

    // And it all boils down to this.

    Address_Adder
    #(
        .WORD_WIDTH (ADDR_WIDTH)
    )
    Address_Adder
    (
        .clock      (clock),
        .addr_in    (addr_in),
        .offset     (final_offset),
        .addr_out   (addr_out)
    );
endmodule

