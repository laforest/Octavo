
// Address Offset Module: adds an offset to an instruction operand, depending
// on the thread, and whether the memory is shared or indirect.

module Address_Offset_Module
#(
    parameter       ADDR_WIDTH              = 0,
    parameter       INCR_WIDTH              = 0,
    // Multiple Programmed Offset/Increment per Thread
    parameter       PO_ENTRY_COUNT          = 0,
    parameter       PO_ENTRY_WIDTH          = 0,
    parameter       PO_ADDR_WIDTH           = 0,
    parameter       PO_INIT_FILE            = 0,
    // One Default Offset per Thread
    parameter       DO_INIT_FILE            = 0,
    // Common RAM parameters
    parameter       RAMSTYLE                = "",
    parameter       READ_NEW_DATA           = 0,
    // Multithreading
    parameter       THREAD_COUNT            = 0,
    parameter       THREAD_COUNT_WIDTH      = 0
)
(
    input   wire                            clock,

    input   wire    [ADDR_WIDTH-1:0]        raw_addr,
    input   wire                            raw_addr_is_shared_memory,
    input   wire                            raw_addr_is_indirect_memory,

    // Programmed Offset (and Increment) for Indirect Memory
    // External write port to set them up
    input   wire                            po_wren,
    input   wire    [PO_ADDR_WIDTH-1:0]     po_write_addr,
    input   wire    [PO_ENTRY_WIDTH-1:0]    po_write_data,

    // Default Offset for regular memory    
    // External write port to set it up
    input   wire                            do_wren,
    input   wire    [ADDR_WIDTH-1:0]        do_write_data,

    output  reg     [ADDR_WIDTH-1:0]        offset_addr
);

// ---------------------------------------------------------------------

    initial begin
        offset_addr = 0;
    end

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 0

    wire [THREAD_COUNT_WIDTH-1:0] current_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        ()                  // N/C
    );

// ---------------------------------------------------------------------
// Programmed Offsets and Increments

    localparam PO_MEM_ADDR_WIDTH = PO_ADDR_WIDTH  + THREAD_COUNT_WIDTH;
    localparam PO_MEM_DEPTH      = PO_ENTRY_COUNT * THREAD_COUNT;

    // Read PO/PI entry based on raw address and thread
    reg     [PO_MEM_ADDR_WIDTH-1:0] po_mem_read_addr    = 0;
    wire    [PO_ENTRY_WIDTH-1:0]    po_mem_read_data;

    // Final values to PO memory
    reg                             po_mem_wren         = 0;
    wire    [PO_ENTRY_WIDTH-1:0]    po_mem_write_data;
    wire    [PO_ADDR_WIDTH-1:0]     po_mem_write_addr_base;
    reg     [PO_MEM_ADDR_WIDTH-1:0] po_mem_write_addr   = 0;

    // External writes, when code updates a PO/PI entry
    wire                            po_ext_wren;

    // Internal writes, when post-incrementing a PO/PI entry
    wire                            po_int_wren;
    reg     [PO_ENTRY_WIDTH-1:0]    po_int_write_data   = 0;
    reg     [PO_ADDR_WIDTH-1:0]     po_int_write_addr   = 0;

    // Further index addresses by thread
    always @(*) begin
        po_mem_read_addr    <= {current_thread, raw_addr[PO_ADDR_WIDTH-1:0]};
        po_mem_write_addr   <= {current_thread, po_mem_write_addr_base};
    end

// ---------------------------------------------------------------------
// External writes have priority over internal writes, which means
// be careful not to prevent an unrelated internal write.

    reg raw_addr_is_indirect_memory_wren  = 0;

    localparam PO_WRITE_SOURCE_COUNT = 2;

    Priority_Arbiter
    #(
        .WORD_WIDTH     (PO_WRITE_SOURCE_COUNT)
    )
    PO_WREN_SELECT
    (
        .requests       ({raw_addr_is_indirect_memory_wren, po_wren    }),
        .grant          ({po_int_wren,                      po_ext_wren})
    );

    always @(*) begin
        po_mem_wren <= po_int_wren | po_ext_wren;
    end

    One_Hot_Mux
    #(
        .WORD_WIDTH     (PO_ADDR_WIDTH),
        .WORD_COUNT     (PO_WRITE_SOURCE_COUNT)
    )
    PO_WRITE_ADDR_SELECT
    (
        .selectors      ({po_int_wren,       po_ext_wren}),
        .in             ({po_int_write_addr, po_write_addr}),
        .out            (po_mem_write_addr_base)
    );

    One_Hot_Mux
    #(
        .WORD_WIDTH     (PO_ENTRY_WIDTH),
        .WORD_COUNT     (PO_WRITE_SOURCE_COUNT)
    )
    PO_WRITE_DATA_SELECT
    (
        .selectors      ({po_int_wren,       po_ext_wren}),
        .in             ({po_int_write_data, po_write_data}),
        .out            (po_mem_write_data)
    );

