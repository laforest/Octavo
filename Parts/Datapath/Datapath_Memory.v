
// Data Memories for Datapath: A and B
// Includes read/write address decoding
// Any split address has already been dealt with before arriving here.

// The read and write base/bound addresses define the depth of the memory (set
// by the smaller of the two ranges), and any access outside of that range
// will be disabled, even if the instantiated memory is larger due to Block
// RAM size granularity.

// It is assumed that bound >= base.

// Don't map anything (I/O ports) to address 0.

`default_nettype none

module Datapath_Memory
#(
    parameter   WORD_WIDTH                              = 0,
    parameter   READ_ADDR_WIDTH                         = 0,
    parameter   WRITE_ADDR_WIDTH                        = 0,
    parameter   MEM_ADDR_WIDTH                          = 0,
    parameter   MEM_RAMSTYLE                            = "",
    parameter   MEM_READ_NEW_DATA                       = 0,
    parameter   MEM_INIT_FILE_A                         = "",
    parameter   MEM_INIT_FILE_B                         = "",
    parameter   MEM_READ_BASE_ADDR_A                    = 0,
    parameter   MEM_READ_BOUND_ADDR_A                   = 0,
    parameter   MEM_WRITE_BASE_ADDR_A                   = 0,
    parameter   MEM_WRITE_BOUND_ADDR_A                  = 0,
    parameter   MEM_READ_BASE_ADDR_B                    = 0,
    parameter   MEM_READ_BOUND_ADDR_B                   = 0,
    parameter   MEM_WRITE_BASE_ADDR_B                   = 0,
    parameter   MEM_WRITE_BOUND_ADDR_B                  = 0,
    parameter   IO_PORT_COUNT                           = 0,
    parameter   IO_PORT_BASE_ADDR                       = 0,
    parameter   IO_PORT_ADDR_WIDTH                      = 0,
    parameter   WRITE_RETIME_STAGES                     = 0
)
(
    input   wire                                        clock,

    // Current and previous instruction status (Annuled/Cancelled)
    input   wire                                        IOR,
    input   wire                                        cancel,
    input   wire                                        IOR_previous,
    input   wire                                        cancel_previous,

    // Translated addresses from Addressing Module
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_A,
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_B,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_A,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_B,
    
    // From the ALU
    input   wire    [WORD_WIDTH-1:0]                    write_data_A,
    input   wire    [WORD_WIDTH-1:0]                    write_data_B,

    // To/From the outside world
    input   wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_A,
    input   wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_B,
    output  wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_write_data_A,
    output  wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_write_data_B,

    // From the I/O Predication module
    input   wire                                        read_addr_is_IO_A,
    input   wire                                        read_addr_is_IO_B,
    input   wire                                        write_addr_is_IO_A,
    input   wire                                        write_addr_is_IO_B,

    // To the outside world: which I/O Write Port is writing
    output  wire    [IO_PORT_COUNT-1:0]                 io_wren_A,
    output  wire    [IO_PORT_COUNT-1:0]                 io_wren_B,

    // Final read output from either Memory or I/O
    output  wire    [WORD_WIDTH-1:0]                    read_data_A,
    output  wire    [WORD_WIDTH-1:0]                    read_data_B
);

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    // Smaller of the read/write ranges sets the memory depth. 

    localparam MEM_READ_DEPTH_A  = MEM_READ_BOUND_ADDR_A  - MEM_READ_BASE_ADDR_A  + 1;
    localparam MEM_WRITE_DEPTH_A = MEM_WRITE_BOUND_ADDR_A - MEM_WRITE_BASE_ADDR_A + 1;
    localparam MEM_DEPTH_A       = (MEM_READ_DEPTH_A <= MEM_WRITE_DEPTH_A) ? MEM_READ_DEPTH_A : MEM_WRITE_DEPTH_A;

    localparam MEM_READ_DEPTH_B  = MEM_READ_BOUND_ADDR_B  - MEM_READ_BASE_ADDR_B  + 1;
    localparam MEM_WRITE_DEPTH_B = MEM_WRITE_BOUND_ADDR_B - MEM_WRITE_BASE_ADDR_B + 1;
    localparam MEM_DEPTH_B       = (MEM_READ_DEPTH_B <= MEM_WRITE_DEPTH_B) ? MEM_READ_DEPTH_B : MEM_WRITE_DEPTH_B;

// --------------------------------------------------------------------

    wire [WRITE_ADDR_WIDTH-1:0] write_addr_A_retimed;
    wire [WRITE_ADDR_WIDTH-1:0] write_addr_B_retimed;
    wire                        write_addr_is_IO_A_retimed;
    wire                        write_addr_is_IO_B_retimed;

    Delay_Line 
    #(
        .DEPTH  (WRITE_RETIME_STAGES), 
        .WIDTH  (WRITE_ADDR_WIDTH + WRITE_ADDR_WIDTH + 1 + 1)
    ) 
    DL_retime
    (
        .clock  (clock),
        .in     ({write_addr_A,         write_addr_B,         write_addr_is_IO_A,         write_addr_is_IO_B}),
        .out    ({write_addr_A_retimed, write_addr_B_retimed, write_addr_is_IO_A_retimed, write_addr_is_IO_B_retimed})
    );

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    wire read_A_zero;
    wire write_enable_A;

    // Memory A is always in range of the read operands, but we disable access
    // to address 0 to implement a zero register.

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (READ_ADDR_WIDTH),
        .ADDR_BASE  (0),
        .ADDR_BOUND (0)
    )
    Mem_A_Zero
    (
        .enable     (1'b1),
        .addr       (read_addr_A),
        .hit        (read_A_zero)
    );

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (WRITE_ADDR_WIDTH),
        .ADDR_BASE  (MEM_WRITE_BASE_ADDR_A),
        .ADDR_BOUND (MEM_WRITE_BOUND_ADDR_A)
    )
    Mem_A_Write
    (
        .enable     (1'b1),
        .addr       (write_addr_A_retimed),
        .hit        (write_enable_A)
    );

// --------------------------------------------------------------------

    // Same for Memory B.

    wire read_B_zero;
    wire write_enable_B;

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (READ_ADDR_WIDTH),
        .ADDR_BASE  (0),
        .ADDR_BOUND (0)
    )
    Mem_B_Zero
    (
        .enable     (1'b1),
        .addr       (read_addr_B),
        .hit        (read_B_zero)
    );

    Address_Range_Decoder_Static
    #(
        .ADDR_WIDTH (WRITE_ADDR_WIDTH),
        .ADDR_BASE  (MEM_WRITE_BASE_ADDR_B),
        .ADDR_BOUND (MEM_WRITE_BOUND_ADDR_B)
    )
    Mem_B_Write
    (
        .enable     (1'b1),
        .addr       (write_addr_B_retimed),
        .hit        (write_enable_B)
    );


// --------------------------------------------------------------------

    // Memories are addressed as a sub-set of the 
    // entire read/write address space.

    // This does assume that MEM_ADDR_WIDTH is <= READ/WRITE_ADDR_WIDTH
    // and that the sub-set is power-of-two aligned since we drop the MSB.

    reg [MEM_ADDR_WIDTH-1:0] read_addr_A_local = 0;
    reg [MEM_ADDR_WIDTH-1:0] read_addr_B_local = 0;
    reg [MEM_ADDR_WIDTH-1:0] write_addr_A_local = 0;
    reg [MEM_ADDR_WIDTH-1:0] write_addr_B_local = 0;

    always @(*) begin
        read_addr_A_local  <= read_addr_A           [MEM_ADDR_WIDTH-1:0];
        read_addr_B_local  <= read_addr_B           [MEM_ADDR_WIDTH-1:0];
        write_addr_A_local <= write_addr_A_retimed  [MEM_ADDR_WIDTH-1:0];
        write_addr_B_local <= write_addr_B_retimed  [MEM_ADDR_WIDTH-1:0];
    end

// --------------------------------------------------------------------
// --------------------------------------------------------------------

    Data_Memory
    #(
        .WORD_WIDTH             (WORD_WIDTH), 
        .ADDR_WIDTH             (MEM_ADDR_WIDTH), 
        .MEM_DEPTH              (MEM_DEPTH_A), 
        .MEM_RAMSTYLE           (MEM_RAMSTYLE), 
        .MEM_INIT_FILE          (MEM_INIT_FILE_A), 
        .MEM_READ_NEW_DATA      (MEM_READ_NEW_DATA),
        .IO_PORT_COUNT          (IO_PORT_COUNT), 
        .IO_PORT_BASE_ADDR      (IO_PORT_BASE_ADDR), 
        .IO_PORT_ADDR_WIDTH     (IO_PORT_ADDR_WIDTH)
    )
    DM_A
    (
        .clock                  (clock),

        .IOR                    (IOR),
        .cancel                 (cancel),
        .IOR_previous           (IOR_previous),
        .cancel_previous        (cancel_previous),

        .read_enable            ((read_A_zero == 1'b0)),
        .read_addr              (read_addr_A_local),
        .read_addr_is_IO        (read_addr_is_IO_A),
        .read_data              (read_data_A),
        .io_read_data           (io_read_data_A),   

        .write_enable           (write_enable_A),
        .write_addr             (write_addr_A_local),
        .write_addr_is_IO       (write_addr_is_IO_A_retimed),
        .write_data             (write_data_A),
        .io_wren                (io_wren_A),
        .io_write_data          (io_write_data_A)
    );

// --------------------------------------------------------------------

    Data_Memory
    #(
        .WORD_WIDTH             (WORD_WIDTH), 
        .ADDR_WIDTH             (MEM_ADDR_WIDTH), 
        .MEM_DEPTH              (MEM_DEPTH_B), 
        .MEM_RAMSTYLE           (MEM_RAMSTYLE), 
        .MEM_INIT_FILE          (MEM_INIT_FILE_B), 
        .MEM_READ_NEW_DATA      (MEM_READ_NEW_DATA),
        .IO_PORT_COUNT          (IO_PORT_COUNT), 
        .IO_PORT_BASE_ADDR      (IO_PORT_BASE_ADDR), 
        .IO_PORT_ADDR_WIDTH     (IO_PORT_ADDR_WIDTH)
    )
    DM_B
    (
        .clock                  (clock),

        .IOR                    (IOR),
        .cancel                 (cancel),
        .IOR_previous           (IOR_previous),
        .cancel_previous        (cancel_previous),

        .read_enable            ((read_B_zero == 1'b0)),
        .read_addr              (read_addr_B_local),
        .read_addr_is_IO        (read_addr_is_IO_B),
        .read_data              (read_data_B),
        .io_read_data           (io_read_data_B),   

        .write_enable           (write_enable_B),
        .write_addr             (write_addr_B_local),
        .write_addr_is_IO       (write_addr_is_IO_B_retimed),
        .write_data             (write_data_B),
        .io_wren                (io_wren_B),
        .io_write_data          (io_write_data_B)
    );

endmodule

