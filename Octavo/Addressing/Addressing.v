
// Adds a default or programmed (at PC LSB match) per-thread offset to
// addresses to make shared code access per-thread private data. This includes
// the shared I/O and high-mem areas. Programmed offsets end basic blocks and
// provide indirection with (+0, +1) post-incrementing addressing.

module Addressing
#(
    parameter   PC_WIDTH                                = 0,
    parameter   WORD_WIDTH                              = 0,
    parameter   ADDR_WIDTH                              = 0,
    parameter   D_OPERAND_WIDTH                         = 0,

    parameter   INITIAL_THREAD                          = 0,
    parameter   THREAD_COUNT                            = 0,
    parameter   THREAD_ADDR_WIDTH                       = 0,

    parameter   BASIC_BLOCK_COUNTER_WORD_WIDTH          = 0,
    parameter   BASIC_BLOCK_COUNTER_ADDR_WIDTH          = 0,
    parameter   BASIC_BLOCK_COUNTER_DEPTH               = 0,
    parameter   BASIC_BLOCK_COUNTER_RAMSTYLE            = 0,
    parameter   BASIC_BLOCK_COUNTER_INIT_FILE           = 0,

    parameter   CONTROL_MEMORY_WORD_WIDTH               = 0,
    parameter   CONTROL_MEMORY_ADDR_WIDTH               = 0,
    parameter   CONTROL_MEMORY_DEPTH                    = 0,
    parameter   CONTROL_MEMORY_RAMSTYLE                 = 0,
    parameter   CONTROL_MEMORY_INIT_FILE                = 0,
    parameter   CONTROL_MEMORY_MATCH_WIDTH              = 0,
    parameter   CONTROL_MEMORY_COND_WIDTH               = 0,
    parameter   CONTROL_MEMORY_LINK_WIDTH               = 0,

    parameter   DEFAULT_OFFSET_WORD_WIDTH               = 0,
    parameter   DEFAULT_OFFSET_ADDR_WIDTH               = 0,
    parameter   DEFAULT_OFFSET_DEPTH                    = 0,
    parameter   DEFAULT_OFFSET_RAMSTYLE                 = 0,
    parameter   DEFAULT_OFFSET_INIT_FILE                = 0,

    parameter   PROGRAMMED_OFFSETS_WORD_WIDTH           = 0,
    parameter   PROGRAMMED_OFFSETS_ADDR_WIDTH           = 0,
    parameter   PROGRAMMED_OFFSETS_DEPTH                = 0,
    parameter   PROGRAMMED_OFFSETS_RAMSTYLE             = 0,
    parameter   PROGRAMMED_OFFSETS_INIT_FILE            = 0,

    parameter   INCREMENTS_OFFSET_WORD_WIDTH            = 0,
    parameter   INCREMENTS_OFFSET_ADDR_WIDTH            = 0,
    parameter   INCREMENTS_OFFSET_DEPTH                 = 0,
    parameter   INCREMENTS_OFFSET_RAMSTYLE              = 0,
    parameter   INCREMENTS_OFFSET_INIT_FILE             = 0
)
(
    input   wire                                            clock,
    input   wire    [PC_WIDTH-1:0]                          PC,        // Right out of ControlPath
    input   wire    [ADDR_WIDTH-1:0]                        addr_in,   // from stage 1

    input   wire                                            IO_ready,  // from stage 3

    // Generate these combinationaly from the ALU D output in DataPath
    input   wire                                            ALU_wren_BBC,
    input   wire                                            ALU_wren_CTL,
    input   wire                                            ALU_wren_DO,
    input   wire                                            ALU_wren_PO,
    input   wire                                            ALU_wren_INC,

    input   wire    [D_OPERAND_WIDTH-1:0]                   ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]                        ALU_write_data,

    // Subsets of above, so we can align multiple Addressing instances along a word in the DataPath.
    input   wire    [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    ALU_write_data_BBC,
    input   wire    [CONTROL_MEMORY_WORD_WIDTH-1:0]         ALU_write_data_CTL,
    input   wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]         ALU_write_data_DO,
    input   wire    [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]     ALU_write_data_PO,
    input   wire    [INCREMENTS_WORD_WIDTH-1:0]             ALU_write_data_INC,

    output  wire    [ADDR_WIDTH-1:0]                        addr_out
);

// -----------------------------------------------------------

    wire    [THREAD_ADDR_WIDTH-1:0] read_thread_BBC;
    wire    [THREAD_ADDR_WIDTH-1:0] read_thread_MEM;
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
        .read_thread_MEM    (read_thread_BBC),
        .read_thread_MEM    (read_thread_MEM),
        .write_thread       (write_thread)
    );

