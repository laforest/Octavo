
// Programmable Offsets and Increments (PO/PI) Memory for the Address Offset
// Module. This memory internally self-increments when we access an indirect
// memory location. We can also externally write to update a PO entry, with
// priority over the self-increment.

`default_nettype none

module Address_Offset_Module_PO_Memory
#(
    // Offsets are address-wide to reach all memory
    parameter       ADDR_WIDTH                  = 0,
    // Multiple Programmed Offset/Increment per Thread
    parameter       PO_INCR_WIDTH               = 0,
    parameter       PO_ADDR_WIDTH               = 0,
    parameter       PO_ENTRY_COUNT              = 0,
    parameter       PO_ENTRY_WIDTH              = 0,
    parameter       PO_INIT_FILE                = "",
    // Common RAM parameters
    parameter       RAMSTYLE                    = "",
    parameter       READ_NEW_DATA               = 0,
    // Multithreading
    parameter       THREAD_COUNT                = 0,
    parameter       THREAD_COUNT_WIDTH          = 0
)
(
    input   wire                                clock,
    input   wire    [THREAD_COUNT_WIDTH-1:0]    read_thread,
    input   wire    [THREAD_COUNT_WIDTH-1:0]    write_thread,
    input   wire    [ADDR_WIDTH-1:0]            raw_addr,
    input   wire                                abort,
    // External write port 
    input   wire                                po_wren,
    input   wire    [PO_ADDR_WIDTH-1:0]         po_write_addr,
    input   wire    [PO_ENTRY_WIDTH-1:0]        po_write_data,
    // Raw address was indirect memory, and accessed, so enable self-increment
    input   wire                                po_increment,
    output  reg     [ADDR_WIDTH-1:0]            programmed_offset
);

// ---------------------------------------------------------------------

    initial begin
        programmed_offset = 0;
    end

    localparam PO_MEM_ADDR_WIDTH = PO_ADDR_WIDTH  + THREAD_COUNT_WIDTH;
    localparam PO_MEM_DEPTH      = PO_ENTRY_COUNT * THREAD_COUNT;

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 0

// ---------------------------------------------------------------------
// Read PO/PI entry based on raw address LSBs and read thread.

    reg [PO_ADDR_WIDTH-1:0]     po_mem_read_addr_base   = 0;
    reg [PO_MEM_ADDR_WIDTH-1:0] po_mem_read_addr        = 0;

    always @(*) begin
        po_mem_read_addr_base   = raw_addr[PO_ADDR_WIDTH-1:0];
        po_mem_read_addr        = {read_thread, po_mem_read_addr_base};
    end

// ---------------------------------------------------------------------
// Pass the read address back as the internal write address for self-increment
// Make sure it arrives one clock cycle before the same thread reads again so
// that thread gets the updated value.

    wire [PO_ADDR_WIDTH-1:0] po_int_write_addr;

    Delay_Line 
    #(
        .DEPTH  (THREAD_COUNT-1),
        .WIDTH  (PO_ADDR_WIDTH)
    ) 
    INT_WRITE_ADDR
    (
        .clock   (clock),
        .in      (po_mem_read_addr_base),
        .out     (po_int_write_addr)
    );

// Do the same for the self-incremented entry itself, delayed by one less
// cycle since it's generated one cycle later

    reg  [PO_ENTRY_WIDTH-1:0]    new_po_entry       = 0;
    wire [PO_ENTRY_WIDTH-1:0]    po_int_write_data;

    Delay_Line 
    #(
        .DEPTH  (THREAD_COUNT-2),
        .WIDTH  (PO_ENTRY_WIDTH)
    ) 
    INT_WRITE_DATA
    (
        .clock   (clock),
        .in      (new_po_entry),
        .out     (po_int_write_data)
    );

// ---------------------------------------------------------------------
// Signals for write arbitration

    // External writes updating a PO/PI entry
    // Internal writes post-incrementing a PO/PI entry
    wire                            po_ext_wren;
    wire                            po_int_wren;

    // Final arbtrated values to PO memory
    reg                             po_mem_wren         = 0;
    wire    [PO_ENTRY_WIDTH-1:0]    po_mem_write_data;
    wire    [PO_ADDR_WIDTH-1:0]     po_mem_write_addr_base;
    reg     [PO_MEM_ADDR_WIDTH-1:0] po_mem_write_addr   = 0;

// ---------------------------------------------------------------------
// External writes have priority over internal writes, which means
// be careful not to prevent an internal write to another entry.

    localparam PO_WRITE_SOURCE_COUNT = 2;

    Priority_Arbiter
    #(
        .WORD_WIDTH     (PO_WRITE_SOURCE_COUNT)
    )
    PO_WREN_SELECT
    (
        .requests       ({po_increment, po_wren}),
        .grant          ({po_int_wren,  po_ext_wren})
    );

    // Don't self-increment if the instruction was aborted,
    // but let an external update through.
    always @(*) begin
        po_mem_wren = (po_int_wren == 1'b1) & (abort == 1'b0);
        po_mem_wren = (po_mem_wren == 1'b1) | (po_ext_wren == 1'b1);
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

    always @(*) begin
        po_mem_write_addr <= {write_thread, po_mem_write_addr_base};
    end

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

    wire    [PO_ENTRY_WIDTH-1:0]    po_mem_read_data;

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
// ---------------------------------------------------------------------
// Stage 1

// ---------------------------------------------------------------------
// Post-increment Programmed Offset (po)
// Programmed Increment (pi) is in signed-magnitude representation (for range symmetry)

    reg [ADDR_WIDTH-1:0]        po_raw          = 0;
    reg [ADDR_WIDTH-1:0]        po_post_inc     = 0;
    reg                         pi_sign         = 0;
    reg [PO_INCR_WIDTH-2:0]     pi              = 0;

    always @(*) begin
        {po_raw, pi_sign, pi}   = po_mem_read_data;
        po_post_inc             = (pi_sign == 1'b0) ? (po_raw + pi) : (po_raw - pi);
        new_po_entry            = {po_post_inc, pi_sign, pi};
    end

    always @(posedge clock) begin
        programmed_offset <= po_raw;
    end

endmodule

