
// Performs all the I/O readiness and range checks before we get to Memory.

// We check the E/F bits of write ports here, even though we only do the write
// much later, so we can annul I/O and instruction side-effects before they
// happen.

module IO
#(
    parameter   A_ADDR_WIDTH                    = 0,
    parameter   B_ADDR_WIDTH                    = 0,
    parameter   D_ADDR_WIDTH                    = 0,

    parameter   A_READ_PORT_COUNT               = 0,
    parameter   A_READ_PORT_BASE_ADDR           = 0,
    parameter   A_READ_PORT_ADDR_WIDTH          = 0,

    parameter   A_WRITE_PORT_COUNT              = 0,
    parameter   A_WRITE_PORT_BASE_ADDR          = 0,
    parameter   A_WRITE_PORT_ADDR_WIDTH         = 0,

    parameter   B_READ_PORT_COUNT               = 0,
    parameter   B_READ_PORT_BASE_ADDR           = 0,
    parameter   B_READ_PORT_ADDR_WIDTH          = 0,

    parameter   B_WRITE_PORT_COUNT              = 0,
    parameter   B_WRITE_PORT_BASE_ADDR          = 0,
    parameter   B_WRITE_PORT_ADDR_WIDTH         = 0
)
(
    input   wire                                clock,

    input   wire    [A_READ_PORT_COUNT-1:0]     A_read_EF, 
    input   wire    [A_WRITE_PORT_COUNT-1:0]    A_write_EF, 

    input   wire    [B_READ_PORT_COUNT-1:0]     B_read_EF, 
    input   wire    [B_WRITE_PORT_COUNT-1:0]    B_write_EF, 

    input   wire    [A_ADDR_WIDTH-1:0]          A_read_addr,
    input   wire    [B_ADDR_WIDTH-1:0]          B_read_addr,
    input   wire    [D_ADDR_WIDTH-1:0]          D_write_addr,
);
    //
    // **************** FIRST STAGE ********************
    //

    //
    // Let's check if each read/write address points to a port
    //

    wire    A_read_is_IO;

    Address_Decoder
    #(
        .ADDR_COUNT (A_READ_PORT_COUNT),
        .ADDR_BASE  (A_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH (A_READ_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    A_read_decoder
    (
        .clock      (clock),
        .addr       (A_read_addr),
        .hit        (A_read_is_IO)
    );
    
    wire    B_read_is_IO;

    Address_Decoder
    #(
        .ADDR_COUNT (B_READ_PORT_COUNT),
        .ADDR_BASE  (B_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH (B_READ_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    B_read_decoder
    (
        .clock      (clock),
        .addr       (B_read_addr),
        .hit        (B_read_is_IO)
    );
    
    // Both A and B ports share a common write address and data.
    // The writes will duplicate to both if their port address 
    // ranges overlap.

    wire    A_write_is_IO;

    Address_Decoder
    #(
        .ADDR_COUNT (A_WRITE_PORT_COUNT),
        .ADDR_BASE  (A_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH (A_WRITE_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    A_write_decoder
    (
        .clock      (clock),
        .addr       (D_write_addr),
        .hit        (A_write_is_IO)
    );
    
    wire    B_write_is_IO;

    Address_Decoder
    #(
        .ADDR_COUNT (B_WRITE_PORT_COUNT),
        .ADDR_BASE  (B_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH (B_WRITE_PORT_ADDR_WIDTH),
        .REGISTERED (`TRUE)
    )
    B_write_decoder
    (
        .clock      (clock),
        .addr       (D_write_addr),
        .hit        (B_write_is_IO)
    );
    
    //
    // Now let's select the addressed ports' Empty/Full bit.
    //

    wire    A_read_EF_selected;

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (A_READ_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (A_READ_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    A_read_EF_Selector
    (
        .clock          (clock),
        .addr           (A_read_addr),
        .data_in        (A_read_EF),
        .data_out       (A_read_EF_selected)
    );

    wire    B_read_EF_selected;

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (B_READ_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (B_READ_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    B_read_EF_Selector
    (
        .clock          (clock),
        .addr           (B_read_addr),
        .data_in        (B_read_EF),
        .data_out       (B_read_EF_selected)
    );

    // Again, A and B share a common write address

    wire    A_write_EF_selected;

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (A_WRITE_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (A_WRITE_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    A_write_EF_Selector
    (
        .clock          (clock),
        .addr           (D_write_addr),
        .data_in        (A_write_EF),
        .data_out       (A_write_EF_selected)
    );

    wire    B_write_EF_selected;

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (B_WRITE_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (B_WRITE_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    B_write_EF_Selector
    (
        .clock          (clock),
        .addr           (B_write_addr),
        .data_in        (B_write_EF),
        .data_out       (B_write_EF_selected)
    );

    wire    B_read_EF_selected;

    Addressed_Mux
    #(
        .WORD_WIDTH     (1),
        .ADDR_WIDTH     (B_READ_PORT_ADDR_WIDTH),
        .INPUT_COUNT    (B_READ_PORT_COUNT),
        .REGISTERED     (`TRUE)
    )
    B_read_EF_Selector
    (
        .clock          (clock),
        .addr           (B_read_addr),
        .data_in        (B_read_EF),
        .data_out       (B_read_EF_selected)
    );

    //
    // And register the addresses too for the next stage
    //

    reg     [A_ADDR_WIDTH-1:0]  A_read_addr_2;
    reg     [B_ADDR_WIDTH-1:0]  B_read_addr_2;
    reg     [D_ADDR_WIDTH-1:0]  D_write_addr_2;

    always @(posedge clock) begin
        A_read_addr_2  <= A_read_addr;
        B_read_addr_2  <= B_read_addr;
        D_write_addr_2 <= D_write_addr;
    end

    //
    // **************** SECOND STAGE ********************
    //

endmodule

