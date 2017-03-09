
module Generic_test_harness
#(
    // Instruction format
    parameter       INSTRUCTION_WIDTH               = 36,
    parameter       OPCODE_WIDTH                    = 4,
    parameter       D_OPERAND_WIDTH                 = 12,
    parameter       A_OPERAND_WIDTH                 = 10,
    parameter       B_OPERAND_WIDTH                 = 10,
    // Instruction Mem
    parameter       IMEM_WORD_WIDTH                 = 36,
    parameter       IMEM_ADDR_WIDTH                 = 10,
    parameter       IMEM_READ_NEW                   = 0,
    parameter       IMEM_DEPTH                      = 1024,
    parameter       IMEM_RAMSTYLE                   = "M10K,no_rw_check",
    parameter       IMEM_INIT_FILE                  = "empty.imem",
    // Control Mem Individual sub-RAMs
    parameter       CMEM_RAMSTYLE                   = "MLAB,no_rw_check",
    parameter       CMEM_READ_NEW_DATA              = 0,
    parameter       CMEM_SUB_INIT_FILE              = "empty.cmem",
    parameter       CMEM_SUB_ADDR_WIDTH             = 5,
    parameter       CMEM_SUB_DEPTH                  = 32,
    parameter       CMEM_WORD_WIDTH                 = 20,
    // Multithreading
    parameter       THREAD_COUNT                    = 8,
    parameter       THREAD_COUNT_WIDTH              = 3

)
(
    input   wire    clock,
    input   wire    test_in,
    output  wire    test_out
);

// --------------------------------------------------------------------

    localparam INPUT_WIDTH  = 1 + IMEM_ADDR_WIDTH + IMEM_WORD_WIDTH + 1 + IMEM_ADDR_WIDTH + 1 + OPCODE_WIDTH + CMEM_WORD_WIDTH;
    localparam OUTPUT_WIDTH = IMEM_WORD_WIDTH + IMEM_WORD_WIDTH + CMEM_WORD_WIDTH + CMEM_WORD_WIDTH;

    wire    [INPUT_WIDTH-1:0]   test_input;
    reg     [OUTPUT_WIDTH-1:0]  test_output;

// --------------------------------------------------------------------

    reg                                     imem_wren           = 0;   
    reg     [IMEM_ADDR_WIDTH-1:0]           imem_write_addr     = 0;
    reg     [IMEM_WORD_WIDTH-1:0]           imem_write_data     = 0;
    reg                                     imem_rden           = 0;
    reg     [IMEM_ADDR_WIDTH-1:0]           imem_read_addr      = 0;
    wire    [IMEM_WORD_WIDTH-1:0]           imem_read_data;
    wire    [IMEM_WORD_WIDTH-1:0]           imem_read_data_reg;
    reg                                     cmem_wren           = 0;
    reg     [OPCODE_WIDTH-1:0]              cmem_write_addr     = 0;
    reg     [CMEM_WORD_WIDTH-1:0]           cmem_write_data     = 0;
    wire    [CMEM_WORD_WIDTH-1:0]           cmem_read_data;
    wire    [CMEM_WORD_WIDTH-1:0]           cmem_read_data_reg;
    

    always @(*) begin
        {imem_wren,imem_write_addr,imem_write_data,imem_rden,imem_read_addr,cmem_wren,cmem_write_addr,cmem_write_data} <= test_input;
        test_output <= {imem_write_data,imem_read_data_reg,cmem_read_data,cmem_read_data_reg};
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

    Instruction_Memory
    #(
        // Instruction format
        .INSTRUCTION_WIDTH      (INSTRUCTION_WIDTH),
        .OPCODE_WIDTH           (OPCODE_WIDTH),
        .D_OPERAND_WIDTH        (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH        (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH        (B_OPERAND_WIDTH),
        // Instruction Mem
        .IMEM_WORD_WIDTH        (IMEM_WORD_WIDTH),
        .IMEM_ADDR_WIDTH        (IMEM_ADDR_WIDTH),
        .IMEM_READ_NEW          (IMEM_READ_NEW),
        .IMEM_DEPTH             (IMEM_DEPTH),
        .IMEM_RAMSTYLE          (IMEM_RAMSTYLE),
        .IMEM_INIT_FILE         (IMEM_INIT_FILE),
        // Control Mem Individual sub-RAMs
        .CMEM_RAMSTYLE          (CMEM_RAMSTYLE),
        .CMEM_READ_NEW_DATA     (CMEM_READ_NEW_DATA),
        .CMEM_SUB_INIT_FILE     (CMEM_SUB_INIT_FILE),
        .CMEM_SUB_ADDR_WIDTH    (CMEM_SUB_ADDR_WIDTH),
        .CMEM_SUB_DEPTH         (CMEM_SUB_DEPTH),
        .CMEM_WORD_WIDTH        (CMEM_WORD_WIDTH),
        // Multithreading
        .THREAD_COUNT           (THREAD_COUNT),
        .THREAD_COUNT_WIDTH     (THREAD_COUNT_WIDTH)
    )
    IMEM
    (
        .clock                  (clock),
        .imem_wren              (imem_wren),
        .imem_write_addr        (imem_write_addr),
        .imem_write_data        (imem_write_data),
        .imem_rden              (imem_rden),
        .imem_read_addr         (imem_read_addr),
        .imem_read_data         (imem_read_data),
        .imem_read_data_reg     (imem_read_data_reg),
        .cmem_wren              (cmem_wren),
        .cmem_write_addr        (cmem_write_addr),
        .cmem_write_data        (cmem_write_data),
        .cmem_read_data         (cmem_read_data),
        .cmem_read_data_reg     (cmem_read_data_reg)
    );

endmodule

