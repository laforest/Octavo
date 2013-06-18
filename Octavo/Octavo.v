
// Octavo CPU. I/O lines are flat vectors of words.
// Wrap as necessary to break-out I/O ports and set parameters.
// Specify (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER) > 0 for a SIMD core.
// Adjust SIMD_* for SIMD paths that differ from main Datapath.

module Octavo
#(
    parameter       ALU_WORD_WIDTH                      = 0,
    parameter       SIMD_ALU_WORD_WIDTH                 = 0,

    parameter       INSTR_WIDTH                         = 0,
    parameter       OPCODE_WIDTH                        = 0,
    parameter       D_OPERAND_WIDTH                     = 0,
    parameter       A_OPERAND_WIDTH                     = 0,
    parameter       B_OPERAND_WIDTH                     = 0,

    parameter       A_WORD_WIDTH                        = 0,
    parameter       A_ADDR_WIDTH                        = 0,
    parameter       A_DEPTH                             = 0,
    parameter       A_RAMSTYLE                          = "",
    parameter       A_INIT_FILE                         = "",
    parameter       A_IO_READ_PORT_COUNT                = 0,
    parameter       A_IO_READ_PORT_BASE_ADDR            = 0,
    parameter       A_IO_READ_PORT_ADDR_WIDTH           = 0,
    parameter       A_IO_WRITE_PORT_COUNT               = 0,
    parameter       A_IO_WRITE_PORT_BASE_ADDR           = 0,
    parameter       A_IO_WRITE_PORT_ADDR_WIDTH          = 0,

    parameter       SIMD_A_WORD_WIDTH                   = 0,
    parameter       SIMD_A_ADDR_WIDTH                   = 0,
    parameter       SIMD_A_DEPTH                        = 0,
    parameter       SIMD_A_RAMSTYLE                     = "",
    parameter       SIMD_A_INIT_FILE                    = "",
    parameter       SIMD_A_IO_READ_PORT_COUNT           = 0,
    parameter       SIMD_A_IO_READ_PORT_BASE_ADDR       = 0,
    parameter       SIMD_A_IO_READ_PORT_ADDR_WIDTH      = 0,
    parameter       SIMD_A_IO_WRITE_PORT_COUNT          = 0,
    parameter       SIMD_A_IO_WRITE_PORT_BASE_ADDR      = 0,
    parameter       SIMD_A_IO_WRITE_PORT_ADDR_WIDTH     = 0,

    parameter       B_WORD_WIDTH                        = 0,
    parameter       B_ADDR_WIDTH                        = 0,
    parameter       B_DEPTH                             = 0,
    parameter       B_RAMSTYLE                          = "",
    parameter       B_INIT_FILE                         = "",
    parameter       B_IO_READ_PORT_COUNT                = 0,
    parameter       B_IO_READ_PORT_BASE_ADDR            = 0,
    parameter       B_IO_READ_PORT_ADDR_WIDTH           = 0,
    parameter       B_IO_WRITE_PORT_COUNT               = 0,
    parameter       B_IO_WRITE_PORT_BASE_ADDR           = 0,
    parameter       B_IO_WRITE_PORT_ADDR_WIDTH          = 0,

    parameter       SIMD_B_WORD_WIDTH                   = 0,
    parameter       SIMD_B_ADDR_WIDTH                   = 0,
    parameter       SIMD_B_DEPTH                        = 0,
    parameter       SIMD_B_RAMSTYLE                     = "",
    parameter       SIMD_B_INIT_FILE                    = "",
    parameter       SIMD_B_IO_READ_PORT_COUNT           = 0,
    parameter       SIMD_B_IO_READ_PORT_BASE_ADDR       = 0,
    parameter       SIMD_B_IO_READ_PORT_ADDR_WIDTH      = 0,
    parameter       SIMD_B_IO_WRITE_PORT_COUNT          = 0,
    parameter       SIMD_B_IO_WRITE_PORT_BASE_ADDR      = 0,
    parameter       SIMD_B_IO_WRITE_PORT_ADDR_WIDTH     = 0,

    parameter       I_WORD_WIDTH                        = 0,
    parameter       I_ADDR_WIDTH                        = 0,
    parameter       I_DEPTH                             = 0,
    parameter       I_RAMSTYLE                          = "",
    parameter       I_INIT_FILE                         = "",

    parameter       PC_RAMSTYLE                         = "",
    parameter       PC_INIT_FILE                        = "",
    parameter       THREAD_COUNT                        = 0, 
    parameter       THREAD_ADDR_WIDTH                   = 0, 

    parameter       PC_PIPELINE_DEPTH                   = 0,
    parameter       I_TAP_PIPELINE_DEPTH                = 0,
    parameter       TAP_AB_PIPELINE_DEPTH               = 0,
    parameter       I_PASSTHRU_PIPELINE_DEPTH           = 0,
    parameter       AB_READ_PIPELINE_DEPTH              = 0,
    parameter       AB_ALU_PIPELINE_DEPTH               = 0,

    parameter       SIMD_I_PASSTHRU_PIPELINE_DEPTH      = 0,
    parameter       SIMD_TAP_AB_PIPELINE_DEPTH          = 0,

    parameter       LOGIC_OPCODE_WIDTH                  = 0,
    parameter       ADDSUB_CARRY_SELECT                 = 0,
    parameter       MULT_DOUBLE_PIPE                    = 0,
    parameter       MULT_HETEROGENEOUS                  = 0,    
    parameter       MULT_USE_DSP                        = 0,

    parameter       SIMD_ADDSUB_CARRY_SELECT            = 0,
    parameter       SIMD_MULT_DOUBLE_PIPE               = 0,
    parameter       SIMD_MULT_HETEROGENEOUS             = 0,    
    parameter       SIMD_MULT_USE_DSP                   = 0,

    parameter       SIMD_LAYER_COUNT                    = 0,
    parameter       SIMD_LANES_PER_LAYER                = 0
)
(
    input   wire                                                                                                                                                    clock,
    input   wire                                                                                                                                                    half_clock,

    // Memory write enables for external control by accelerators
    input   wire                                                                                                                                                    I_wren_other,
    input   wire    [(SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER):0]                                                                                                   A_wren_other,
    input   wire    [(SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER):0]                                                                                                   B_wren_other,
    
    // ALU AddSub carry-in/out for external control by accelerators
    input   wire    [(SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER):0]                                                                                                   ALU_c_in,
    output  wire    [(SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER):0]                                                                                                   ALU_c_out,

    // Group I/O:    *****************Main*****************    ************************************SIMD*******************************
    output  wire    [((               A_IO_READ_PORT_COUNT)  + (                    SIMD_A_IO_READ_PORT_COUNT  * (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER)))-1:0]   A_io_rden,
    input   wire    [((A_WORD_WIDTH * A_IO_READ_PORT_COUNT)  + (SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT  * (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER)))-1:0]   A_io_in,
    output  wire    [((               A_IO_WRITE_PORT_COUNT) + (                    SIMD_A_IO_WRITE_PORT_COUNT * (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER)))-1:0]   A_io_wren,
    output  wire    [((A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT) + (SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT * (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER)))-1:0]   A_io_out,

    output  wire    [((               B_IO_READ_PORT_COUNT)  + (                    SIMD_B_IO_READ_PORT_COUNT  * (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER)))-1:0]   B_io_rden,
    input   wire    [((B_WORD_WIDTH * B_IO_READ_PORT_COUNT)  + (SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT  * (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER)))-1:0]   B_io_in,
    output  wire    [((               B_IO_WRITE_PORT_COUNT) + (                    SIMD_B_IO_WRITE_PORT_COUNT * (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER)))-1:0]   B_io_wren,
    output  wire    [((B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT) + (SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT * (SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER)))-1:0]   B_io_out
);
    // Instruction common to all Datapaths
    wire    [INSTR_WIDTH-1:0]                   I_read_data;

    Scalar
    #(
        .ALU_WORD_WIDTH             (ALU_WORD_WIDTH),

        .INSTR_WIDTH                (INSTR_WIDTH),
        .OPCODE_WIDTH               (OPCODE_WIDTH),
        .D_OPERAND_WIDTH            (D_OPERAND_WIDTH),
        .A_OPERAND_WIDTH            (A_OPERAND_WIDTH),
        .B_OPERAND_WIDTH            (B_OPERAND_WIDTH),

        .A_WORD_WIDTH               (A_WORD_WIDTH),
        .A_ADDR_WIDTH               (A_ADDR_WIDTH),
        .A_DEPTH                    (A_DEPTH),
        .A_RAMSTYLE                 (A_RAMSTYLE),
        .A_INIT_FILE                (A_INIT_FILE),
        .A_IO_READ_PORT_COUNT       (A_IO_READ_PORT_COUNT),
        .A_IO_READ_PORT_BASE_ADDR   (A_IO_READ_PORT_BASE_ADDR),
        .A_IO_READ_PORT_ADDR_WIDTH  (A_IO_READ_PORT_ADDR_WIDTH),
        .A_IO_WRITE_PORT_COUNT      (A_IO_WRITE_PORT_COUNT),
        .A_IO_WRITE_PORT_BASE_ADDR  (A_IO_WRITE_PORT_BASE_ADDR),
        .A_IO_WRITE_PORT_ADDR_WIDTH (A_IO_WRITE_PORT_ADDR_WIDTH),

        .B_WORD_WIDTH               (B_WORD_WIDTH),
        .B_ADDR_WIDTH               (B_ADDR_WIDTH),
        .B_DEPTH                    (B_DEPTH),
        .B_RAMSTYLE                 (B_RAMSTYLE),
        .B_INIT_FILE                (B_INIT_FILE),
        .B_IO_READ_PORT_COUNT       (B_IO_READ_PORT_COUNT),
        .B_IO_READ_PORT_BASE_ADDR   (B_IO_READ_PORT_BASE_ADDR),
        .B_IO_READ_PORT_ADDR_WIDTH  (B_IO_READ_PORT_ADDR_WIDTH),
        .B_IO_WRITE_PORT_COUNT      (B_IO_WRITE_PORT_COUNT),
        .B_IO_WRITE_PORT_BASE_ADDR  (B_IO_WRITE_PORT_BASE_ADDR),
        .B_IO_WRITE_PORT_ADDR_WIDTH (B_IO_WRITE_PORT_ADDR_WIDTH),

        .I_WORD_WIDTH               (I_WORD_WIDTH),
        .I_ADDR_WIDTH               (I_ADDR_WIDTH),
        .I_DEPTH                    (I_DEPTH),
        .I_RAMSTYLE                 (I_RAMSTYLE),
        .I_INIT_FILE                (I_INIT_FILE),

        .PC_RAMSTYLE                (PC_RAMSTYLE),
        .PC_INIT_FILE               (PC_INIT_FILE),
        .THREAD_COUNT               (THREAD_COUNT),
        .THREAD_ADDR_WIDTH          (THREAD_ADDR_WIDTH),

        .PC_PIPELINE_DEPTH          (PC_PIPELINE_DEPTH),
        .I_TAP_PIPELINE_DEPTH       (I_TAP_PIPELINE_DEPTH),
        .TAP_AB_PIPELINE_DEPTH      (TAP_AB_PIPELINE_DEPTH),
        .I_PASSTHRU_PIPELINE_DEPTH  (I_PASSTHRU_PIPELINE_DEPTH),
        .AB_READ_PIPELINE_DEPTH     (AB_READ_PIPELINE_DEPTH),
        .AB_ALU_PIPELINE_DEPTH      (AB_ALU_PIPELINE_DEPTH),

        .LOGIC_OPCODE_WIDTH         (LOGIC_OPCODE_WIDTH),
        .ADDSUB_CARRY_SELECT        (ADDSUB_CARRY_SELECT),
        .MULT_DOUBLE_PIPE           (MULT_DOUBLE_PIPE),
        .MULT_HETEROGENEOUS         (MULT_HETEROGENEOUS),
        .MULT_USE_DSP               (MULT_USE_DSP)
    )
    Scalar
    (
        .clock                      (clock),
        .half_clock                 (half_clock),

        .I_wren_other               (I_wren_other),
        .A_wren_other               (A_wren_other[0]),
        .B_wren_other               (B_wren_other[0]),
        
        .ALU_c_in                   (ALU_c_in [0]),
        .ALU_c_out                  (ALU_c_out[0]),

        .I_read_data                (I_read_data),

        .A_io_rden                  (A_io_rden[(               A_IO_READ_PORT_COUNT)-1:0]),
        .A_io_in                    (A_io_in  [(A_WORD_WIDTH * A_IO_READ_PORT_COUNT)-1:0]),
        .A_io_wren                  (A_io_wren[(               A_IO_WRITE_PORT_COUNT)-1:0]),
        .A_io_out                   (A_io_out [(A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT)-1:0]),

        .B_io_rden                  (B_io_rden[(               B_IO_READ_PORT_COUNT)-1:0]),
        .B_io_in                    (B_io_in  [(B_WORD_WIDTH * B_IO_READ_PORT_COUNT)-1:0]),
        .B_io_wren                  (B_io_wren[(               B_IO_WRITE_PORT_COUNT)-1:0]),
        .B_io_out                   (B_io_out [(B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT)-1:0])
    );

    generate
        if (SIMD_LAYER_COUNT > 0 && SIMD_LANES_PER_LAYER > 0) begin : SIMD_Layer_last
            localparam SIMD_LANES   = SIMD_LAYER_COUNT * SIMD_LANES_PER_LAYER;
            localparam PLAIN_LAYERS = SIMD_LAYER_COUNT - 1;
            localparam PLAIN_LANES  = PLAIN_LAYERS * SIMD_LANES_PER_LAYER;
            localparam LAST_LAYER_BASE = SIMD_LANES - SIMD_LANES_PER_LAYER + 1;
            
            // Instruction pipeline wiring for all layers but the last
            // Plus one stage for output to last layer wiring
            localparam SIMD_I_read_data_Layers_WIDTH = ((INSTR_WIDTH * PLAIN_LAYERS) + INSTR_WIDTH);
            wire [SIMD_I_read_data_Layers_WIDTH-1:0] SIMD_I_read_data_Layers;
            // Connect instruction distribution to the first layer
            assign SIMD_I_read_data_Layers[INSTR_WIDTH-1:0] = I_read_data;

            // Instruction pipeline wiring for last layer
            wire [INSTR_WIDTH-1:0] SIMD_I_read_data_Layer_last;
            // Connect instruction distribution to the last layer
            assign SIMD_I_read_data_Layer_last = SIMD_I_read_data_Layers[SIMD_I_read_data_Layers_WIDTH - INSTR_WIDTH +: INSTR_WIDTH];


            if (SIMD_LAYER_COUNT > 1 && SIMD_LANES_PER_LAYER > 0) begin : SIMD_Layers
                // All but the last layer
                SIMD
                #(
                    .SIMD_ALU_WORD_WIDTH                (SIMD_ALU_WORD_WIDTH),

                    .INSTR_WIDTH                        (INSTR_WIDTH),
                    .OPCODE_WIDTH                       (OPCODE_WIDTH),
                    .D_OPERAND_WIDTH                    (D_OPERAND_WIDTH),
                    .A_OPERAND_WIDTH                    (A_OPERAND_WIDTH),
                    .B_OPERAND_WIDTH                    (B_OPERAND_WIDTH),

                    .A_ADDR_WIDTH                       (A_ADDR_WIDTH),
                    .B_ADDR_WIDTH                       (B_ADDR_WIDTH),

                    .SIMD_A_WORD_WIDTH                  (SIMD_A_WORD_WIDTH),
                    .SIMD_A_ADDR_WIDTH                  (SIMD_A_ADDR_WIDTH),
                    .SIMD_A_DEPTH                       (SIMD_A_DEPTH),
                    .SIMD_A_RAMSTYLE                    (SIMD_A_RAMSTYLE),
                    .SIMD_A_INIT_FILE                   (SIMD_A_INIT_FILE),
                    .SIMD_A_IO_READ_PORT_COUNT          (SIMD_A_IO_READ_PORT_COUNT),
                    .SIMD_A_IO_READ_PORT_BASE_ADDR      (SIMD_A_IO_READ_PORT_BASE_ADDR),
                    .SIMD_A_IO_READ_PORT_ADDR_WIDTH     (SIMD_A_IO_READ_PORT_ADDR_WIDTH),
                    .SIMD_A_IO_WRITE_PORT_COUNT         (SIMD_A_IO_WRITE_PORT_COUNT),
                    .SIMD_A_IO_WRITE_PORT_BASE_ADDR     (SIMD_A_IO_WRITE_PORT_BASE_ADDR),
                    .SIMD_A_IO_WRITE_PORT_ADDR_WIDTH    (SIMD_A_IO_WRITE_PORT_ADDR_WIDTH),

                    .SIMD_B_WORD_WIDTH                  (SIMD_B_WORD_WIDTH),
                    .SIMD_B_ADDR_WIDTH                  (SIMD_B_ADDR_WIDTH),
                    .SIMD_B_DEPTH                       (SIMD_B_DEPTH),
                    .SIMD_B_RAMSTYLE                    (SIMD_B_RAMSTYLE),
                    .SIMD_B_INIT_FILE                   (SIMD_B_INIT_FILE),
                    .SIMD_B_IO_READ_PORT_COUNT          (SIMD_B_IO_READ_PORT_COUNT),
                    .SIMD_B_IO_READ_PORT_BASE_ADDR      (SIMD_B_IO_READ_PORT_BASE_ADDR),
                    .SIMD_B_IO_READ_PORT_ADDR_WIDTH     (SIMD_B_IO_READ_PORT_ADDR_WIDTH),
                    .SIMD_B_IO_WRITE_PORT_COUNT         (SIMD_B_IO_WRITE_PORT_COUNT),
                    .SIMD_B_IO_WRITE_PORT_BASE_ADDR     (SIMD_B_IO_WRITE_PORT_BASE_ADDR),
                    .SIMD_B_IO_WRITE_PORT_ADDR_WIDTH    (SIMD_B_IO_WRITE_PORT_ADDR_WIDTH),

                    .SIMD_I_PASSTHRU_PIPELINE_DEPTH     (SIMD_I_PASSTHRU_PIPELINE_DEPTH),
                    .SIMD_TAP_AB_PIPELINE_DEPTH         (SIMD_TAP_AB_PIPELINE_DEPTH),
                    .AB_READ_PIPELINE_DEPTH             (AB_READ_PIPELINE_DEPTH),
                    .AB_ALU_PIPELINE_DEPTH              (AB_ALU_PIPELINE_DEPTH),

                    .LOGIC_OPCODE_WIDTH                 (LOGIC_OPCODE_WIDTH),
                    .SIMD_ADDSUB_CARRY_SELECT           (SIMD_ADDSUB_CARRY_SELECT),
                    .SIMD_MULT_DOUBLE_PIPE              (SIMD_MULT_DOUBLE_PIPE),
                    .SIMD_MULT_HETEROGENEOUS            (SIMD_MULT_HETEROGENEOUS),    
                    .SIMD_MULT_USE_DSP                  (SIMD_MULT_USE_DSP), 

                    .SIMD_LANE_COUNT                    (SIMD_LANES_PER_LAYER)
                )
                Layers                                  [PLAIN_LAYERS-1:0]
                (
                    .clock                              (clock),
                    .half_clock                         (half_clock),

                    .A_wren_other                       (A_wren_other[PLAIN_LANES:1]),
                    .B_wren_other                       (B_wren_other[PLAIN_LANES:1]),

                    .ALU_c_in                           (ALU_c_in [PLAIN_LANES:1]),
                    .ALU_c_out                          (ALU_c_out[PLAIN_LANES:1]),

                    .I_read_data_in                     (SIMD_I_read_data_Layers[(SIMD_I_read_data_Layers_WIDTH - INSTR_WIDTH)-1 : 0          ]),
                    .I_read_data_out                    (SIMD_I_read_data_Layers[ SIMD_I_read_data_Layers_WIDTH               -1 : INSTR_WIDTH]),

                    .A_io_rden                          (A_io_rden[(                    SIMD_A_IO_READ_PORT_COUNT  * PLAIN_LANES) + (               A_IO_READ_PORT_COUNT)  -1 : (               A_IO_READ_PORT_COUNT)]),
                    .A_io_in                            (A_io_in  [(SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT  * PLAIN_LANES) + (A_WORD_WIDTH * A_IO_READ_PORT_COUNT)  -1 : (A_WORD_WIDTH * A_IO_READ_PORT_COUNT)]),
                    .A_io_wren                          (A_io_wren[(                    SIMD_A_IO_WRITE_PORT_COUNT * PLAIN_LANES) + (               A_IO_WRITE_PORT_COUNT) -1 : (               A_IO_WRITE_PORT_COUNT)]),
                    .A_io_out                           (A_io_out [(SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT * PLAIN_LANES) + (A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT) -1 : (A_WORD_WIDTH * A_IO_WRITE_PORT_COUNT)]),

                    .B_io_rden                          (B_io_rden[(                    SIMD_B_IO_READ_PORT_COUNT  * PLAIN_LANES) + (               B_IO_READ_PORT_COUNT)  -1 : (               B_IO_READ_PORT_COUNT)]),
                    .B_io_in                            (B_io_in  [(SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT  * PLAIN_LANES) + (B_WORD_WIDTH * B_IO_READ_PORT_COUNT)  -1 : (B_WORD_WIDTH * B_IO_READ_PORT_COUNT)]),
                    .B_io_wren                          (B_io_wren[(                    SIMD_B_IO_WRITE_PORT_COUNT * PLAIN_LANES) + (               B_IO_WRITE_PORT_COUNT) -1 : (               B_IO_WRITE_PORT_COUNT)]),
                    .B_io_out                           (B_io_out [(SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT * PLAIN_LANES) + (B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT) -1 : (B_WORD_WIDTH * B_IO_WRITE_PORT_COUNT)])
                );
            end

            // The last layer, which has no I_PASSTHRU pipeline (the registers would be wasted)
            SIMD
            #(
                .SIMD_ALU_WORD_WIDTH                (SIMD_ALU_WORD_WIDTH),

                .INSTR_WIDTH                        (INSTR_WIDTH),
                .OPCODE_WIDTH                       (OPCODE_WIDTH),
                .D_OPERAND_WIDTH                    (D_OPERAND_WIDTH),
                .A_OPERAND_WIDTH                    (A_OPERAND_WIDTH),
                .B_OPERAND_WIDTH                    (B_OPERAND_WIDTH),

                .A_ADDR_WIDTH                       (A_ADDR_WIDTH),
                .B_ADDR_WIDTH                       (B_ADDR_WIDTH),

                .SIMD_A_WORD_WIDTH                  (SIMD_A_WORD_WIDTH),
                .SIMD_A_ADDR_WIDTH                  (SIMD_A_ADDR_WIDTH),
                .SIMD_A_DEPTH                       (SIMD_A_DEPTH),
                .SIMD_A_RAMSTYLE                    (SIMD_A_RAMSTYLE),
                .SIMD_A_INIT_FILE                   (SIMD_A_INIT_FILE),
                .SIMD_A_IO_READ_PORT_COUNT          (SIMD_A_IO_READ_PORT_COUNT),
                .SIMD_A_IO_READ_PORT_BASE_ADDR      (SIMD_A_IO_READ_PORT_BASE_ADDR),
                .SIMD_A_IO_READ_PORT_ADDR_WIDTH     (SIMD_A_IO_READ_PORT_ADDR_WIDTH),
                .SIMD_A_IO_WRITE_PORT_COUNT         (SIMD_A_IO_WRITE_PORT_COUNT),
                .SIMD_A_IO_WRITE_PORT_BASE_ADDR     (SIMD_A_IO_WRITE_PORT_BASE_ADDR),
                .SIMD_A_IO_WRITE_PORT_ADDR_WIDTH    (SIMD_A_IO_WRITE_PORT_ADDR_WIDTH),

                .SIMD_B_WORD_WIDTH                  (SIMD_B_WORD_WIDTH),
                .SIMD_B_ADDR_WIDTH                  (SIMD_B_ADDR_WIDTH),
                .SIMD_B_DEPTH                       (SIMD_B_DEPTH),
                .SIMD_B_RAMSTYLE                    (SIMD_B_RAMSTYLE),
                .SIMD_B_INIT_FILE                   (SIMD_B_INIT_FILE),
                .SIMD_B_IO_READ_PORT_COUNT          (SIMD_B_IO_READ_PORT_COUNT),
                .SIMD_B_IO_READ_PORT_BASE_ADDR      (SIMD_B_IO_READ_PORT_BASE_ADDR),
                .SIMD_B_IO_READ_PORT_ADDR_WIDTH     (SIMD_B_IO_READ_PORT_ADDR_WIDTH),
                .SIMD_B_IO_WRITE_PORT_COUNT         (SIMD_B_IO_WRITE_PORT_COUNT),
                .SIMD_B_IO_WRITE_PORT_BASE_ADDR     (SIMD_B_IO_WRITE_PORT_BASE_ADDR),
                .SIMD_B_IO_WRITE_PORT_ADDR_WIDTH    (SIMD_B_IO_WRITE_PORT_ADDR_WIDTH),

                // Right here: no instruction passthru pipeline registers.
                .SIMD_I_PASSTHRU_PIPELINE_DEPTH     (0),
                .SIMD_TAP_AB_PIPELINE_DEPTH         (SIMD_TAP_AB_PIPELINE_DEPTH),
                .AB_READ_PIPELINE_DEPTH             (AB_READ_PIPELINE_DEPTH),
                .AB_ALU_PIPELINE_DEPTH              (AB_ALU_PIPELINE_DEPTH),

                .LOGIC_OPCODE_WIDTH                 (LOGIC_OPCODE_WIDTH),
                .SIMD_ADDSUB_CARRY_SELECT           (SIMD_ADDSUB_CARRY_SELECT),
                .SIMD_MULT_DOUBLE_PIPE              (SIMD_MULT_DOUBLE_PIPE),
                .SIMD_MULT_HETEROGENEOUS            (SIMD_MULT_HETEROGENEOUS),    
                .SIMD_MULT_USE_DSP                  (SIMD_MULT_USE_DSP), 

                .SIMD_LANE_COUNT                    (SIMD_LANES_PER_LAYER)
            )
            Layer_last
            (
                .clock                              (clock),
                .half_clock                         (half_clock),

                .A_wren_other                       (A_wren_other[LAST_LAYER_BASE +: (1 * SIMD_LANES_PER_LAYER)]),
                .B_wren_other                       (B_wren_other[LAST_LAYER_BASE +: (1 * SIMD_LANES_PER_LAYER)]),

                .ALU_c_in                           (ALU_c_in [LAST_LAYER_BASE +: (1 * SIMD_LANES_PER_LAYER)]),
                .ALU_c_out                          (ALU_c_out[LAST_LAYER_BASE +: (1 * SIMD_LANES_PER_LAYER)]),

                .I_read_data_in                     (SIMD_I_read_data_Layer_last),
                .I_read_data_out                    (),

                .A_io_rden                          (A_io_rden[(                    SIMD_A_IO_READ_PORT_COUNT   * LAST_LAYER_BASE) +: (1 * SIMD_LANES_PER_LAYER * SIMD_A_IO_READ_PORT_COUNT)]),
                .A_io_in                            (A_io_in  [(SIMD_A_WORD_WIDTH * SIMD_A_IO_READ_PORT_COUNT   * LAST_LAYER_BASE) +: (SIMD_A_WORD_WIDTH * SIMD_LANES_PER_LAYER * SIMD_A_IO_READ_PORT_COUNT)]),
                .A_io_wren                          (A_io_wren[(                    SIMD_A_IO_WRITE_PORT_COUNT  * LAST_LAYER_BASE) +: (1 * SIMD_LANES_PER_LAYER * SIMD_A_IO_WRITE_PORT_COUNT)]),
                .A_io_out                           (A_io_out [(SIMD_A_WORD_WIDTH * SIMD_A_IO_WRITE_PORT_COUNT  * LAST_LAYER_BASE) +: (SIMD_A_WORD_WIDTH * SIMD_LANES_PER_LAYER *SIMD_A_IO_WRITE_PORT_COUNT)]),

                .B_io_rden                          (B_io_rden[(                    SIMD_B_IO_READ_PORT_COUNT   * LAST_LAYER_BASE) +: (1 * SIMD_LANES_PER_LAYER * SIMD_B_IO_READ_PORT_COUNT)]),
                .B_io_in                            (B_io_in  [(SIMD_B_WORD_WIDTH * SIMD_B_IO_READ_PORT_COUNT   * LAST_LAYER_BASE) +: (SIMD_B_WORD_WIDTH * SIMD_LANES_PER_LAYER * SIMD_B_IO_READ_PORT_COUNT)]),
                .B_io_wren                          (B_io_wren[(                    SIMD_B_IO_WRITE_PORT_COUNT  * LAST_LAYER_BASE) +: (1 * SIMD_LANES_PER_LAYER * SIMD_B_IO_WRITE_PORT_COUNT)]),
                .B_io_out                           (B_io_out [(SIMD_B_WORD_WIDTH * SIMD_B_IO_WRITE_PORT_COUNT  * LAST_LAYER_BASE) +: (SIMD_B_WORD_WIDTH * SIMD_LANES_PER_LAYER * SIMD_B_IO_WRITE_PORT_COUNT)])
            );
        end
    endgenerate
endmodule

