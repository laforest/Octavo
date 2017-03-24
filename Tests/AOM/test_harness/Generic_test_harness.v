
`default_nettype none

module Generic_test_harness
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
    input   wire    clock,
    input   wire    test_in,
    output  wire    test_out
);

// --------------------------------------------------------------------

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

    localparam INPUT_WIDTH  = ADDR_WIDTH + 1 + 1 + 1 + 1 + PO_ADDR_WIDTH + PO_ENTRY_WIDTH + 1 + ADDR_WIDTH;
    localparam OUTPUT_WIDTH = ADDR_WIDTH;

    wire    [INPUT_WIDTH-1:0]   test_input;
    reg     [OUTPUT_WIDTH-1:0]  test_output;

// --------------------------------------------------------------------

    always @(*) begin
        {raw_addr,shared,indirect,abort,po_wren,po_write_addr,po_write_data,do_wren,do_write_data} <= test_input;
        test_output <= {offset_addr};
    end

// --------------------------------------------------------------------
// Test Harness Registers

    harness_input_register
    #(
        .WIDTH  (INPUT_WIDTH)
    )
    i
    (
        .clock  (clock),    
        .in     (test_in),
        .rden   (1'b1),
        .out    (test_input)
    );

    harness_output_register 
    #(
        .WIDTH  (OUTPUT_WIDTH)
    )
    o
    (
        .clock  (clock),
        .in     (test_output),
        .wren   (1'b1),
        .out    (test_out)
    );

// --------------------------------------------------------------------

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

