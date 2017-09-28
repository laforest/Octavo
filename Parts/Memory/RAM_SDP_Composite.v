
// Simple Dual-Port RAM, implemented as a composite of smaller RAMs.
// Useful for portability reasons, or if the CAD tool infers sub-optimal
// monolitic RAMs.
// The explicit read/write enables might save power.

`default_nettype none

module RAM_SDP_Composite
#(
    // Same parameters as RAM_SDP
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       DEPTH               = 0,
    parameter       RAMSTYLE            = "",
    parameter       READ_NEW_DATA       = 0,
    parameter       USE_INIT_FILE       = 0,
    // Parameters for the individual sub-RAMs
    parameter       SUB_INIT_FILE       = "",
    parameter       SUB_ADDR_WIDTH      = 0,
    parameter       SUB_DEPTH           = 0
)
(
    input  wire                         clock,
    input  wire                         wren,
    input  wire     [ADDR_WIDTH-1:0]    write_addr,
    input  wire     [WORD_WIDTH-1:0]    write_data,
    input  wire                         rden,
    input  wire     [ADDR_WIDTH-1:0]    read_addr, 
    output wire     [WORD_WIDTH-1:0]    read_data
);

// --------------------------------------------------------------------
// Calculate the arrangement of sub-RAMs and their addressing
// We assume 2**N depths, so the address bits and depths divide integrally.
// Width is left to the CAD tool, as it does not require multiplexing.

    localparam SUB_RAM_COUNT  = DEPTH / SUB_DEPTH;
    // MSB selects a sub-RAM, which LSB addresses
    localparam ADDR_WIDTH_MSB = ADDR_WIDTH - SUB_ADDR_WIDTH;
    localparam ADDR_WIDTH_LSB = SUB_ADDR_WIDTH;

    reg [ADDR_WIDTH_MSB-1:0] sub_read_selector  = 0;
    reg [ADDR_WIDTH_LSB-1:0] sub_read_addr      = 0;

    reg [ADDR_WIDTH_MSB-1:0] sub_write_selector = 0;
    reg [ADDR_WIDTH_LSB-1:0] sub_write_addr     = 0;

    always @(*) begin
        sub_read_selector   = read_addr  [ADDR_WIDTH-1:ADDR_WIDTH-ADDR_WIDTH_MSB]; 
        sub_write_selector  = write_addr [ADDR_WIDTH-1:ADDR_WIDTH-ADDR_WIDTH_MSB]; 
        sub_read_addr       = read_addr  [ADDR_WIDTH_LSB-1:0];
        sub_write_addr      = write_addr [ADDR_WIDTH_LSB-1:0];
    end

// --------------------------------------------------------------------
// Enable reads and writes to each sub-RAM based on selectors.

    wire [SUB_RAM_COUNT-1:0] sub_wren;
    wire [SUB_RAM_COUNT-1:0] sub_rden;

    generate
        genvar i;
        for(i = 0; i < SUB_RAM_COUNT; i = i+1) begin : enables

            Address_Range_Decoder_Static
            #(
                .ADDR_WIDTH     (ADDR_WIDTH_MSB),
                .ADDR_BASE      (SUB_DEPTH * i),
                .ADDR_BOUND     ((SUB_DEPTH * i) + SUB_DEPTH - 1)
            )
            SUB_READ_ENABLE
            (
                .enable         (rden),
                .addr           (sub_read_selector),
                .hit            (sub_rden[i])
            );

            Address_Range_Decoder_Static
            #(
                .ADDR_WIDTH     (ADDR_WIDTH_MSB),
                .ADDR_BASE      (SUB_DEPTH * i),
                .ADDR_BOUND     ((SUB_DEPTH * i) + SUB_DEPTH - 1)
            )
            SUB_WRITE_ENABLE
            (
                .enable         (wren),
                .addr           (sub_write_selector),
                .hit            (sub_wren[i])
            );

        end
    endgenerate

// --------------------------------------------------------------------
// Instantiate and wire-up the sub-RAMs

    reg [(WORD_WIDTH*SUB_RAM_COUNT)-1:0] sub_read_data = 0;

    RAM_SDP 
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (SUB_ADDR_WIDTH),
        .DEPTH          (SUB_DEPTH),
        .RAMSTYLE       (RAMSTYLE),
        .READ_NEW_DATA  (READ_NEW_DATA),
        .USE_INIT_FILE  (USE_INIT_FILE),
        .INIT_FILE      (SUB_INIT_FILE)
    )
    SUB_RAM             [SUB_RAM_COUNT-1:0]
    (
        .clock          (clock),
        .wren           (sub_wren),
        .write_addr     (sub_write_addr),
        .write_data     (write_data),
        .rden           (sub_rden),
        .read_addr      (sub_read_addr), 
        .read_data      (sub_read_data)
    );

// --------------------------------------------------------------------
// Select the output of the read-enabled sub-RAM

    reg [ADDR_WIDTH_MSB-1:0] sub_read_selector_synced = 0;

    always @(posedge clock) begin
        sub_read_selector_synced <= sub_read_selector;
    end

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH_MSB),
        .INPUT_COUNT    (SUB_RAM_COUNT)
    )
    SUB_READ_MUX
    (
        .addr           (sub_read_selector_synced),    
        .in             (sub_read_data),
        .out            (read_data)
    );

endmodule