// -----------------------------------------------------------

    wire                                            BBC_wren;
    wire    [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    BBC_write_data;
    wire    [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    block_number;
    wire    [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    block_number_post_incr;

    Basic_Block_Counter
    #(
        .WORD_WIDTH                 (BASIC_BLOCK_COUNTER_WORD_WIDTH),
        .ADDR_WIDTH                 (BASIC_BLOCK_COUNTER_ADDR_WIDTH),
        .DEPTH                      (BASIC_BLOCK_COUNTER_DEPTH),
        .RAMSTYLE                   (BASIC_BLOCK_COUNTER_RAMSTYLE),
        .INIT_FILE                  (BASIC_BLOCK_COUNTER_INIT_FILE)  
    )
    BBC
    (
        .clock                      (clock),
        .wren                       (BBC_wren),
        .write_thread               (write_thread),
        .write_data                 (BBC_write_data),
        .read_thread                (read_thread_BBC),
        .block_number               (block_number),
        .block_number_post_incr     (block_number_post_incr)
    );

// -----------------------------------------------------------

    reg                                             local_wren;
    wire    [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    next_block_number;

    Write_Priority
    #(
        .WORD_WIDTH     (BASIC_BLOCK_COUNTER_WORD_WIDTH)
    )
    BBC
    (
        .clock          (clock),
        .ALU_wren       (ALU_wren_BBC),
        .ALU_data       (ALU_write_data_BBC),
        .local_wren     (local_wren),
        .local_data     (next_block_number),
        .wren_out       (BBC_wren),
        .data_out       (BBC_write_data)
    );

// -----------------------------------------------------------

    wire                                            CTL_wren;
    wire    [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    CTL_write_data;
    wire    [CONTROL_MEMORY_MATCH_WIDTH-1:0]        match;
    wire    [CONTROL_MEMORY_COND_WIDTH-1:0]         cond;
    wire    [CONTROL_MEMORY_LINK_WIDTH-1:0]         link;

    Control_Memory
    #(
        .WORD_WIDTH         (CONTROL_MEMORY_WORD_WIDTH),
        .ADDR_WIDTH         (CONTROL_MEMORY_ADDR_WIDTH),
        .DEPTH              (CONTROL_MEMORY_DEPTH),
        .RAMSTYLE           (CONTROL_MEMORY_RAMSTYLE),
        .INIT_FILE          (CONTROL_MEMORY_INIT_FILE),
        .MATCH_WIDTH        (CONTROL_MEMORY_MATCH_WIDTH),
        .COND_WIDTH         (CONTROL_MEMORY_COND_WIDTH),
        .LINK_WIDTH         (CONTROL_MEMORY_LINK_WIDTH)
    )
    CTL
    (
        .clock              (clock),
        .wren               (CTL_wren),
        .write_thread       (write_thread),
        .write_data         (CTL_write_data),
        .read_thread        (read_thread_MEM),
        .PC_match           (match),
        .branch_condition   (cond),
        .BBC_link           (link)
    );

// -----------------------------------------------------------

    // ECL XXX Note the redundancy here. Without local data writes, this should
    // reduce to the ALU write synchronization pipeline.

    Write_Priority
    #(
        .WORD_WIDTH     (CONTROL_MEMORY_WORD_WIDTH)
    )
    CTL
    (
        .clock          (clock),
        .ALU_wren       (ALU_wren_CTL),
        .ALU_data       (ALU_write_data_CTL),
        .local_wren     (`LOW),
        .local_data     (ALU_write_data_CTL),
        .wren_out       (CTL_wren),
        .data_out       (CTL_write_data)
    );

// -----------------------------------------------------------

    wire    branch_stage_2;
    wire    branch_stage_3;

    Basic_Block_End
    #(
        .WORD_WIDTH         (CONTROL_MEMORY_MATCH_WIDTH)
    )
    BBE
    (
        .clock              (clock),
        .PC_LSB             (PC[CONTROL_MEMORY_MATCH_WIDTH-1:0]),
        .match              (match),
        .block_end_stage_2  (branch_stage_2),
        .block_end_stage_3  (branch_stage_3)
    );

// -----------------------------------------------------------

    // Don't update local state of annulled instruction

    always @(*) begin
        local_wren <= branch_stage_3 & IO_ready;
    end

// -----------------------------------------------------------

    wire    branch_taken;

    module Basic_Block_Flags
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .COND_WIDTH         (CONTROL_MEMORY_COND_WIDTH)
    )
    BBF
    (
        .clock              (clock),
        .R_prev             (ALU_write_data),
        .branch_condition   (cond),
        .basic_block_end    (branch_stage_2),
        .branch_taken       (branch_taken)
    );

// -----------------------------------------------------------

    Addressed_Mux
    #(
        .WORD_WIDTH     (CONTROL_MEMORY_LINK_WIDTH),
        .ADDR_WIDTH     (1),
        .INPUT_COUNT    (2),
        .REGISTERED     (`FALSE)
    )
    BBC_selector
    (
        .clock          (clock),
        .addr           (branch_taken),
        .data_in        ({link, block_number_post_incr}),
        .data_out       (next_block_number)
    );

// -----------------------------------------------------------

    wire                                        DO_wren;
    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]     DO_write_data;
    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]     default_offset;

    Default_Offset
    #(
        .WORD_WIDTH     (DEFAULT_OFFSET_WORD_WIDTH),
        .ADDR_WIDTH     (DEFAULT_OFFSET_ADDR_WIDTH
        .DEPTH          (DEFAULT_OFFSET_DEPTH),
        .RAMSTYLE       (DEFAULT_OFFSET_RAMSTYLE),
        .INIT_FILE      (DEFAULT_OFFSET_INIT_FILE) 
    )
    DO
    (
        .clock          (clock),
        .wren           (DO_wren),
        .write_thread   (write_thread),
        .write_data     (DO_write_data),
        .read_thread    (read_thread_MEM),
        .offset         (default_offset)
    );

