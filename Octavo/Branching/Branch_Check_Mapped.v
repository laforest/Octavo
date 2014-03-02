
// Wraps Branch_Check with memory mapping hardware.

module Branch_Check_Mapped
#(
    parameter   PC_WIDTH                            = 0,
    parameter   D_OPERAND_WIDTH                     = 0,
    parameter   WORD_WIDTH                          = 0,

    parameter   INITIAL_THREAD                      = 0,
    parameter   THREAD_COUNT                        = 0,
    parameter   THREAD_ADDR_WIDTH                   = 0,

    parameter   ORIGIN_WRITE_WORD_OFFSET            = 0,
    parameter   ORIGIN_WRITE_ADDR_OFFSET            = 0,
    parameter   ORIGIN_WORD_WIDTH                   = 0,
    parameter   ORIGIN_ADDR_WIDTH                   = 0,
    parameter   ORIGIN_DEPTH                        = 0,
    parameter   ORIGIN_RAMSTYLE                     = 0,
    parameter   ORIGIN_INIT_FILE                    = 0,

    parameter   DESTINATION_WRITE_WORD_OFFSET       = 0,
    parameter   DESTINATION_WRITE_ADDR_OFFSET       = 0,
    parameter   DESTINATION_WORD_WIDTH              = 0,
    parameter   DESTINATION_ADDR_WIDTH              = 0,
    parameter   DESTINATION_DEPTH                   = 0,
    parameter   DESTINATION_RAMSTYLE                = 0,
    parameter   DESTINATION_INIT_FILE               = 0,

    parameter   CONDITION_WRITE_WORD_OFFSET         = 0,
    parameter   CONDITION_WRITE_ADDR_OFFSET         = 0,
    parameter   CONDITION_WORD_WIDTH                = 0,
    parameter   CONDITION_ADDR_WIDTH                = 0,
    parameter   CONDITION_DEPTH                     = 0,
    parameter   CONDITION_RAMSTYLE                  = 0,
    parameter   CONDITION_INIT_FILE                 = 0,

    parameter   FLAGS_WRITE_WORD_OFFSET             = 0,
    parameter   FLAGS_WRITE_ADDR_OFFSET             = 0,
    parameter   FLAGS_WORD_WIDTH                    = 0,
    parameter   FLAGS_ADDR_WIDTH                    = 0
)
(
    input   wire                                    clock,
    input   wire    [PC_WIDTH-1:0]                  PC,
    input   wire    [FLAGS_WORD_WIDTH-1:0]          flags,
    input   wire                                    IO_ready_previous,
    input   wire                                    jump_previous,

    input   wire    [D_OPERAND_WIDTH-1:0]           ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]                ALU_write_data,

    output  wire    [PC_WIDTH-1:0]                  branch_destination,
    output  wire                                    jump
);

// -----------------------------------------------------------

    // Subsets of above, so we can align multiple memories along a single word.
    // We want to keep all memory map knowledge in *this* module.
    wire    [ORIGIN_WORD_WIDTH-1:0]         ALU_write_data_BO,
    wire    [DESTINATION_WORD_WIDTH-1:0]    ALU_write_data_BD,
    wire    [CONDITION_WORD_WIDTH-1:0]      ALU_write_data_BC,

    always @(*) begin
        ALU_write_data_BO  <= ALU_write_data[ORIGIN_WORD_WIDTH + ORIGIN_WRITE_WORD_OFFSET-1:ORIGIN_WRITE_WORD_OFFSET];
        ALU_write_data_BD  <= ALU_write_data[DESTINATION_WORD_WIDTH + DESTINATION_WRITE_WORD_OFFSET-1:DESTINATION_WRITE_WORD_OFFSET];
        ALU_write_data_BC <= ALU_write_data[CONDITION_WORD_WIDTH + CONDITION_WRITE_WORD_OFFSET-1:CONDITION_WRITE_WORD_OFFSET];
    end

// -----------------------------------------------------------

    wire    ALU_wren_BO; // Branch Origin

    Address_Decoder
    #(
        .ADDR_COUNT     (ORIGIN_DEPTH),
        .ADDR_BASE      (ORIGIN_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    BO
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_BO)
    );

// -----------------------------------------------------------

    wire    ALU_wren_BD; // Branch Destination

    Address_Decoder
    #(
        .ADDR_COUNT     (DESTINATION_DEPTH),
        .ADDR_BASE      (DESTINATION_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    BD
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_DO)
    );

// -----------------------------------------------------------

    wire    ALU_wren_BC; // Branch Condition

    Address_Decoder
    #(
        .ADDR_COUNT     (CONDITION_DEPTH),
        .ADDR_BASE      (CONDITION_WRITE_ADDR_OFFSET),
        .ADDR_WIDTH     (D_OPERAND_WIDTH),
        .REGISTERED     (`FALSE)
    )
    BC
    (
        .clock          (clock),
        .addr           (ALU_write_addr),
        .hit            (ALU_wren_BC)
    );

// -----------------------------------------------------------

    Branch_Check
    #(
        .PC_WIDTH                   (PC_WIDTH),
        .D_OPERAND_WIDTH            (D_OPERAND_WIDTH),
        .WORD_WIDTH                 (WORD_WIDTH),

        .INITIAL_THREAD             (INITIAL_THREAD),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH          (THREAD_ADDR_WIDTH),

        .ORIGIN_WORD_WIDTH          (ORIGIN_WORD_WIDTH),
        .ORIGIN_ADDR_WIDTH          (ORIGIN_ADDR_WIDTH),
        .ORIGIN_DEPTH               (ORIGIN_DEPTH),
        .ORIGIN_RAMSTYLE            (ORIGIN_RAMSTYLE),
        .ORIGIN_INIT_FILE           (ORIGIN_INIT_FILE),

        .DESTINATION_WORD_WIDTH     (DESTINATION_WORD_WIDTH),
        .DESTINATION_ADDR_WIDTH     (DESTINATION_ADDR_WIDTH),
        .DESTINATION_DEPTH          (DESTINATION_DEPTH),
        .DESTINATION_RAMSTYLE       (DESTINATION_RAMSTYLE),
        .DESTINATION_INIT_FILE      (DESTINATION_INIT_FILE),

        .CONDITION_WORD_WIDTH       (CONDITION_WORD_WIDTH),
        .CONDITION_ADDR_WIDTH       (CONDITION_ADDR_WIDTH),
        .CONDITION_DEPTH            (CONDITION_DEPTH),
        .CONDITION_RAMSTYLE         (CONDITION_RAMSTYLE),
        .CONDITION_INIT_FILE        (CONDITION_INIT_FILE),

        .FLAGS_WORD_WIDTH           (FLAGS_WORD_WIDTH),
        .FLAGS_ADDR_WIDTH           (FLAGS_ADDR_WIDTH)
    )
    Branch_Check
    (
        .clock                      (clock),
        .PC                         (PC),
        .flags,
        .IO_ready_previous          (IO_ready_previous),
        .jump_previous              (jump_previous),

        .ALU_wren_BO                (ALU_wren_BO),
        .ALU_wren_BD                (ALU_wren_BD),
        .ALU_wren_BC                (ALU_wren_BC),

        .ALU_write_addr             (ALU_write_addr),

        .ALU_write_data_BO          (ALU_write_data_BO),
        .ALU_write_data_BD          (ALU_write_data_BD),
        .ALU_write_data_BC          (ALU_write_data_BC),

        .branch_destination         (branch_destination),
        .jump                       (jump)
    );

endmodule

