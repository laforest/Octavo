
// Master AXI Transactor

// Connects a set of system interface registers to an AXI interface.
// Internal sequencing is done through the control interface.

// Expected usage for AXI reads and writes:
// - Set the address, type and length of transaction
// - Read/write the expected number of data words
// - If a write, read the response.

module Master_AXI_Transactor
#(
    parameter WORD_WIDTH    = 0,
    // set to clog2(WORD_WIDTH)
    parameter BYTE_COUNT    = 0,
    parameter ADDR_WIDTH    = 0,
    // Bytes per transfer
    // set to clog2(BYTE_COUNT)
    parameter AXSIZE        = 0
)
(
    input   wire                        clock,

// --

    // Read Address Channel
    // System interface
    input   wire    [ADDR_WIDTH-1:0]    ar_system_address,
    input   wire                        ar_system_address_wren,
    input   wire    [AXLEN_WIDTH-1:0]   ar_system_count,
    input   wire                        ar_system_count_wren,
    input   wire    [AXBURST_WIDTH-1:0] ar_system_type,
    input   wire                        ar_system_type_wren,

    // AXI interface
    output  wire    [ADDR_WIDTH-1:0]    araddr,
    output  wire    [AXLEN_WIDTH-1:0]   arlen,
    output  wire    [AXSIZE_WIDTH-1:0]  arsize,
    output  wire    [AXBURST_WIDTH-1:0] arburst,
    output  wire                        arvalid,
    input   wire                        arready

// --

    // Write Address Channel
    // System interface
    input   wire    [ADDR_WIDTH-1:0]    aw_system_address,
    input   wire                        aw_system_address_wren,
    input   wire    [AXLEN_WIDTH-1:0]   aw_system_count,
    input   wire                        aw_system_count_wren,
    input   wire    [AXBURST_WIDTH-1:0] aw_system_type,
    input   wire                        aw_system_type_wren,

    // AXI interface
    output  wire    [ADDR_WIDTH-1:0]    awaddr,
    output  wire    [AXLEN_WIDTH-1:0]   awlen,
    output  wire    [AXSIZE_WIDTH-1:0]  awsize,
    output  wire    [AXBURST_WIDTH-1:0] awburst,
    output  wire                        awvalid,
    input   wire                        awready

// --

    // Read Data Channel
    // System interface
    input   wire                        r_system_ready,
    output  wire    [WORD_WIDTH-1:0]    r_system_data,
    output  wire                        r_system_valid,
    output  wire                        r_system_error,

    // AXI interface
    input   wire    [WORD_WIDTH-1:0]    rdata,
    input   wire    [RRESP_WIDTH-1:0]   rresp,
    input   wire                        rlast,
    input   wire                        rvalid,
    output  wire                        rready

// --

    // Write Data Channel
    // System interface
    output  wire                        w_system_ready,
    input   wire    [WORD_WIDTH-1:0]    w_system_data,
    input   wire                        w_system_valid,

    // AXI interface
    output  wire    [WORD_WIDTH-1:0]    wdata,
    output  wire    [BYTE_COUNT-1:0]    wstrb,
    output  wire                        wlast,
    output  wire                        wvalid,
    input   wire                        wready

// --

    // Write Response Channel
    // System interface
    input   wire                        b_system_ready,
    output  wire    [BRESP_WIDTH-1:0]   b_system_response,
    output  wire                        b_system_valid,

    // AXI interface
    input   wire    [BRESP_WIDTH-1:0]   bresp,
    input   wire                        bvalid,
    output  wire                        bready
);

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

    wire ar_control_start;
    wire ar_control_busy;

    Master_AXI_Address_Channel
    #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .AXSIZE                 (AXSIZE)
    )
    Read_Address
    (
        .clock                  (clock),

        // System interface
        .system_address         (ar_system_address),
        .system_address_wren    (ar_system_address_wren),
        .system_count           (ar_system_count),
        .system_count_wren      (ar_system_count_wren),
        .system_type            (ar_system_type),
        .system_type_wren       (ar_system_type_wren),

        // Control interface
        .control_start          (ar_control_start),
        .control_busy           (ar_control_busy),

        // AXI interface        
        .axaddr                 (araddr),
        .axlen                  (arlen),
        .axsize                 (arsize),
        .axburst                (arburst),
        .axvalid                (arvalid),
        .axready                (arready)
    );