// -----------------------------------------------------------

    // ECL XXX Note the redundancy here. Without local data writes, this should
    // reduce to the ALU write synchronization pipeline.

    Write_Priority
    #(
        .WORD_WIDTH     (DEFAULT_OFFSET_WORD_WIDTH)
    )
    DO
    (
        .clock          (clock),
        .ALU_wren       (ALU_wren_DO),
        .ALU_data       (ALU_write_data_DO),
        .local_wren     (`LOW),
        .local_data     (ALU_write_data_DO),
        .wren_out       (DO_wren),
        .data_out       (DO_write_data)
    );


// -----------------------------------------------------------

    Programmed_Offsets
    #(
        .WORD_WIDTH         (PROGRAMMED_OFFSETS_WORD_WIDTH),
        .ADDR_WIDTH         (PROGRAMMED_OFFSETS_ADDR_WIDTH),
        .DEPTH              (PROGRAMMED_OFFSETS_DEPTH),
        .RAMSTYLE           (PROGRAMMED_OFFSETS_RAMSTYLE),
        .INIT_FILE          (PROGRAMEED_OFFSETS_INIT_FILE)
    )
    PO
    (
        .clock              (clock),
        .wren               (PO_wren),
        .write_thread       (write_thread),
        .write_data         (PO_write_data),
        .read_thread        (read_thread_MEM),
        .offset_pre_incr    (programmed_offset_pre_incr),
        .offset_addr_adder  (programmed_offset)
    );

// -----------------------------------------------------------

    wire    [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]     programmed_offset_post_incr;

    Write_Priority
    #(
        .WORD_WIDTH     (PROGRAMMED_OFFSETS_WORD_WIDTH)
    )
    PO
    (
        .clock          (clock),
        .ALU_wren       (ALU_wren_PO),
        .ALU_data       (ALU_write_data_PO),
        .local_wren     (local_wren),
        .local_data     (programmed_offset_post_incr),
        .wren_out       (PO_wren),
        .data_out       (PO_write_data)
    );

// -----------------------------------------------------------

    wire                                    INC_wren;
    wire    [INCREMENTS_WORD_WIDTH-1:0]     INC_write_data;
    wire    [INCREMENTS_WORD_WIDTH-1:0]     increment;

    Increments
    #(
        .WORD_WIDTH     (INCREMENTS_WORD_WIDTH),
        .ADDR_WIDTH     (INCREMENTS_ADDR_WIDTH),
        .DEPTH          (INCREMENTS_DEPTH),
        .RAMSTYLE       (INCREMENTS_RAMSTYLE),
        .INIT_FILE      (INCREMENTS_INIT_FILE)
    )
    INC
    (
        .clock          (clock),
        .wren           (INC_wren),
        .write_thread   (write_thread),
        .write_data     (INC_write_data),
        .read_thread    (read_thread_MEM),
        .increment      (increment)
    );

// -----------------------------------------------------------

    // ECL XXX Note the redundancy here. Without local data writes, this should
    // reduce to the ALU write synchronization pipeline.

    Write_Priority
    #(
        .WORD_WIDTH     (INCREMENTS_WORD_WIDTH)
    )
    INC
    (
        .clock          (clock),
        .ALU_wren       (ALU_wren_INC),
        .ALU_data       (ALU_write_data_INC),
        .local_wren     (`LOW),
        .local_data     (ALU_write_data_INC),
        .wren_out       (INC_wren),
        .data_out       (INC_write_data)
    );

// -----------------------------------------------------------

    Increment_Adder
    #(
        .WORD_WIDTH     (PROGRAMMED_OFFSETS_WORD_WIDTH)
    )
    INC_ADD
    (
        .clock          (clock),
        .offset_in      (programmed_offset_pre_incr),
        .increment      (increment),
        .offset_out     (programmed_offset_post_incr)
    );

// -----------------------------------------------------------

    // ECL XXX Not that default and programmed should ever differ in width.
    wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]    addr_offset;

    Addressed_Mux
    #(
        .WORD_WIDTH     (DEFAULT_OFFSET_WORD_WIDTH),
        .ADDR_WIDTH     (1),
        .INPUT_COUNT    (2),
        .REGISTERED     (`FALSE)
    )
    offset_selector
    (
        .clock          (clock),
        .addr           (branch_stage_2),
        .data_in        ({programmed_offset, default_offset}),
        .data_out       (addr_offset)
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
        .offset     (addr_offset),
        .addr_out   (addr_out)
    );
endmodule

