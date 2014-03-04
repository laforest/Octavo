module ControlPath
#(
    parameter   ALU_WORD_WIDTH                  = 0,

    parameter   INSTR_WIDTH                     = 0,
    parameter   D_OPERAND_WIDTH                 = 0,

    parameter   I_WRITE_ADDR_OFFSET             = 0,
    parameter   I_WORD_WIDTH                    = 0,
    parameter   I_ADDR_WIDTH                    = 0,
    parameter   I_DEPTH                         = 0,
    parameter   I_RAMSTYLE                      = "",
    parameter   I_INIT_FILE                     = "",

    parameter   PC_RAMSTYLE                     = "",
    parameter   PC_INIT_FILE                    = "",
    parameter   THREAD_COUNT                    = 0, 
    parameter   THREAD_ADDR_WIDTH               = 0, 

    parameter   I_TAP_PIPELINE_DEPTH            = 0,
    parameter   AB_READ_PIPELINE_DEPTH          = 0,

    parameter   ORIGIN_WRITE_WORD_OFFSET        = 0,
    parameter   ORIGIN_WRITE_ADDR_OFFSET        = 0,
    parameter   ORIGIN_WORD_WIDTH               = 0,
    parameter   ORIGIN_ADDR_WIDTH               = 0,
    parameter   ORIGIN_DEPTH                    = 0,
    parameter   ORIGIN_RAMSTYLE                 = 0,
    parameter   ORIGIN_INIT_FILE                = 0,

    parameter   BRANCH_COUNT                    = 0,

    parameter   DESTINATION_WRITE_WORD_OFFSET   = 0,
    parameter   DESTINATION_WRITE_ADDR_OFFSET   = 0,
    parameter   DESTINATION_WORD_WIDTH          = 0,
    parameter   DESTINATION_ADDR_WIDTH          = 0,
    parameter   DESTINATION_DEPTH               = 0,
    parameter   DESTINATION_RAMSTYLE            = 0,
    parameter   DESTINATION_INIT_FILE           = 0,

    parameter   CONDITION_WRITE_WORD_OFFSET     = 0,
    parameter   CONDITION_WRITE_ADDR_OFFSET     = 0,
    parameter   CONDITION_WORD_WIDTH            = 0,
    parameter   CONDITION_ADDR_WIDTH            = 0,
    parameter   CONDITION_DEPTH                 = 0,
    parameter   CONDITION_RAMSTYLE              = 0,
    parameter   CONDITION_INIT_FILE             = 0,

    parameter   FLAGS_WORD_WIDTH                = 0,
    parameter   FLAGS_ADDR_WIDTH                = 0

)
(
    input   wire                                clock,

    input   wire                                I_wren_other,
    input   wire    [D_OPERAND_WIDTH-1:0]       ALU_write_addr,
    input   wire    [ALU_WORD_WIDTH-1:0]        ALU_write_data,
    input   wire                                IO_ready,

    output  wire    [INSTR_WIDTH-1:0]           I_read_data
);

// -----------------------------------------------------------

    wire    I_wren_raw;

    Address_Decoder
    #(
        .ADDR_COUNT     (I_DEPTH),
        .ADDR_BASE      (I_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    I_mem_wren
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (I_wren_raw)
    );

// -----------------------------------------------------------

    reg     I_wren;

    always @(*) begin
        I_wren <= I_wren_raw & I_wren_other;
    end

// -----------------------------------------------------------

    wire    [INSTR_WIDTH-1:0]       I_read_data_bram;

    RAM_SDP
    #(
        .WORD_WIDTH     (I_WORD_WIDTH),
        .ADDR_WIDTH     (I_ADDR_WIDTH),
        .DEPTH          (I_DEPTH),
        .RAMSTYLE       (I_RAMSTYLE),
        .INIT_FILE      (I_INIT_FILE)
    )
    I_mem
    (
        .clock          (clock),
        .wren           (I_wren),
        .write_addr     (ALU_write_addr[I_ADDR_WIDTH-1:0]),
        .write_data     (ALU_write_data[I_WORD_WIDTH-1:0]),
        .read_addr      (I_read_addr),
        .read_data      (I_read_data_bram)
    );

// -----------------------------------------------------------

    // This stage should get retimed into the BRAM for higher Fmax.
    // ECL XXX Sacrosanct! Don't remove this pipeline stage, or connect before it.
    // Else it tends to create a critical path.
    delay_line 
    #(
        .DEPTH  (I_TAP_PIPELINE_DEPTH),
        .WIDTH  (INSTR_WIDTH)
    ) 
    I_TAP_pipeline
    (
        .clock  (clock),
        .in     (I_read_data_bram),
        .out    (I_read_data)
    );