// --------------------------------------------------------------------------

    wire aw_control_start;
    wire aw_control_busy;

    Master_AXI_Address_Channel
    #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .AXSIZE                 (AXSIZE)
    )
    Write_Address
    (
        .clock                  (clock),

        // System interface
        .system_address         (aw_system_address),
        .system_address_wren    (aw_system_address_wren),
        .system_count           (aw_system_count),
        .system_count_wren      (aw_system_count_wren),
        .system_type            (aw_system_type),
        .system_type_wren       (aw_system_type_wren),

        // Control interface
        .control_start          (aw_control_start),
        .control_busy           (aw_control_busy),

        // AXI interface        
        .axaddr                 (awaddr),
        .axlen                  (awlen),
        .axsize                 (awsize),
        .axburst                (awburst),
        .axvalid                (awvalid),
        .axready                (awready)
    );

// --------------------------------------------------------------------------

    wire r_control_start;
    wire r_control_busy;

    Master_AXI_Read_Data_Channel
    #(
        .WORD_WIDTH     (WORD_WIDTH)
    )
    Read_Data
    (
        .clock          (clock),

        // System interface
        .system_ready   (r_system_ready),
        .system_data    (r_system_data),
        .system_valid   (r_system_valid),
        .system_error   (r_system_error),

        // Control interface
        .control_start  (r_control_start),
        .control_busy   (r_control_busy),

        // AXI interface
        .rdata          (rdata),
        .rresp          (rresp),
        .rlast          (rlast),
        .rvalid         (rvalid),
        .rready         (rready)
    );

// --------------------------------------------------------------------------

    wire w_control_start;
    wire w_control_busy;

    Master_AXI_Write_Data_Channel
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .BYTE_COUNT     (BYTE_COUNT)
    )
    Write_Data
    (
        .clock          (clock),

        // System interface
        .system_ready   (w_system_ready),
        .system_data    (w_system_data),
        .system_valid   (w_system_valid),

        // Control interface
        .control_start  (w_control_start),
        .control_busy   (w_control_busy),

        // Internal
        .axlen          (arlen),

        // AXI interface
        .wdata          (wdata),
        .wstrb          (wstrb),
        .wlast          (wlast),
        .wvalid         (wvalid),
        .wready         (wready)
    );

// --------------------------------------------------------------------------

    wire b_control_start;
    wire b_control_busy;

    Master_AXI_Write_Response_Channel
    // No user-settable parameters
    Write_Response
    (
        .clock              (clock),

        // System interface
        .system_ready       (b_system_ready),
        .system_response    (b_system_response),
        .system_valid       (b_system_valid),

        // Control interface
        .control_start      (b_control_start),
        .control_busy       (b_control_busy),

        // AXI interface
        .bresp              (bresp),
        .bvalid             (bvalid),
        .bready             (bready)
    );

// --------------------------------------------------------------------------

    Master_AXI_Sequencer_Read
    // No parameters
    Sequencer_Read
    (
        .clock              (clock),

        .ar_control_start   (ar_control_start),
        .ar_control_busy    (ar_control_busy),

        .r_control_start    (r_control_start),
        .r_control_busy     (r_control_busy)
    );

// --------------------------------------------------------------------------

    Master_AXI_Sequencer_Write
    // No parameters
    Sequencer_Write
    (
        .clock              (clock),

        .aw_control_start   (aw_control_start),
        .aw_control_busy    (aw_control_busy),

        .w_control_start    (w_control_start),
        .w_control_busy     (w_control_busy),

        .b_control_start    (b_control_start),
        .b_control_busy     (b_control_busy)
    );

endmodule

