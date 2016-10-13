
module Datapath_test_bench
#(
    parameter   WORD_WIDTH              = 36,
    parameter   READ_ADDR_WIDTH         = 10,
    parameter   WRITE_ADDR_WIDTH        = 12,
    parameter   MEM_DEPTH               = 1024,
    parameter   MEM_RAMSTYLE            = "M10K",
    parameter   MEM_INIT_FILE_A         = "./empty.mem",
    parameter   MEM_INIT_FILE_B         = "./empty.mem",
    parameter   MEM_READ_BASE_ADDR_A    = 1,
    parameter   MEM_READ_BOUND_ADDR_A   = 1023,
    parameter   MEM_WRITE_BASE_ADDR_A   = 1,
    parameter   MEM_WRITE_BOUND_ADDR_A  = 1023,
    parameter   MEM_READ_BASE_ADDR_B    = 1,
    parameter   MEM_READ_BOUND_ADDR_B   = 1023,
    parameter   MEM_WRITE_BASE_ADDR_B   = 1025, // 1    + 1024
    parameter   MEM_WRITE_BOUND_ADDR_B  = 2047, // 1023 + 1024
    parameter   ALU_REGISTER_S_ADDR     = 4,
    parameter   IO_PORT_COUNT           = 3,
    parameter   IO_PORT_BASE_ADDR       = 1,
    parameter   IO_PORT_ADDR_WIDTH      = 2
)
(
    // No ports. Ignore Modelsim warning.
);

// --------------------------------------------------------------------

    integer                                     cycle;

    reg                                         clock;
    reg     [`TRIADIC_CTRL_WIDTH-1:0]           control;

    reg                                         split;
    reg                                         branch_cancel;

    reg     [READ_ADDR_WIDTH-1:0]               read_addr_A;
    reg     [READ_ADDR_WIDTH-1:0]               read_addr_B;
    reg     [WRITE_ADDR_WIDTH-1:0]              write_addr_D;

    reg     [READ_ADDR_WIDTH-1:0]               read_addr_A_offset;
    reg     [READ_ADDR_WIDTH-1:0]               read_addr_B_offset;
    reg     [WRITE_ADDR_WIDTH-1:0]              write_addr_A_offset;
    reg     [WRITE_ADDR_WIDTH-1:0]              write_addr_B_offset;
    
    reg     [IO_PORT_COUNT-1:0]                 io_read_EF_A;
    reg     [IO_PORT_COUNT-1:0]                 io_read_EF_B;
    reg     [IO_PORT_COUNT-1:0]                 io_write_EF_A;
    reg     [IO_PORT_COUNT-1:0]                 io_write_EF_B;

    reg     [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_A;
    reg     [(IO_PORT_COUNT*WORD_WIDTH)-1:0]    io_read_data_B;
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

    initial begin
        cycle                   = 0;
        clock                   = 0;
        control                 = `ALU_NOP;

        split                   = control[`TRIADIC_CTRL_WIDTH-1];
        branch_cancel           = 0;

        read_addr_A             = 10'd2;
        read_addr_B             = 10'd3;
        write_addr_D            = {6'd3,6'd1};

        read_addr_A_offset      = 10'd2;
        read_addr_B_offset      = 10'd3;
        write_addr_A_offset     = 12'd3;
        write_addr_B_offset     = 12'd1025;
        
        // All not ready at start
        io_read_EF_A            = 0;
        io_read_EF_B            = 0;
        io_write_EF_A           = -1;
        io_write_EF_B           = -1;

        io_read_data_A          = {36'd3,36'd2,36'd1};
        io_read_data_B          = {36'd6,36'd5,36'd4};
        `DELAY_CLOCK_CYCLES(128) $finish;
    end

    // Update on the fly
    always @(*) begin
        split = control[`TRIADIC_CTRL_WIDTH-1];
    end

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin
        // control <= `ALU_NOP;
        //`DELAY_CLOCK_CYCLES(1);
        control <= `ALU_DMOV;
        `DELAY_CLOCK_CYCLES(20);
        // Enable all ports to start computation
        io_read_EF_A            = -1;
        io_read_EF_B            = -1;
        io_write_EF_A           = 0;
        io_write_EF_B           = 0;
        `DELAY_CLOCK_CYCLES(1);
        // control <= `ALU_DMOV;
        // `DELAY_CLOCK_CYCLES(1);
    end

// --------------------------------------------------------------------

    Datapath
    #(
        .WORD_WIDTH             (WORD_WIDTH),
        .READ_ADDR_WIDTH        (READ_ADDR_WIDTH),
        .WRITE_ADDR_WIDTH       (WRITE_ADDR_WIDTH),
        .MEM_RAMSTYLE           (MEM_RAMSTYLE),
        .MEM_INIT_FILE_A        (MEM_INIT_FILE_A),
        .MEM_INIT_FILE_B        (MEM_INIT_FILE_B),
        .MEM_READ_BASE_ADDR_A   (MEM_READ_BASE_ADDR_A),
        .MEM_READ_BOUND_ADDR_A  (MEM_READ_BOUND_ADDR_A),
        .MEM_WRITE_BASE_ADDR_A  (MEM_WRITE_BASE_ADDR_A),
        .MEM_WRITE_BOUND_ADDR_A (MEM_WRITE_BOUND_ADDR_A),
        .MEM_READ_BASE_ADDR_B   (MEM_READ_BASE_ADDR_B),
        .MEM_READ_BOUND_ADDR_B  (MEM_READ_BOUND_ADDR_B),
        .MEM_WRITE_BASE_ADDR_B  (MEM_WRITE_BASE_ADDR_B),
        .MEM_WRITE_BOUND_ADDR_B (MEM_WRITE_BOUND_ADDR_B),
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

endmodule