// -----------------------------------------------------------

    wire    IO_ready_ctrl;

    // Synchronize with A/B memory reads.
    delay_line 
    #(
        .DEPTH  (AB_READ_PIPELINE_DEPTH),
        .WIDTH  (1)
    ) 
    AB_IO_ready_pipeline
    (
        .clock  (clock),
        .in     (IO_ready),
        .out    (IO_ready_ctrl)
    );

// -----------------------------------------------------------

    wire    [I_ADDR_WIDTH-1:0]  PC;
    wire    [I_ADDR_WIDTH-1:0]  branch_destination;
    wire                        jump;

    Branch_Folding
    #(
        .PC_WIDTH                       (I_ADDR_WIDTH),
        .D_OPERAND_WIDTH                (D_OPERAND_WIDTH),
        .WORD_WIDTH                     (ALU_WORD_WIDTH),

        .INITIAL_THREAD                 (5), // ECL XXX Hardcoded!!!
        .THREAD_COUNT                   (THREAD_COUNT),
        .THREAD_ADDR_WIDTH              (THREAD_ADDR_WIDTH),

        .ORIGIN_WRITE_WORD_OFFSET       (ORIGIN_WRITE_WORD_OFFSET),
        .ORIGIN_WRITE_ADDR_OFFSET       (ORIGIN_WRITE_ADDR_OFFSET),
        .ORIGIN_WORD_WIDTH              (ORIGIN_WORD_WIDTH),
        .ORIGIN_ADDR_WIDTH              (ORIGIN_ADDR_WIDTH),
        .ORIGIN_DEPTH                   (ORIGIN_DEPTH),
        .ORIGIN_RAMSTYLE                (ORIGIN_RAMSTYLE),
        .ORIGIN_INIT_FILE               (ORIGIN_INIT_FILE),

        .BRANCH_COUNT                   (BRANCH_COUNT),

        .DESTINATION_WRITE_WORD_OFFSET  (DESTINATION_WRITE_WORD_OFFSET),
        .DESTINATION_WRITE_ADDR_OFFSET  (DESTINATION_WRITE_ADDR_OFFSET),
        .DESTINATION_WORD_WIDTH         (DESTINATION_WORD_WIDTH),
        .DESTINATION_ADDR_WIDTH         (DESTINATION_ADDR_WIDTH),
        .DESTINATION_DEPTH              (DESTINATION_DEPTH),
        .DESTINATION_RAMSTYLE           (DESTINATION_RAMSTYLE),
        .DESTINATION_INIT_FILE          (DESTINATION_INIT_FILE),

        .CONDITION_WRITE_WORD_OFFSET    (CONDITION_WRITE_WORD_OFFSET),
        .CONDITION_WRITE_ADDR_OFFSET    (CONDITION_WRITE_ADDR_OFFSET),
        .CONDITION_WORD_WIDTH           (CONDITION_WORD_WIDTH),
        .CONDITION_ADDR_WIDTH           (CONDITION_ADDR_WIDTH),
        .CONDITION_DEPTH                (CONDITION_DEPTH),
        .CONDITION_RAMSTYLE             (CONDITION_RAMSTYLE),
        .CONDITION_INIT_FILE            (CONDITION_INIT_FILE),

        .FLAGS_WORD_WIDTH               (FLAGS_WORD_WIDTH),
        .FLAGS_ADDR_WIDTH               (FLAGS_ADDR_WIDTH)
    )
    BF
    (
        .clock                          (clock),
        .PC                             (PC),
        .R_prev                         (ALU_write_data),
        .IO_ready                       (IO_ready),

        .ALU_write_addr                 (ALU_write_addr),
        .ALU_write_data                 (ALU_write_data),

        .branch_destination             (branch_destination),
        .jump                           (jump)
    );

// -----------------------------------------------------------

    Controller
    #(
        .PC_WIDTH           (I_ADDR_WIDTH), 
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH),
        .THREAD_COUNT       (THREAD_COUNT),
        .RAMSTYLE           (PC_RAMSTYLE), 
        .INIT_FILE          (PC_INIT_FILE)
    )
    Controller
    (
        .clock              (clock),
        .branch_destination (branch_destination),
        .jump               (jump),
        .IO_ready           (IO_ready_ctrl),
        .PC                 (PC) 
    );

endmodule

