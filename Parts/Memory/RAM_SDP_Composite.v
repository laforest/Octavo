
// Simple Dual-Port RAM, implemented as a composite of smaller RAMs.

// For example, if we let Quartus infer a single deep MLAB-based memory with
// a registered output, it will do so, but places the single output register
// after the mux, as the behavioural code describes, rather than at the output
// of each MLAB.  Furthermore, since the mux is inferred, the output register
// will not get retimed across the mux, and so becomes a critical path.

// This implementation instead yields multiple memories with registered
// outputs, and a mux placed after these. Use this if the automatically
// inferred RAM is too slow.

module RAM_SDP_Composite
#(
    // Same parameters as RAM_SDP
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       DEPTH               = 0,
    parameter       RAMSTYLE            = "",
    parameter       READ_NEW_DATA       = 0,
    parameter       USE_INIT_FILE       = 0,
    parameter       INIT_FILE           = "",
    // Parameters for the individual sub-RAMs
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
        sub_read_addr       = read_addr  [ADDR_WIDTH-ADDR_WIDTH_LSB:0];
        sub_write_addr      = write_addr [ADDR_WIDTH-ADDR_WIDTH_LSB:0];
    end

// --------------------------------------------------------------------
// Enable reads and writes to each sub-RAM based on selectors.

    reg [SUB_RAM_COUNT-1:0] sub_wren = 0;
    reg [SUB_RAM_COUNT-1:0] sub_rden = 0;

    generate
        genvar i;
        for(i = 0; i < SUB_RAM_COUNT; i = i+1) begin

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
        .INIT_FILE      (INIT_FILE)
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

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH_MSB),
        .INPUT_COUNT    (SUB_RAM_COUNT)
    )
    SUB_READ_MUX
    (
        .addr           (sub_read_selector),    
        .in             (sub_read_data),
        .out            (read_data)
    );

endmodule

