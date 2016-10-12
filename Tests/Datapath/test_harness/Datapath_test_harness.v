
module Datapath_test_harness
#(
    parameter   WORD_WIDTH              = 36,
    parameter   READ_ADDR_WIDTH         = 10,
    parameter   WRITE_ADDR_WIDTH        = 12,
    parameter   MEM_DEPTH               = 1024,
    parameter   MEM_RAMSTYLE            = "M10K",
    parameter   MEM_INIT_FILE_A         = "./empty.mem",
    parameter   MEM_INIT_FILE_B         = "./empty.mem",
    parameter   MEM_WRITE_BASE_ADDR_B   = 1024,
    parameter   ALU_REGISTER_S_ADDR     = 4,
    parameter   IO_PORT_COUNT           = 3,
    parameter   IO_PORT_BASE_ADDR       = 1,
    parameter   IO_PORT_ADDR_WIDTH      = 2
)
(
    input   wire    clock,
    input   wire    in,
    output  wire    out
);

// --------------------------------------------------------------------

    // inputs

    wire    [`TRIADIC_CTRL_WIDTH-1:0]           control;

    wire                                        split;
    wire                                        branch_cancel;

    wire    [READ_ADDR_WIDTH-1:0]               read_addr_A;
    wire    [READ_ADDR_WIDTH-1:0]               read_addr_B;
    wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_D;

    wire    [READ_ADDR_WIDTH-1:0]               read_addr_A_offset;
    wire    [READ_ADDR_WIDTH-1:0]               read_addr_B_offset;
    wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_A_offset;
    wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_B_offset;
    
    wire    [IO_PORT_COUNT-1:0]                 io_read_EF_A;
    wire    [IO_PORT_COUNT-1:0]                 io_read_EF_B;
    wire    [IO_PORT_COUNT-1:0]                 io_write_EF_A;
    wire    [IO_PORT_COUNT-1:0]                 io_write_EF_B;

    wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_A;
    wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_B;

    // outputs

    wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_write_data_A;
    wire    [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_write_data_B;

    wire    [IO_PORT_COUNT-1:0]                 io_rden_A;
    wire    [IO_PORT_COUNT-1:0]                 io_rden_B;
    wire    [IO_PORT_COUNT-1:0]                 io_wren_A;
    wire    [IO_PORT_COUNT-1:0]                 io_wren_B;

    wire    [WORD_WIDTH-1:0]                    Ra;
    wire    [WORD_WIDTH-1:0]                    Rb;
    wire                                        Rcarry_out;
    wire                                        Roverflow;

    wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_Ra;
    wire    [WRITE_ADDR_WIDTH-1:0]              write_addr_Rb;

    wire                                        IO_ready;

    Datapath
    #(
        .WORD_WIDTH             (WORD_WIDTH),
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),
        .MEM_DEPTH              (MEM_DEPTH),
        .MEM_RAMSTYLE           (MEM_RAMSTYLE),
        .MEM_INIT_FILE_A        (MEM_INIT_FILE_A),
        .MEM_INIT_FILE_B        (MEM_INIT_FILE_B),
        .MEM_WRITE_BASE_ADDR_B  (MEM_WRITE_BASE_ADDR_B),
        .ALU_REGISTER_S_ADDR    (ALU_REGISTER_S_ADDR),
        .IO_PORT_COUNT          (IO_PORT_COUNT),
        .IO_PORT_BASE_ADDR      (IO_PORT_BASE_ADDR),
        .IO_PORT_ADDR_WIDTH     (IO_PORT_ADDR_WIDTH) 
    )
    DUT
    (
        .clock                  (clock),
        .control                (control),

        .split                  (split),
        .branch_cancel          (branch_cancel),

        .read_addr_A            (read_addr_A),
        .read_addr_B            (read_addr_B),
        .write_addr_D           (write_addr_D),

        .read_addr_A_offset     (read_addr_A_offset),
        .read_addr_B_offset     (read_addr_B_offset),
        .write_addr_A_offset    (write_addr_A_offset),
        .write_addr_B_offset    (write_addr_B_offset),
        
        .io_read_EF_A           (io_read_EF_A),
        .io_read_EF_B           (io_read_EF_B),
        .io_write_EF_A          (io_write_EF_A),
        .io_write_EF_B          (io_write_EF_B),

        .io_read_data_A         (io_read_data_A),
        .io_read_data_B         (io_read_data_B),
        .io_write_data_A        (io_write_data_A),
        .io_write_data_B        (io_write_data_B),

        .io_rden_A              (io_rden_A),
        .io_rden_B              (io_rden_B),
        .io_wren_A              (io_wren_A),
        .io_wren_B              (io_wren_B),

        .Ra                     (Ra),
        .Rb                     (Rb),
        .Rcarry_out             (Rcarry_out),
        .Roverflow              (Roverflow),

        .write_addr_Ra          (write_addr_Ra),
        .write_addr_Rb          (write_addr_Rb),

        .IO_ready               (IO_ready)
    );

// --------------------------------------------------------------------

    // Tie-off and register inputs and outputs to get a valid timing analysis.

    localparam INPUT_WIDTH = `TRIADIC_CTRL_WIDTH + 2 + (READ_ADDR_WIDTH*4) + (WRITE_ADDR_WIDTH*3) + (IO_PORT_COUNT*4) + ((IO_PORT_COUNT*WORD_WIDTH)*2);

    harness_input_register
    #(
        .WIDTH  (INPUT_WIDTH)
    )
    i
    (
        .clock  (clock),    
        .in     (in),
        .rden   (1'b1),
        .out    ({control, split, branch_cancel, read_addr_A, read_addr_B, write_addr_D, read_addr_A_offset, read_addr_B_offset, write_addr_A_offset, write_addr_B_offset, io_read_EF_A, io_read_EF_B, io_write_EF_A, io_write_EF_B, io_read_data_A, io_read_data_B})
    );

    localparam OUTPUT_WIDTH = ((IO_PORT_COUNT*WORD_WIDTH)*2) + (IO_PORT_COUNT*4) + (WORD_WIDTH*2) + 3 + (WRITE_ADDR_WIDTH*2);

    harness_output_register 
    #(
        .WIDTH  (OUTPUT_WIDTH)
    )
    o
    (
        .clock  (clock),
        .in     ({io_write_data_A, io_write_data_B, io_rden_A, io_rden_B, io_wren_A, io_wren_B, Ra, Rb, Rcarry_out, Roverflow, write_addr_Ra, write_addr_Rb, IO_ready}),
        .wren   (1'b1),
        .out    (out)
    );

endmodule

