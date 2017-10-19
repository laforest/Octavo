
// Places Instruction_Fetch_Decode_Mapped in the write memory space.

`default_nettype none

module Instruction_Fetch_Decode_Mapped
#(
    parameter       WORD_WIDTH              = 0,
    parameter       ADDR_WIDTH              = 0,
    // Instruction format
    parameter       OPCODE_WIDTH            = 0,
    parameter       D_OPERAND_WIDTH         = 0,
    parameter       A_OPERAND_WIDTH         = 0,
    parameter       B_OPERAND_WIDTH         = 0,
    // Instruction Memory (shared)
    parameter       IM_WORD_WIDTH           = 0,
    parameter       IM_ADDR_WIDTH           = 0,
    parameter       IM_READ_NEW             = 0,
    parameter       IM_DEPTH                = 0,
    parameter       IM_RAMSTYLE             = "",
    parameter       IM_INIT_FILE            = "",
    // Opcode Decoder Memory (multithreaded)
    parameter       OD_WORD_WIDTH           = 0,
    parameter       OD_ADDR_WIDTH           = 0,
    parameter       OD_READ_NEW             = 0,
    parameter       OD_THREAD_DEPTH         = 0,
    parameter       OD_RAMSTYLE             = "",
    parameter       OD_INIT_FILE            = "",
    parameter       OD_INITIAL_THREAD_READ  = 0,
    parameter       OD_INITIAL_THREAD_WRITE = 0,
    // Memory-mapping
    parameter       DB_BASE_ADDR            = 0,
    parameter       IM_BASE_ADDR_WRITE      = 0,
    parameter       OD_BASE_ADDR_WRITE      = 0,
    // Multithreading
    parameter       THREAD_COUNT            = 0,
    parameter       THREAD_COUNT_WIDTH      = 0
)
(
    input   wire                            clock,

    input   wire                            IOR_previous,
    input   wire                            cancel_previous,

    input   wire    [ADDR_WIDTH-1:0]        im_write_addr,
    input   wire    [WORD_WIDTH-1:0]        im_write_data,
    input   wire    [IM_ADDR_WIDTH-1:0]     im_read_addr,

    input   wire    [ADDR_WIDTH-1:0]        od_write_addr,
    input   wire    [WORD_WIDTH-1:0]        od_write_data,

    output  wire    [OD_WORD_WIDTH-1:0]     ALU_control,
    output  wire    [D_OPERAND_WIDTH-1:0]   DA,
    output  wire    [D_OPERAND_WIDTH-1:0]   DB,
    output  wire    [A_OPERAND_WIDTH-1:0]   A,
    output  wire    [B_OPERAND_WIDTH-1:0]   B
);

// --------------------------------------------------------------------

    // For now, we always perform a fetch and decode each cycle.  In the
    // future, we might watch for consecutive fetches from the same PC from
    // consecutive threads, which would happen in SIMD code, and save power
    // by holding the instruction and decode memories output steady.

    reg im_rden = 1'b1;

// --------------------------------------------------------------------

    // Disable writes if writing instruction was Cancelled or Annulled

    reg instruction_ok = 0;

    always @(*) begin
        instruction_ok <= (IOR_previous == 1'b1) & (cancel_previous == 1'b0);
    end

// --------------------------------------------------------------------

    localparam                  IM_BOUND_ADDR_WRITE = IM_BASE_ADDR_WRITE + IM_DEPTH - 1;

    wire                        im_wren;
    wire [IM_ADDR_WIDTH-1:0]    im_write_addr_translated;

    Memory_Mapper
    #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .ADDR_BASE              (IM_BASE_ADDR_WRITE),
        .ADDR_BOUND             (IM_BOUND_ADDR_WRITE),
        .ADDR_WIDTH_LSB         (IM_ADDR_WIDTH),
        .REGISTERED             (0)

    )
    MM_IM
    (
        .clock                  (1'b0),
        .enable                 (instruction_ok),
        .addr                   (im_write_addr),
        .addr_translated_lsb    (im_write_addr_translated),
        .addr_valid             (im_wren)
    );

// --------------------------------------------------------------------

    localparam                      OD_BOUND_ADDR_WRITE = OD_BASE_ADDR_WRITE + OD_THREAD_DEPTH - 1;

    wire                            od_wren;
    wire        [OD_ADDR_WIDTH-1:0] od_write_addr_translated;

    Memory_Mapper
    #(
        .ADDR_WIDTH             (ADDR_WIDTH),
        .ADDR_BASE              (OD_BASE_ADDR_WRITE),
        .ADDR_BOUND             (OD_BOUND_ADDR_WRITE),
        .ADDR_WIDTH_LSB         (OD_ADDR_WIDTH),
        .REGISTERED             (0)

    )
    MM_OD
    (
        .clock                  (1'b0),
        .enable                 (instruction_ok),
        .addr                   (od_write_addr),
        .addr_translated_lsb    (od_write_addr_translated),
        .addr_valid             (od_wren)
    );

// --------------------------------------------------------------------

Instruction_Fetch_Decode
#(
    .OPCODE_WIDTH               (OPCODE_WIDTH),
    .D_OPERAND_WIDTH            (D_OPERAND_WIDTH),
    .A_OPERAND_WIDTH            (A_OPERAND_WIDTH),
    .B_OPERAND_WIDTH            (B_OPERAND_WIDTH),
    .IM_WORD_WIDTH              (IM_WORD_WIDTH),
    .IM_ADDR_WIDTH              (IM_ADDR_WIDTH),
    .IM_READ_NEW                (IM_READ_NEW),
    .IM_DEPTH                   (IM_DEPTH),
    .IM_RAMSTYLE                (IM_RAMSTYLE),
    .IM_INIT_FILE               (IM_INIT_FILE),
    .OD_WORD_WIDTH              (OD_WORD_WIDTH),
    .OD_ADDR_WIDTH              (OD_ADDR_WIDTH),
    .OD_READ_NEW                (OD_READ_NEW),
    .OD_THREAD_DEPTH            (OD_THREAD_DEPTH),
    .OD_RAMSTYLE                (OD_RAMSTYLE),
    .OD_INIT_FILE               (OD_INIT_FILE),
    .OD_INITIAL_THREAD_READ     (OD_INITIAL_THREAD_READ),
    .OD_INITIAL_THREAD_WRITE    (OD_INITIAL_THREAD_WRITE),
    .DB_BASE_ADDR               (DB_BASE_ADDR),
    .THREAD_COUNT               (THREAD_COUNT),
    .THREAD_COUNT_WIDTH         (THREAD_COUNT_WIDTH)
)
IFD
(
    .clock                      (clock),

    .im_wren                    (im_wren),
    .im_write_addr              (im_write_addr_translated),
    .im_write_data              (im_write_data[IM_WORD_WIDTH-1:0]),
    .im_rden                    (im_rden),
    .im_read_addr               (im_read_addr),

    .od_wren                    (od_wren),
    .od_write_addr              (od_write_addr_translated),
    .od_write_data              (od_write_data[OD_WORD_WIDTH-1:0]),

    .ALU_control                (ALU_control),
    .DA                         (DA),
    .DB                         (DB),
    .A                          (A),
    .B                          (B)
);

endmodule

