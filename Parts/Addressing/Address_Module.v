
// Address Module: adds an offset to an instruction operand, depending
// on the thread, and whether the memory is shared or indirect.

`default_nettype none

module Address_Module
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

    // Don't let internal state self-update if the current instruction ends up
    // cancelled or annulled.
    input   wire                            IO_Ready_current,
    input   wire                            Cancel_current,

    // Disable any writes to PO/DO memories from previous instruction if it
    // was annulled or cancelled.
    input   wire                            IO_Ready_previous,
    input   wire                            Cancel_previous,

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

    // Stages from input to output
    localparam MODULE_PIPE_DEPTH = 2;

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 0

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

    wire [THREAD_COUNT_WIDTH-1:0] read_thread;
    wire [THREAD_COUNT_WIDTH-1:0] write_thread_current;
    wire [THREAD_COUNT_WIDTH-1:0] write_thread_previous;

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

// Since this Stage 0 is exactly THREAD_COUNT pipeline stages behind the ALU
// output, the read thread number of the current instruction and the write
// thread number of the instruction doing the write coincide (and is thus the
// previous thread instruction), so we don't need a separate thread number
// counter.

    always @(*) begin
        write_thread_previous <= read_thread;
    end

// Delay write thread number by the depth of the Address_Module, so we write
// back to the same post-incremented offset we are currently reading.  (The
// value is the delay subtracted from read thread number, modulo the number of
// threads)

    Thread_Number
    #(
        .INITIAL_THREAD     (THREAD_COUNT - MODULE_PIPE_DEPTH),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID_WRITE
    (
        .clock              (clock),
        .current_thread     (write_thread_current),
        .next_thread        ()
    );

// ---------------------------------------------------------------------
// Programmed Offsets

    wire [ADDR_WIDTH-1:0]   programmed_offset;
    reg                     po_incr_enable        = 0;

    Address_Offset_Module_PO_Memory
    #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .PO_INCR_WIDTH          (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT         (PO_ENTRY_COUNT),
        .PO_ENTRY_WIDTH         (PO_ENTRY_WIDTH),
        .PO_ADDR_WIDTH          (PO_ADDR_WIDTH),
        .PO_INIT_FILE           (PO_INIT_FILE),
        .RAMSTYLE               (RAMSTYLE),
        .READ_NEW_DATA          (READ_NEW_DATA),
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH)
    )
    PO_MEM
    (
        .clock                  (clock),
        .read_thread            (read_thread),
        .write_thread_current   (write_thread_current),
        .write_thread_previous  (write_thread_current),
        .raw_addr               (raw_addr),
        .IO_Ready_current       (IO_Ready_current),
        .Cancel_current         (Cancel_current),
        .IO_Ready_previous      (IO_Ready_previous),
        .Cancel_previous        (Cancel_previous),
        .po_wren                (po_wren),
        .po_write_addr          (po_write_addr),
        .po_write_data          (po_write_data),
        .po_incr_enable         (po_incr_enable),
        .programmed_offset      (programmed_offset)
    );

// ---------------------------------------------------------------------
// Don't update the Default Offset if the previous instruction, possibly
// writing to DO, was Cancelled or Annulled.

    reg do_wren_local = 0;

    always @(*) begin
        do_wren_local <= do_wren & (IO_Ready_previous == 1'b1) & (Cancel_previous == 1'b0);
    end

// ---------------------------------------------------------------------
// Default Offsets

    wire [ADDR_WIDTH-1:0] default_offset;

    RAM_SDP 
    #(
        .WORD_WIDTH     (ADDR_WIDTH),
        .ADDR_WIDTH     (THREAD_COUNT_WIDTH),
        .DEPTH          (THREAD_COUNT),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        // Force init file use to simplify setup
        .USE_INIT_FILE  (1),
        .INIT_FILE      (DO_INIT_FILE)
    )
    DO_MEM
    (
        .clock          (clock),
        .wren           (do_wren_local),
        .write_addr     (write_thread_previous),
        .write_data     (do_write_data),
        .rden           (1'b1),
        .read_addr      (read_thread),
        .read_data      (default_offset)
    );

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

// ---------------------------------------------------------------------

// Delay the indirect memory signal to act as a write enable for the
// post-incrementing of that PO entry. Synchronize to the current IO_Ready and
// Cancel signals, which also control write enable.

    always @(posedge clock) begin
        po_incr_enable <= indirect_stage1;
    end

endmodule

