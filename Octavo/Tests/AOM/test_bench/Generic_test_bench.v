
module Generic_test_bench
#(
   // Offsets are address-wide to enable full offset range
    parameter       ADDR_WIDTH              = 12,
    // Multiple Programmed Offset/Increment per Thread
    parameter       PO_INCR_WIDTH           = 5,
    parameter       PO_ADDR_WIDTH           = 2,
    parameter       PO_ENTRY_COUNT          = 2**PO_ADDR_WIDTH,
    parameter       PO_ENTRY_WIDTH          = ADDR_WIDTH + PO_INCR_WIDTH,
    parameter       PO_INIT_FILE            = "empty.mem",
    // One Default Offset per Thread
    parameter       DO_INIT_FILE            = "empty.mem",
    // Common RAM parameters
    parameter       RAMSTYLE                = "MLAB,no_rw_check",
    parameter       READ_NEW_DATA           = 0,
    // Multithreading
    parameter       THREAD_COUNT            = 8,
    parameter       THREAD_COUNT_WIDTH      = 3
)
(
    // No ports
);

// --------------------------------------------------------------------

    integer                     cycle           = 0;
    reg                         clock           = 0;

    reg  [ADDR_WIDTH-1:0]       raw_addr        = 0;  
    reg                         shared          = 0;       
    reg                         indirect        = 0;
    reg                         abort           = 0;
    reg                         po_wren         = 0;
    reg  [PO_ADDR_WIDTH-1:0]    po_write_addr   = 0;
    reg  [PO_ENTRY_WIDTH-1:0]   po_write_data   = 0;
    reg                         do_wren         = 0;
    reg  [ADDR_WIDTH-1:0]       do_write_data   = 0;
    wire [ADDR_WIDTH-1:0]       offset_addr;

// --------------------------------------------------------------------
// Clock and cycle count generation

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

// --------------------------------------------------------------------
// Test signals 

    always @(posedge clock) begin
        // First, let's create some PO/DO entries
        po_wren         = 1;
        po_write_addr   = 0;
        po_write_data   = {12'd10,1'b1,4'd3}; // Add 10, and post-incr.
        do_wren         = 1;
        do_write_data   = 12'd5;         // Add 5 by default 
        `WAIT_CYCLES(1)
        // Only set for 1 thread. Others will be zeroed out.
        po_wren         = 0;
        po_write_addr   = 0;
        po_write_data   = {12'd0,1'b0,4'd0};
        do_wren         = 0;
        do_write_data   = 12'd0;
        `WAIT_CYCLES(1)
        // Some address whose status changes over time
        raw_addr        = 12'd60;
        `WAIT_CYCLES(32)
        shared          = 1;
        `WAIT_CYCLES(32)
        shared          = 0;
        indirect        = 1;
        `WAIT_CYCLES(32)
        abort           = 1;
        `WAIT_CYCLES(32)
        // Reset the loop
        indirect        = 0;
        abort           = 0;
        `WAIT_CYCLES(1)
        $finish;
    end

// --------------------------------------------------------------------
// DUT goes here

    Address_Offset_Module
    #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .PO_INCR_WIDTH          (PO_INCR_WIDTH),
        .PO_ENTRY_COUNT         (PO_ENTRY_COUNT),
        .PO_ENTRY_WIDTH         (PO_ENTRY_WIDTH),
        .PO_ADDR_WIDTH          (PO_ADDR_WIDTH),
        .PO_INIT_FILE           (PO_INIT_FILE),
        .DO_INIT_FILE           (DO_INIT_FILE),
        .RAMSTYLE               (RAMSTYLE),
        .READ_NEW_DATA          (READ_NEW_DATA),
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH) 
    )
    DUT
    (
        .clock                  (clock),

        .raw_addr               (raw_addr),
        .shared                 (shared),
        .indirect               (indirect),
        .abort                  (abort),

        .po_wren                (po_wren),
        .po_write_addr          (po_write_addr),
        .po_write_data          (po_write_data),

        .do_wren                (do_wren),
        .do_write_data          (do_write_data),

        .offset_addr            (offset_addr)
    );

endmodule

