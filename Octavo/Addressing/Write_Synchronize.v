
// Delays address, wren, and data from ALU, which arrives from the previous
// Thread 6 instruction, for two cycles to match the local writes synched to
// Thread 4. This way, when a thread writes to a memory here, it can only
// override a local write in its next instruction, and not corrupt the
// operation of another thread. See Write_Priority also.

module Write_Synchronize
#(
    parameter   WORD_WIDTH                                  = 0,
    parameter   ADDR_WIDTH                                  = 0,

    parameter   BASIC_BLOCK_COUNTER_WORD_WIDTH              = 0, 
    parameter   CONTROL_MEMORY_WORD_WIDTH                   = 0, 
    parameter   DEFAULT_OFFSET_WORD_WIDTH                   = 0, 
    parameter   PROGRAMMED_OFFSETS_WORD_WIDTH               = 0, 
    parameter   INCREMENTS_WORD_WIDTH                       = 0 
)
(
    input   wire                                            clock,

    input   wire                                            ALU_wren_BBC,
    input   wire                                            ALU_wren_CTL,
    input   wire                                            ALU_wren_DO,
    input   wire                                            ALU_wren_PO,
    input   wire                                            ALU_wren_INC,

    input   wire    [ADDR_WIDTH-1:0]                        ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]                        ALU_write_data,

    input   wire    [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    ALU_write_data_BBC,
    input   wire    [CONTROL_MEMORY_WORD_WIDTH-1:0]         ALU_write_data_CTL,
    input   wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]         ALU_write_data_DO,
    input   wire    [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]     ALU_write_data_PO,
    input   wire    [INCREMENTS_WORD_WIDTH-1:0]             ALU_write_data_INC,

    output  wire                                            ALU_wren_BBC_synced,
    output  wire                                            ALU_wren_CTL_synced,
    output  wire                                            ALU_wren_DO_synced,
    output  wire                                            ALU_wren_PO_synced,
    output  wire                                            ALU_wren_INC_synced,

    output  wire    [ADDR_WIDTH-1:0]                        ALU_write_addr_synced,
    output  wire    [WORD_WIDTH-1:0]                        ALU_write_data_synced,

    output  wire    [BASIC_BLOCK_COUNTER_WORD_WIDTH-1:0]    ALU_write_data_BBC_synced,
    output  wire    [CONTROL_MEMORY_WORD_WIDTH-1:0]         ALU_write_data_CTL_synced,
    output  wire    [DEFAULT_OFFSET_WORD_WIDTH-1:0]         ALU_write_data_DO_synced,
    output  wire    [PROGRAMMED_OFFSETS_WORD_WIDTH-1:0]     ALU_write_data_PO_synced,
    output  wire    [INCREMENTS_WORD_WIDTH-1:0]             ALU_write_data_INC_synced
);

    localparam PIPE_DEPTH = 2;

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (1)
    )
    BBC_wren
    (
        .clock  (clock),
        .in     (ALU_wren_BBC),
        .out    (ALU_wren_BBC_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (1)
    )
    CTL_wren
    (
        .clock  (clock),
        .in     (ALU_wren_CTL),
        .out    (ALU_wren_CTL_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (1)
    )
    DO_wren
    (
        .clock  (clock),
        .in     (ALU_wren_DO),
        .out    (ALU_wren_DO_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (1)
    )
    INC_wren
    (
        .clock  (clock),
        .in     (ALU_wren_INC),
        .out    (ALU_wren_INC_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (1)
    )
    PO_wren
    (
        .clock  (clock),
        .in     (ALU_wren_PO),
        .out    (ALU_wren_PO_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (ADDR_WIDTH)
    )
    write_addr
    (
        .clock  (clock),
        .in     (ALU_write_addr),
        .out    (ALU_write_addr_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (WORD_WIDTH)
    )
    write_data
    (
        .clock  (clock),
        .in     (ALU_write_data),
        .out    (ALU_write_data_synced)
    );

// -----------------------------------------------------------

    // ECL XXX Verilog needs real lists to make generate blocks really useful.

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (BASIC_BLOCK_COUNTER_WORD_WIDTH)
    )
    BBC_write_data
    (
        .clock  (clock),
        .in     (ALU_write_data_BBC),
        .out    (ALU_write_data_BBC_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (CONTROL_MEMORY_WORD_WIDTH)
    )
    CTL_write_data
    (
        .clock  (clock),
        .in     (ALU_write_data_CTL),
        .out    (ALU_write_data_CTL_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (DEFAULT_OFFSET_WORD_WIDTH)
    )
    DO_write_data
    (
        .clock  (clock),
        .in     (ALU_write_data_DO),
        .out    (ALU_write_data_DO_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (PROGRAMMED_OFFSETS_WORD_WIDTH)
    )
    PO_write_data
    (
        .clock  (clock),
        .in     (ALU_write_data_PO),
        .out    (ALU_write_data_PO_synced)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (PIPE_DEPTH),
        .WIDTH  (INCREMENTS_WORD_WIDTH)
    )
    INC_write_data
    (
        .clock  (clock),
        .in     (ALU_write_data_INC),
        .out    (ALU_write_data_INC_synced)
    );

endmodule

