
// Memory-mapped wrapper for Address Module: defines locations of indirect and
// shared memories, and memory addresses for indirect memory entry updates.
// (usually in write-only H memory space)

// Writing a PO entry affects the behaviour of the corresponding indirect
// memory location. Writing the DO entry affects the default offset of normal
// memory accesses. The shared memory range is fixed.

`default_nettype none

module Address_Module_Mapped
#(
    // Match to system word width and total address space
    parameter       WRITE_WORD_WIDTH            = 0,
    parameter       WRITE_ADDR_WIDTH            = 0,
    // Offsets are the width of an address operand to enable full offset range
    parameter       ADDR_WIDTH                  = 0,
    // Address ranges (base and bound inclusive)
    parameter       SHARED_ADDR_BASE            = 0,
    parameter       SHARED_ADDR_BOUND           = 0,
    parameter       INDIRECT_ADDR_BASE          = 0,
    parameter       PO_ADDR_BASE                = 0,
    parameter       DO_ADDR                     = 0,
    // Multiple Programmed Offset/Increment per Thread
    parameter       PO_INCR_WIDTH               = 0,
    parameter       PO_ENTRY_COUNT              = 0, // Sets indirect and PO addr bounds
    parameter       PO_ADDR_WIDTH               = 0,
    parameter       PO_INIT_FILE                = "",
    parameter       PO_ENTRY_WIDTH              = ADDR_WIDTH + PO_INCR_WIDTH, // Don't set an instantiation.
    // One Default Offset per Thread
    parameter       DO_INIT_FILE                = "",
    // Common RAM parameters
    parameter       RAMSTYLE                    = "",
    parameter       READ_NEW_DATA               = 0,
    // Multithreading
    parameter       THREAD_COUNT                = 0,
    parameter       THREAD_COUNT_WIDTH          = 0,
    // Retiming
    parameter       WRITE_RETIME_STAGES         = 0
)
(
    input   wire                                clock,

    // Operand address
    input   wire    [ADDR_WIDTH-1:0]            raw_addr,

    // Don't let internal state self-update if the current instruction ends up
    // cancelled or annulled.
    input   wire                                IO_Ready_current,
    input   wire                                Cancel_current,

    // Disable any writes to PO/DO memories from previous instruction if it
    // was annulled or cancelled.
    input   wire                                IO_Ready_previous,
    input   wire                                Cancel_previous,

    // External write port for previous instruction to update Programmed or
    // Default Offset
    input   wire    [WRITE_ADDR_WIDTH-1:0]      write_addr,
    input   wire    [WRITE_WORD_WIDTH-1:0]      write_data,

    output  wire    [ADDR_WIDTH-1:0]            offset_addr
);

// --------------------------------------------------------------------

    // 0-based addresses, hence -1

    localparam PO_ADDR_BOUND        = PO_ADDR_BASE       + PO_ENTRY_COUNT - 1;
    localparam INDIRECT_ADDR_BOUND  = INDIRECT_ADDR_BASE + PO_ENTRY_COUNT - 1;

// --------------------------------------------------------------------

    wire shared;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ADDR_BASE  (SHARED_ADDR_BASE),
        .ADDR_BOUND (SHARED_ADDR_BOUND)
    )
    ARDS_SHARED
    (
        .enable     (1'b1),
        .addr       (raw_addr),
        .hit        (shared)
    );

// --------------------------------------------------------------------

    wire indirect;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .ADDR_BASE  (INDIRECT_ADDR_BASE),
        .ADDR_BOUND (INDIRECT_ADDR_BOUND)
    )
    ARDS_INDIRECT
    (
        .enable     (1'b1),
        .addr       (raw_addr),
        .hit        (indirect)
    );

// --------------------------------------------------------------------

    wire [WRITE_ADDR_WIDTH-1:0] write_addr_retimed;

    Delay_Line 
    #(
        .DEPTH  (WRITE_RETIME_STAGES), 
        .WIDTH  (WRITE_ADDR_WIDTH)
    ) 
    DL_retime
    (
        .clock  (clock),
        .in     (write_addr),
        .out    (write_addr_retimed)
    );

// --------------------------------------------------------------------

    wire                        po_wren;
    wire [PO_ADDR_WIDTH-1:0]    write_addr_translated;

    Memory_Mapper
    #(
        .ADDR_WIDTH             (WRITE_ADDR_WIDTH),
        .ADDR_BASE              (PO_ADDR_BASE),
        .ADDR_BOUND             (PO_ADDR_BOUND),
        .ADDR_WIDTH_LSB         (PO_ADDR_WIDTH),
        .REGISTERED             (0)

    )
    MM_PO
    (
        .clock                  (1'b0),
        .enable                 (1'b1),
        .addr                   (write_addr_retimed),
        .addr_translated_lsb    (write_addr_translated),
        .addr_valid             (po_wren)
    );

// --------------------------------------------------------------------

    wire do_wren;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (WRITE_ADDR_WIDTH),
        .ADDR_BASE  (DO_ADDR),
        .ADDR_BOUND (DO_ADDR)
    )
    ARDS_DO_WREN
    (
        .enable     (1'b1),
        .addr       (write_addr_retimed),
        .hit        (do_wren)
    );

// --------------------------------------------------------------------

    Address_Module
    #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .PO_INCR_WIDTH          (PO_INCR_WIDTH),
        .PO_ADDR_WIDTH          (PO_ADDR_WIDTH),
        .PO_ENTRY_COUNT         (PO_ENTRY_COUNT),
        .PO_ENTRY_WIDTH         (PO_ENTRY_WIDTH),
        .PO_INIT_FILE           (PO_INIT_FILE),
        .DO_INIT_FILE           (DO_INIT_FILE),
        .RAMSTYLE               (RAMSTYLE),
        .READ_NEW_DATA          (READ_NEW_DATA),
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH) 
    )
    AM
    (
        .clock                  (clock),

        .raw_addr               (raw_addr),
        .shared                 (shared),
        .indirect               (indirect),

        .IO_Ready_current       (IO_Ready_current),
        .Cancel_current         (Cancel_current),

        .IO_Ready_previous      (IO_Ready_previous),
        .Cancel_previous        (Cancel_previous),

        .po_wren                (po_wren),
        .po_write_addr          (write_addr_translated),
        .po_write_data          (write_data[PO_ENTRY_WIDTH-1:0]),

        .do_wren                (do_wren),
        .do_write_data          (write_data[ADDR_WIDTH-1:0]),

        .offset_addr            (offset_addr)
    );

endmodule