// ---------------------------------------------------------------------

    RAM_SDP 
    #(
        .WORD_WIDTH     (PO_ENTRY_WIDTH),
        .ADDR_WIDTH     (PO_MEM_ADDR_WIDTH),
        .DEPTH          (PO_MEM_DEPTH),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        // Force init file use to simplify setup
        .USE_INIT_FILE  (1),
        .INIT_FILE      (PO_INIT_FILE)
    )
    PO_MEM
    (
        .clock          (clock),
        .wren           (po_mem_wren),
        .write_addr     (po_mem_write_addr),
        .write_data     (po_mem_write_data),
        .rden           (1'b1),
        .read_addr      (po_mem_read_addr),
        .read_data      (po_mem_read_data)
    );

// ---------------------------------------------------------------------
// Default Offsets

    localparam DO_MEM_ADDR_WIDTH = THREAD_COUNT_WIDTH;
    localparam DO_MEM_DEPTH      = THREAD_COUNT;

    reg     [DO_MEM_ADDR_WIDTH-1:0]     do_mem_read_addr    = 0;
    wire    [ADDR_WIDTH-1:0]            do_mem_read_data;
    reg     [DO_MEM_ADDR_WIDTH-1:0]     do_mem_write_addr   = 0;

    always @(*) begin
        do_mem_read_addr  <= current_thread;
        do_mem_write_addr <= current_thread;
    end

    RAM_SDP 
    #(
        .WORD_WIDTH     (ADDR_WIDTH),
        .ADDR_WIDTH     (DO_MEM_ADDR_WIDTH),
        .DEPTH          (DO_MEM_DEPTH),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        // Force init file use to simplify setup
        .USE_INIT_FILE  (1),
        .INIT_FILE      (DO_INIT_FILE)
    )
    DO_MEM
    (
        .clock          (clock),
        .wren           (do_wren),
        .write_addr     (do_mem_write_addr),
        .write_data     (do_write_data),
        .rden           (1'b1),
        .read_addr      (do_mem_read_addr),
        .read_data      (do_mem_read_data)
    );

// ---------------------------------------------------------------------
// Sync address and signals to PO/DO memory outputs

    reg [ADDR_WIDTH-1:0]    raw_addr_stage1                     = 0;
    reg                     raw_addr_is_shared_memory_stage1    = 0;
    reg                     raw_addr_is_indirect_memory_stage1  = 0;

    always @(posedge clock) begin
        raw_addr_stage1                     <= raw_addr;
        raw_addr_is_shared_memory_stage1    <= raw_addr_is_shared_memory;
        raw_addr_is_indirect_memory_stage1  <= raw_addr_is_indirect_memory;
    end

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 1

// ---------------------------------------------------------------------
// Apply offset to address

    localparam ZERO_OFFSET = {ADDR_WIDTH{1'b0}};

    reg [ADDR_WIDTH-1:0]    programmed_offset           = 0;
    reg [INCR_WIDTH-1:0]    programmed_increment_unused = 0;

    always @(*) begin
        {programmed_offset, programmed_increment_unused} = po_mem_read_data;
    end

    reg [ADDR_WIDTH-1:0] default_offset = 0;
    reg [ADDR_WIDTH-1:0] final_offset   = 0;

    // Apply a programmed offset   (indirect memory, per thread),
    // else apply a zero offset    (shared   memory, across threads), 
    // else apply a default offset (direct   memory, per thread) 
    always @(*) begin
        default_offset  = (raw_addr_is_shared_memory_stage1   == 1'b1) ? ZERO_OFFSET       : do_mem_read_data;
        final_offset    = (raw_addr_is_indirect_memory_stage1 == 1'b1) ? programmed_offset : default_offset;
    end

    always @(posedge clock) begin
        offset_addr <= raw_addr_stage1 + final_offset;
    end

// ---------------------------------------------------------------------
// Post-increment Programmed Offset (po)
// Programmed Increment (pi) is in signed-magnitude representation (for range symmetry)

    reg [ADDR_WIDTH-1:0]    po          = 0;
    reg [ADDR_WIDTH-1:0]    po_post_inc = 0;
    reg                     pi_sign     = 0;
    reg [INCR_WIDTH-2:0]    pi          = 0;

    always @(posedge clock) begin
        {po, pi_sign, pi}   = po_mem_read_data;
        po_post_inc         = (pi_sign == 1'b0) ? (po + pi) : (po - pi);
        po_int_write_data   = {po_post_inc, pi_sign, pi};
    end

// ---------------------------------------------------------------------

    always @(posedge clock) begin
        raw_addr_is_indirect_memory_wren <= raw_addr_is_indirect_memory_stage1;
    end

endmodule

