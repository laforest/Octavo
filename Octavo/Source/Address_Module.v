
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
    // Base address for later translation to 0-based index
    parameter       INDIRECT_ADDR_BASE      = 0,
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
// The signals from the previous thread instruction arrive at the right
// point in the pipeline to coincide with the signals from the current
// thread instruction. However, we are updating internal state both using
// the previous thread instruction signals and the output of the module.
// Thus, delay the previous thread instruction signals to synchronize them
// with the output of the module, and adjust the write thread number as
// required.

// NOTE: There are redundant signals here, but the CAD tool will deduplicate
// and retime as necessary. And if it becomes necessary to logically partition
// the netlist to avoid these optimizations, then the redundancy will
// re-appear and grant the necessary register and logic duplication to improve
// timing.

    wire                            IO_Ready_previous_sync;
    wire                            Cancel_previous_sync;

    wire                            po_wren_sync;
    wire    [PO_ADDR_WIDTH-1:0]     po_write_addr_sync;
    wire    [PO_ENTRY_WIDTH-1:0]    po_write_data_sync;

    wire                            do_wren_sync;
    wire    [ADDR_WIDTH-1:0]        do_write_data_sync;

    Delay_Line 
    #(
        .DEPTH  (MODULE_PIPE_DEPTH),
        .WIDTH  (1+1+1+PO_ADDR_WIDTH+PO_ENTRY_WIDTH+1+ADDR_WIDTH)
    ) 
    SYNC_PREV_TO_OUTPUT
    (
        .clock   (clock),
        .in      ({IO_Ready_previous,      Cancel_previous,      po_wren,      po_write_addr,      po_write_data,      do_wren,      do_write_data}),
        .out     ({IO_Ready_previous_sync, Cancel_previous_sync, po_wren_sync, po_write_addr_sync, po_write_data_sync, do_wren_sync, do_write_data_sync})
    );

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
    wire [THREAD_COUNT_WIDTH-1:0] write_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (2),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID_READ
    (
        .clock              (clock),
        .current_thread     (read_thread),
        // verilator lint_off PINCONNECTEMPTY
        .next_thread        ()
        // verilator lint_on  PINCONNECTEMPTY
    );

// For PO, since it must be sync'ed to the output and both internal and
// external writes which may conflict, delay write thread number by the depth
// of the Address_Module, so we write back to the same post-incremented offset
// we are currently reading. (The value is the delay subtracted from read
// thread number, modulo the number of threads) For DO, this is redundant, but
// we sync'ed its signals alongside PO so everything looks the same. This
// approach also removes the need for two different write thread numbers.

// Also doing a separate thread number counter uses fewer registers and less
// routing than simply pipelining the thread number along.

    Thread_Number
    #(
        .INITIAL_THREAD     (2 - MODULE_PIPE_DEPTH),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID_WRITE
    (
        .clock              (clock),
        .current_thread     (write_thread),
        // verilator lint_off PINCONNECTEMPTY
        .next_thread        ()
        // verilator lint_on  PINCONNECTEMPTY
    );

// ---------------------------------------------------------------------
// Programmed Offsets

    wire [ADDR_WIDTH-1:0]   programmed_offset;
    reg                     po_incr_enable        = 0;

    Address_Module_PO_Memory
    #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .PO_INCR_WIDTH          (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT         (PO_ENTRY_COUNT),
        .PO_ENTRY_WIDTH         (PO_ENTRY_WIDTH),
        .PO_ADDR_WIDTH          (PO_ADDR_WIDTH),
        .INDIRECT_ADDR_BASE     (INDIRECT_ADDR_BASE),
        .RAMSTYLE               (RAMSTYLE),
        .READ_NEW_DATA          (READ_NEW_DATA),
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH)
    )
    PO_MEM
    (
        .clock                  (clock),
        .read_thread            (read_thread),
        .write_thread           (write_thread),
        .raw_addr               (raw_addr),
        .IO_Ready_current       (IO_Ready_current),
        .Cancel_current         (Cancel_current),
        .IO_Ready_previous      (IO_Ready_previous_sync),
        .Cancel_previous        (Cancel_previous_sync),
        .po_wren                (po_wren_sync),
        .po_write_addr          (po_write_addr_sync),
        .po_write_data          (po_write_data_sync),
        .po_incr_enable         (po_incr_enable),
        .programmed_offset      (programmed_offset)
    );

// ---------------------------------------------------------------------
// Don't update the Default Offset if the previous instruction, possibly
// writing to DO, was Cancelled or Annulled.

    reg do_wren_local = 0;

    always @(*) begin
        do_wren_local = do_wren_sync & (IO_Ready_previous_sync == 1'b1) & (Cancel_previous_sync == 1'b0);
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
        .write_addr     (write_thread),
        .write_data     (do_write_data_sync),
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

