
// Addressing: translates all the instruction address operands as required.
// One Address_Module_Mapped for each of the A/B/DA/DB operands.

// DA/DB write operands share same indirect/shared ranges as A/B read operands
// (plus a shared range for the write-only I and H memories), but have their
// own PO entries. Thus reading and writing an indirect memory location can
// lead to different actual locations.

// All operands have the same number of indirect memory locations.  This
// acknowledges that we can do Double-Moves, so some operations do two writes
// *and* reads, contrary to the common case of 2 source reads for
// 1 destination write in a dyadic operation like addition.

`default_nettype none

module Addressing
#(
    // Match to system word width and total address space
    parameter       WRITE_WORD_WIDTH            = 0,
    parameter       WRITE_ADDR_WIDTH            = 0,
    // Offsets are the width of an address operand to enable full offset range
    parameter       A_ADDR_WIDTH                = 0,
    parameter       B_ADDR_WIDTH                = 0,
    parameter       D_ADDR_WIDTH                = 0,
    // Address ranges (base and bound inclusive)
    parameter       A_SHARED_READ_ADDR_BASE     = 0,
    parameter       A_SHARED_READ_ADDR_BOUND    = 0,
    parameter       A_SHARED_WRITE_ADDR_BASE    = 0,
    parameter       A_SHARED_WRITE_ADDR_BOUND   = 0,
    parameter       B_SHARED_READ_ADDR_BASE     = 0,
    parameter       B_SHARED_READ_ADDR_BOUND    = 0,
    parameter       B_SHARED_WRITE_ADDR_BASE    = 0,
    parameter       B_SHARED_WRITE_ADDR_BOUND   = 0,
    parameter       IH_SHARED_WRITE_ADDR_BASE   = 0,
    parameter       IH_SHARED_WRITE_ADDR_BOUND  = 0,
    parameter       A_INDIRECT_READ_ADDR_BASE   = 0,
    parameter       A_INDIRECT_WRITE_ADDR_BASE  = 0,
    parameter       B_INDIRECT_READ_ADDR_BASE   = 0,
    parameter       B_INDIRECT_WRITE_ADDR_BASE  = 0,
    parameter       A_PO_ADDR_BASE              = 0,
    parameter       B_PO_ADDR_BASE              = 0,
    parameter       DA_PO_ADDR_BASE             = 0,
    parameter       DB_PO_ADDR_BASE             = 0,
    parameter       DO_ADDR                     = 0,
    // Multiple Programmed Offset/Increment per Thread
    parameter       PO_INCR_WIDTH               = 0,
    parameter       PO_ENTRY_COUNT              = 0, // Sets indirect and PO addr bounds
    parameter       PO_ADDR_WIDTH               = 0,
    // Common initial PO entries for all threads
    parameter       PO_INIT_FILE                = "",
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
    input   wire                            clock,

    // Operand address
    input   wire    [A_ADDR_WIDTH-1:0]      A_raw_addr,
    input   wire    [B_ADDR_WIDTH-1:0]      B_raw_addr,
    input   wire    [D_ADDR_WIDTH-1:0]      DA_raw_addr,
    input   wire    [D_ADDR_WIDTH-1:0]      DB_raw_addr,

    // Don't let internal state self-update if the current instruction ends up
    // cancelled or annulled.
    input   wire                            IO_Ready_current,
    input   wire                            Cancel_current,

    // Disable any writes to PO/DO memories from previous instruction if it
    // was annulled or cancelled.
    input   wire                            IO_Ready_previous,
    input   wire                            Cancel_previous,

    // External write port for previous instruction to update Programmed or
    // Default Offset
    input   wire    [WRITE_ADDR_WIDTH-1:0]  write_addr,
    input   wire    [WRITE_WORD_WIDTH-1:0]  write_data,

    output  wire    [A_ADDR_WIDTH-1:0]      A_offset_addr,
    output  wire    [B_ADDR_WIDTH-1:0]      B_offset_addr,
    output  wire    [D_ADDR_WIDTH-1:0]      DA_offset_addr,
    output  wire    [D_ADDR_WIDTH-1:0]      DB_offset_addr
);

// --------------------------------------------------------------------

    Address_Module_Mapped
    #(
        .WRITE_WORD_WIDTH           (WRITE_WORD_WIDTH),
        .WRITE_ADDR_WIDTH           (WRITE_ADDR_WIDTH),
        .ADDR_WIDTH                 (A_ADDR_WIDTH),
        .FIRST_SHARED_ADDR_BASE     (A_SHARED_READ_ADDR_BASE),
        .FIRST_SHARED_ADDR_BOUND    (A_SHARED_READ_ADDR_BOUND),
        .SECOND_SHARED_ADDR_BASE    (0),
        .SECOND_SHARED_ADDR_BOUND   (0),
        .INDIRECT_ADDR_BASE         (A_INDIRECT_READ_ADDR_BASE),
        .PO_ADDR_BASE               (A_PO_ADDR_BASE),
        .DO_ADDR                    (DO_ADDR),
        .PO_INCR_WIDTH              (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT             (PO_ENTRY_COUNT),
        .PO_ADDR_WIDTH              (PO_ADDR_WIDTH),
        .PO_INIT_FILE               (PO_INIT_FILE),
        .DO_INIT_FILE               (DO_INIT_FILE),
        .RAMSTYLE                   (RAMSTYLE),
        .READ_NEW_DATA              (READ_NEW_DATA),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH),
        .WRITE_RETIME_STAGES        (WRITE_RETIME_STAGES)
    )
    AMM_A
    (
        .clock                      (clock),

        .raw_addr                   (A_raw_addr),

        .IO_Ready_current           (IO_Ready_current),
        .Cancel_current             (Cancel_current),

        .IO_Ready_previous          (IO_Ready_previous),
        .Cancel_previous            (Cancel_previous),

        .write_addr                 (write_addr),
        .write_data                 (write_data),

        .offset_addr                (A_offset_addr)
    );

// --------------------------------------------------------------------

    Address_Module_Mapped
    #(
        .WRITE_WORD_WIDTH           (WRITE_WORD_WIDTH),
        .WRITE_ADDR_WIDTH           (WRITE_ADDR_WIDTH),
        .ADDR_WIDTH                 (B_ADDR_WIDTH),
        .FIRST_SHARED_ADDR_BASE     (B_SHARED_READ_ADDR_BASE),
        .FIRST_SHARED_ADDR_BOUND    (B_SHARED_READ_ADDR_BOUND),
        .SECOND_SHARED_ADDR_BASE    (0),
        .SECOND_SHARED_ADDR_BOUND   (0),
        .INDIRECT_ADDR_BASE         (B_INDIRECT_READ_ADDR_BASE),
        .PO_ADDR_BASE               (B_PO_ADDR_BASE),
        .DO_ADDR                    (DO_ADDR),
        .PO_INCR_WIDTH              (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT             (PO_ENTRY_COUNT),
        .PO_ADDR_WIDTH              (PO_ADDR_WIDTH),
        .PO_INIT_FILE               (PO_INIT_FILE),
        .DO_INIT_FILE               (DO_INIT_FILE),
        .RAMSTYLE                   (RAMSTYLE),
        .READ_NEW_DATA              (READ_NEW_DATA),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH),
        .WRITE_RETIME_STAGES        (WRITE_RETIME_STAGES)
    )
    AMM_B
    (
        .clock                      (clock),

        .raw_addr                   (B_raw_addr),

        .IO_Ready_current           (IO_Ready_current),
        .Cancel_current             (Cancel_current),

        .IO_Ready_previous          (IO_Ready_previous),
        .Cancel_previous            (Cancel_previous),

        .write_addr                 (write_addr),
        .write_data                 (write_data),

        .offset_addr                (B_offset_addr)
    );

// --------------------------------------------------------------------

    Address_Module_Mapped
    #(
        .WRITE_WORD_WIDTH           (WRITE_WORD_WIDTH),
        .WRITE_ADDR_WIDTH           (WRITE_ADDR_WIDTH),
        .ADDR_WIDTH                 (D_ADDR_WIDTH),
        .FIRST_SHARED_ADDR_BASE     (A_SHARED_WRITE_ADDR_BASE),
        .FIRST_SHARED_ADDR_BOUND    (A_SHARED_WRITE_ADDR_BOUND),
        .SECOND_SHARED_ADDR_BASE    (IH_SHARED_WRITE_ADDR_BASE),
        .SECOND_SHARED_ADDR_BOUND   (IH_SHARED_WRITE_ADDR_BOUND),
        .INDIRECT_ADDR_BASE         (A_INDIRECT_WRITE_ADDR_BASE),
        .PO_ADDR_BASE               (DA_PO_ADDR_BASE),
        .DO_ADDR                    (DO_ADDR),
        .PO_INCR_WIDTH              (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT             (PO_ENTRY_COUNT),
        .PO_ADDR_WIDTH              (PO_ADDR_WIDTH),
        .PO_INIT_FILE               (PO_INIT_FILE),
        .DO_INIT_FILE               (DO_INIT_FILE),
        .RAMSTYLE                   (RAMSTYLE),
        .READ_NEW_DATA              (READ_NEW_DATA),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH),
        .WRITE_RETIME_STAGES        (WRITE_RETIME_STAGES)
    )
    AMM_DA
    (
        .clock                      (clock),

        .raw_addr                   (DA_raw_addr),

        .IO_Ready_current           (IO_Ready_current),
        .Cancel_current             (Cancel_current),

        .IO_Ready_previous          (IO_Ready_previous),
        .Cancel_previous            (Cancel_previous),

        .write_addr                 (write_addr),
        .write_data                 (write_data),

        .offset_addr                (DA_offset_addr)
    );

// --------------------------------------------------------------------

    Address_Module_Mapped
    #(
        .WRITE_WORD_WIDTH           (WRITE_WORD_WIDTH),
        .WRITE_ADDR_WIDTH           (WRITE_ADDR_WIDTH),
        .ADDR_WIDTH                 (D_ADDR_WIDTH),
        .FIRST_SHARED_ADDR_BASE     (B_SHARED_WRITE_ADDR_BASE),
        .FIRST_SHARED_ADDR_BOUND    (B_SHARED_WRITE_ADDR_BOUND),
        .SECOND_SHARED_ADDR_BASE    (IH_SHARED_WRITE_ADDR_BASE),
        .SECOND_SHARED_ADDR_BOUND   (IH_SHARED_WRITE_ADDR_BOUND),
        .INDIRECT_ADDR_BASE         (B_INDIRECT_WRITE_ADDR_BASE),
        .PO_ADDR_BASE               (DB_PO_ADDR_BASE),
        .DO_ADDR                    (DO_ADDR),
        .PO_INCR_WIDTH              (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT             (PO_ENTRY_COUNT),
        .PO_ADDR_WIDTH              (PO_ADDR_WIDTH),
        .PO_INIT_FILE               (PO_INIT_FILE),
        .DO_INIT_FILE               (DO_INIT_FILE),
        .RAMSTYLE                   (RAMSTYLE),
        .READ_NEW_DATA              (READ_NEW_DATA),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH),
        .WRITE_RETIME_STAGES        (WRITE_RETIME_STAGES)
    )
    AMM_DB
    (
        .clock                      (clock),

        .raw_addr                   (DB_raw_addr),

        .IO_Ready_current           (IO_Ready_current),
        .Cancel_current             (Cancel_current),

        .IO_Ready_previous          (IO_Ready_previous),
        .Cancel_previous            (Cancel_previous),

        .write_addr                 (write_addr),
        .write_data                 (write_data),

        .offset_addr                (DB_offset_addr)
    );

endmodule

