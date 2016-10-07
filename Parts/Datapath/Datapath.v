
// Octavo Datapath: I/O predication, Memory, I/O, and ALU

module Datapath
#(
    parameter   WORD_WIDTH                              = 0,
    parameter   READ_ADDR_WIDTH                         = 0,
    parameter   WRITE_ADDR_WIDTH                        = 0,
    parameter   MEM_DEPTH                               = 0,
    parameter   MEM_RAMSTYLE                            = "",
    parameter   MEM_INIT_FILE_A                         = "",
    parameter   MEM_INIT_FILE_B                         = "",
    // Memory A Write Base Address is always zero
    parameter   MEM_WRITE_BASE_ADDR_B                   = 0,
    parameter   ALU_REGISTER_S_ADDR                     = 0,
    parameter   IO_PORT_COUNT                           = 0,
    parameter   IO_PORT_BASE_ADDR                       = 0,
    parameter   IO_PORT_ADDR_WIDTH                      = 0
)
(
    input   wire                                        clock,
    input   wire    [`TRIADIC_CTRL_WIDTH-1:0]           control,

    // Contained in control, but extracted separately as it's used elsewhere.
    input   wire                                        split,

    // From Branch Trigger Module (BTM). Signals a cancelled instruction.
    input   wire                                        branch_cancel,

    // These are raw from the instruction, and drive I/O Predication
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_A,
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_B,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_D,

    // From the Address Offset Module (AOM), and drive the Memory
    // May be annulled by I/O Predication
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_A_offset,
    input   wire    [READ_ADDR_WIDTH-1:0]               read_addr_B_offset,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_A_offset,
    input   wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_B_offset,
    
    input   wire    [PORT_COUNT-1:0]                    io_read_EF_A,
    input   wire    [PORT_COUNT-1:0]                    io_read_EF_B,
    input   wire    [PORT_COUNT-1:0]                    io_write_EF_A,
    input   wire    [PORT_COUNT-1:0]                    io_write_EF_B,

    input   wire    [(PORT_COUNT*WORD_WIDTH)-1:0]       io_read_data_A,
    input   wire    [(PORT_COUNT*WORD_WIDTH)-1:0]       io_read_data_B,
    output  wire    [(PORT_COUNT*WORD_WIDTH)-1:0]       io_write_data_A,
    output  wire    [(PORT_COUNT*WORD_WIDTH)-1:0]       io_write_data_B,

    output  wire    [PORT_COUNT-1:0]                    io_rden_A,
    output  wire    [PORT_COUNT-1:0]                    io_rden_B,
    output  wire    [PORT_COUNT-1:0]                    io_wren_A,
    output  wire    [PORT_COUNT-1:0]                    io_wren_B,

    // ALU outputs
    output  wire    [WORD_WIDTH-1:0]                    Ra,
    output  wire    [WORD_WIDTH-1:0]                    Rb,
    output  wire                                        Rcarry_out,
    output  wire                                        Roverflow,

    // Write addresses for things not in Datapath (I and H Memories)
    output  wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_Ra,
    output  wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_Rb,

    // Main I/O Predication output. Signals an annulled instruction.
    output  wire                                        IO_ready
);

// --------------------------------------------------------------------

    // For clarity, as the read and write addresses have the same width at the
    // level of individual memories, and the D instruction operand write
    // address is always wider since it addresses all memory ranges
    // (A, B, I, and H)

    localparam MEM_ADDR_WIDTH = READ_ADDR_WIDTH;

// --------------------------------------------------------------------

    localparam PIPE_DEPTH_PREDICATION = 2;

    wire read_addr_is_IO_A;
    wire read_addr_is_IO_B;
    wire write_addr_is_IO_A;
    wire write_addr_is_IO_B;

    Datapath_IO_Predication
    #(
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),    
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),    
        .MEM_ADDR_WIDTH         (MEM_ADDR_WIDTH),
        .MEM_DEPTH              (MEM_DEPTH), 
        .MEM_WRITE_BASE_ADDR_B  (MEM_WRITE_BASE_ADDR_B),
        .PORT_COUNT             (IO_PORT_COUNT),
        .PORT_BASE_ADDR         (IO_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH        (IO_PORT_ADDR_WIDTH)
    )
    DIOP
    (
        .clock                  (clock),
        .split                  (split),

        .read_addr_A            (read_addr_A),
        .read_addr_B            (read_addr_B),
        .write_addr_D           (write_addr_D),

        .read_EF_A              (io_read_EF_A),
        .read_EF_B              (io_read_EF_B),
        .write_EF_A             (io_write_EF_A),
        .write_EF_B             (io_write_EF_B),

        .io_rden_A              (io_rden_A),
        .io_rden_B              (io_rden_B),
        .read_addr_is_IO_A      (read_addr_is_IO_A),
        .read_addr_is_IO_B      (read_addr_is_IO_B),
        .write_addr_is_IO_A     (write_addr_is_IO_A),
        .write_addr_is_IO_B     (write_addr_is_IO_B),
        .IO_ready               (IO_ready)
    );

// --------------------------------------------------------------------
// If IO_ready not set        (instruction was annulled), 
// or if branch_cancel is set (instruction was cancelled)
// force all Memory addresses to zero, which will disable their reads/writes
// and make the current instruction, regardless of operation, into a no-op.

    wire    [READ_ADDR_WIDTH-1:0]   read_addr_A_annulled;
    wire    [READ_ADDR_WIDTH-1:0]   read_addr_B_annulled;
    wire    [WRITE_ADDR_WIDTH-1:0]  write_addr_A_annulled;
    wire    [WRITE_ADDR_WIDTH-1:0]  write_addr_B_annulled;

    reg                             make_noop = 0;

    always @(*) begin
        make_noop <= (IO_ready == 0) | (branch_cancel == 1);
    end

    Annuller
    #(
        .WORD_WIDTH (((WRITE_ADDR_WIDTH*2) + (READ_ADDR_WIDTH*2)))
    )
    Memory_addresses
    (
        .annul      ((make_noop == 1)),
        .in         ({write_addr_B_offset,   write_addr_A_offset,   read_addr_B_offset,   read_addr_A_offset}),
        .out        ({write_addr_B_annulled, write_addr_A_annulled, read_addr_B_annulled, read_addr_A_annulled})
    );

// --------------------------------------------------------------------

    localparam PIPE_DEPTH_MEMORY_READ  = 2;
    localparam PIPE_DEPTH_MEMORY_WRITE = 2;

    wire [WORD_WIDTH-1:0] read_data_A;
    wire [WORD_WIDTH-1:0] read_data_B;

    Datapath_Memory
    #(
        .WORD_WIDTH             (WORD_WIDTH),
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),
        .MEM_ADDR_WIDTH         (MEM_ADDR_WIDTH),
        .MEM_DEPTH              (MEM_DEPTH),
        .MEM_RAMSTYLE           (MEM_RAMSTYLE),
        .MEM_INIT_FILE_A        (MEM_INIT_FILE_A),
        .MEM_INIT_FILE_B        (MEM_INIT_FILE_B),
        .MEM_WRITE_BASE_ADDR_B  (MEM_WRITE_BASE_ADDR_B),
        .IO_PORT_COUNT          (IO_PORT_COUNT),
        .IO_PORT_BASE_ADDR      (IO_PORT_BASE_ADDR),
        .IO_PORT_ADDR_WIDTH     (IO_PORT_ADDR_WIDTH) 
    )
    DM
    (
        .clock                  (clock),

        .read_addr_A            (read_addr_A_annulled),
        .read_addr_B            (read_addr_B_annulled),
        .write_addr_A           (write_addr_Ra),
        .write_addr_B           (write_addr_Rb),
        
        .write_data_A           (Ra),
        .write_data_B           (Rb),

        .io_read_data_A         (io_read_data_A),
        .io_read_data_B         (io_read_data_B),
        .io_write_data_A        (io_write_data_A),
        .io_write_data_B        (io_write_data_B),

        .read_addr_is_IO_A      (read_addr_is_IO_A),
        .read_addr_is_IO_B      (read_addr_is_IO_B),
        .write_addr_is_IO_A     (write_addr_is_IO_A),
        .write_addr_is_IO_B     (write_addr_is_IO_B),

        .io_wren_A              (io_wren_A),
        .io_wren_B              (io_wren_B),

        .read_data_A            (read_data_A),
        .read_data_B            (read_data_B)
    );

// --------------------------------------------------------------------

    // This is the delay between the start of the Datapath to the ALU
    localparam PIPE_DEPTH_TO_ALU = PIPE_DEPTH_PREDICATION + PIPE_DEPTH_MEMORY_READ;

    wire [`TRIADIC_CTRL_WIDTH-1:0] control_ALU;

    Delay_Line 
    #(
        .DEPTH  (PIPE_DEPTH_TO_ALU), 
        .WIDTH  (`TRIADIC_CTRL_WIDTH)
    ) 
    DL_ALU_control
    (
        .clock  (clock),
        .in     (control),
        .out    (control_ALU)
    );

// --------------------------------------------------------------------

    localparam PIPE_DEPTH_ALU = 4;

    reg     [WORD_WIDTH-1:0]    R           = 0;
    reg                         R_zero      = 0;
    reg                         R_negative  = 0;
    reg     [WORD_WIDTH-1:0]    S           = 0;

    Triadic_ALU
    #(
        .WORD_WIDTH     (WORD_WIDTH) 
    )
    ALU
    (
        .clock          (clock),
        .control        (control_ALU),
        .A              (read_data_A),
        .B              (read_data_B),
        .R              (R),
        .R_zero         (R_zero),
        .R_negative     (R_negative),
        .S              (S),
        .Ra             (Ra),
        .Rb             (Rb),
        .carry_out      (Rcarry_out),
        .overflow       (Roverflow)
    );

// --------------------------------------------------------------------
// Carry the write addresses around to the Memory write ports
// Synchronizes them with the ALU outputs

    localparam PIPE_DEPTH_WRITE_ADDR = PIPE_DEPTH_MEMORY_READ + PIPE_DEPTH_ALU;

    Delay_Line 
    #(
        .DEPTH  (PIPE_DEPTH_WRITE_ADDR), 
        .WIDTH  (WRITE_ADDR_WIDTH + WRITE_ADDR_WIDTH)
    ) 
    DL_write_addr
    (
        .clock  (clock),
        .in     ({write_addr_B_annulled, write_addr_A_annulled}),
        .out    ({write_addr_Rb,         write_addr_Ra})
    );

// --------------------------------------------------------------------
// Ra data feedback: feed result to next instruction from same thread
// Make it one shorter than needed, to feed both R and S separate registers.

    localparam PIPE_DEPTH_RA_TO_RS = `OCTAVO_THREAD_COUNT - PIPE_DEPTH_ALU - 1;

    wire [WORD_WIDTH-1:0] RS;

    Delay_Line 
    #(
        .DEPTH  (PIPE_DEPTH_RA_TO_RS), 
        .WIDTH  (WORD_WIDTH)
    ) 
    DL_Ra_to_RS
    (
        .clock  (clock),
        .in     (Ra),
        .out    (RS)
    );

// --------------------------------------------------------------------
// Ra address feedback: feed address to next instruction from same thread
// Make it one shorter than needed, so the address is synched with RS

    wire [WRITE_ADDR_WIDTH-1:0] write_addr_RS;

    Delay_Line 
    #(
        .DEPTH  (PIPE_DEPTH_RA_TO_RS), 
        .WIDTH  (WORD_WIDTH)
    ) 
    DL_write_addr_RS
    (
        .clock  (clock),
        .in     (write_addr_Ra),
        .out    (write_addr_RS)
    );

// --------------------------------------------------------------------
// R and S registers. S is memory-addressed and persistent.

    always @(posedge clock) begin
        R <= RS;
        S <= (write_addr_RS == ALU_REGISTER_S_ADDR) ? RS : S;
    end

// --------------------------------------------------------------------
// Generate R word-masks fed back to ALU

    reg R_is_zero = 0;
    reg R_is_neg  = 0;

    always @(*) begin
        R_is_zero   = (R == 0);
        R_zero      = {WORD_WIDTH{R_is_zero}};
        R_is_neg    = (R[WORD_WIDTH-1] == 1); // MSB is sign bit
        R_negative  = {WORD_WIDTH{R_is_neg}};
    end


endmodule

