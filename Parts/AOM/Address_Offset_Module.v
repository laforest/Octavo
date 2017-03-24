
// Address Offset Module: adds an offset to an instruction operand, depending
// on the thread, and whether the memory is shared or indirect.

`default_nettype none

module Address_Offset_Module
#(
    // Offsets are address-wide to enable full offset range
    parameter       ADDR_WIDTH              = 0,
    // Multiple Programmed Offset/Increment per Thread
    parameter       PO_INCR_WIDTH           = 0,
    parameter       PO_ADDR_WIDTH           = 0,
    parameter       PO_ENTRY_COUNT          = 0,
    parameter       PO_ENTRY_WIDTH          = 0,
    parameter       PO_INIT_FILE            = "",
    // One Default Offset per Thread
    parameter       DO_INIT_FILE            = "",
    // Common RAM parameters
    parameter       RAMSTYLE                = "",
    parameter       READ_NEW_DATA           = 0,
    // Multithreading
    parameter       THREAD_COUNT            = 0,
    parameter       THREAD_COUNT_WIDTH      = 0
)
(
    input   wire                            clock,

    // Operand address, and type of memory based on external memory decoders
    input   wire    [ADDR_WIDTH-1:0]        raw_addr,
    input   wire                            shared,
    input   wire                            indirect,

    // Don't let internal state self-update if the instruction ends up
    // cancelled or annulled.
    input   wire                            abort,

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
// If raw address is an indirect memory address, then delay the indirect
// signal to act as write enable for the post-incrementing of that PO entry
// Arrive one cycle early for next thread (see write thread below)

    wire po_increment;

    Delay_Line 
    #(
        .DEPTH  (THREAD_COUNT-1),
        .WIDTH  (1)
    ) 
    POST_INC_WREN
    (
        .clock   (clock),
        .in      (indirect),
        .out     (po_increment)
    );

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 0

    wire [THREAD_COUNT_WIDTH-1:0] read_thread;
    wire [THREAD_COUNT_WIDTH-1:0] write_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID_READ
    (
        .clock              (clock),
        .current_thread     (read_thread),
        .next_thread        ()
    );

// Write back for next thread at the same time as the current thread read, so
// when the next thread reads in the next cycle, the new data is already
// there.

    Thread_Number
    #(
        .INITIAL_THREAD     (1),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID_WRITE
    (
        .clock              (clock),
        .current_thread     (write_thread),
        .next_thread        ()
    );

// ---------------------------------------------------------------------
// Programmed Offsets

    wire [ADDR_WIDTH-1:0] programmed_offset;

    Address_Offset_Module_PO_Memory
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PO_INCR_WIDTH      (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT     (PO_ENTRY_COUNT),
        .PO_ENTRY_WIDTH     (PO_ENTRY_WIDTH),
        .PO_ADDR_WIDTH      (PO_ADDR_WIDTH),
        .PO_INIT_FILE       (PO_INIT_FILE),
        .RAMSTYLE           (RAMSTYLE),
        .READ_NEW_DATA      (READ_NEW_DATA),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    PO_MEM
    (
        .clock              (clock),
        .read_thread        (read_thread),
        .write_thread       (write_thread),
        .raw_addr           (raw_addr),
        .abort              (abort),
        .po_wren            (po_wren),
        .po_write_addr      (po_write_addr),
        .po_write_data      (po_write_data),
        .po_increment       (po_increment),
        .programmed_offset  (programmed_offset)
    );

// ---------------------------------------------------------------------
// Default Offsets

    localparam DO_MEM_ADDR_WIDTH = THREAD_COUNT_WIDTH;
    localparam DO_MEM_DEPTH      = THREAD_COUNT;

    wire [ADDR_WIDTH-1:0] default_offset;

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
        .write_addr     (write_thread),
        .write_data     (do_write_data),
        .rden           (1'b1),
        .read_addr      (read_thread),
        .read_data      (default_offset)
    );

// ---------------------------------------------------------------------
// Sync address and signals to PO/DO memory outputs

    reg [ADDR_WIDTH-1:0]    raw_addr_stage1 = 0;
    reg                     shared_stage1   = 0;
    reg                     indirect_stage1 = 0;

    always @(posedge clock) begin
        raw_addr_stage1 <= raw_addr;
        shared_stage1   <= shared;
        indirect_stage1 <= indirect;
    end

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 1

// Apply offset to address

    localparam ZERO_OFFSET = {ADDR_WIDTH{1'b0}};

    reg [ADDR_WIDTH-1:0] do_or_zero     = 0;
    reg [ADDR_WIDTH-1:0] final_offset   = 0;

    // Apply a programmed offset   (indirect memory, per thread),
    // else apply a zero offset    (shared   memory, across threads), 
    // else apply a default offset (direct   memory, per thread) 
    always @(*) begin
        do_or_zero      = (shared_stage1   == 1'b1) ? ZERO_OFFSET       : default_offset;
        final_offset    = (indirect_stage1 == 1'b1) ? programmed_offset : do_or_zero;
    end

    always @(posedge clock) begin
        offset_addr <= raw_addr_stage1 + final_offset;
    end

endmodule

