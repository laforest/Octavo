
module Controller_A_zero 
#(
    parameter       A_WORD_WIDTH        = 0
)
(
    input   wire                        clock,
    input   wire    [A_WORD_WIDTH-1:0]  A,
    output  reg                         A_zero
);
    always @(posedge clock) begin
        if (A === {A_WORD_WIDTH{`LOW}}) begin
            A_zero <= `HIGH;
        end
        else begin
            A_zero <= `LOW;
        end
    end

    initial begin
        A_zero = 0;
    end
endmodule

module Controller_A_positive 
#(
    parameter       A_WORD_WIDTH        = 0
)
(
    input   wire                        clock,
    input   wire    [A_WORD_WIDTH-1:0]  A,
    output  reg                         A_positive
);
    always @(posedge clock) begin
        if (A[A_WORD_WIDTH-1] === `LOW) begin
            A_positive <= `HIGH;
        end
        else begin
            A_positive <= `LOW;
        end
    end

    initial begin
        A_positive = 0;
    end
endmodule

// ECL This contains the negation of Memory_wren, combine?
module Controller_jump 
#(
    parameter       OPCODE_WIDTH        = 0
)
(
    input   wire                        clock,
    input   wire    [OPCODE_WIDTH-1:0]  op,
    input   wire                        A_zero,
    input   wire                        A_positive,
    output  reg                         jump
);
    always @(posedge clock) begin
        if (op === `JMP)                            jump <= `HIGH; else
        if (op === `JZE && A_zero === `HIGH)        jump <= `HIGH; else
        if (op === `JNZ && A_zero === `LOW)         jump <= `HIGH; else
        if (op === `JPO && A_positive === `HIGH)    jump <= `HIGH; else
        if (op === `JNE && A_positive === `LOW)     jump <= `HIGH; else jump <= `LOW;
    end

    initial begin
        jump = 0;
    end
endmodule

module Controller_threads 
#(
    parameter       PC_WIDTH                = 0,
    parameter       THREAD_ADDR_WIDTH       = 0,
    parameter       THREAD_COUNT            = 0,
    parameter       RAMSTYLE                = "", 
    parameter       INIT_FILE               = ""
)
(
    input   wire                            clock,
    input   wire    [THREAD_ADDR_WIDTH-1:0] thread_write_addr,
    input   wire    [PC_WIDTH-1:0]          thread_write_data,
    input   wire    [THREAD_ADDR_WIDTH-1:0] thread_read_addr, 
    output  reg     [PC_WIDTH-1:0]          thread_read_data
);
    (* ramstyle = RAMSTYLE *) 
    reg [PC_WIDTH-1:0] threads [THREAD_COUNT-1:0];

    initial begin
        $readmemh(INIT_FILE, threads);
    end

    // The read and write addresses always differ by one
    always @(posedge clock) begin
        threads[thread_write_addr] <= thread_write_data;
        thread_read_data <= threads[thread_read_addr];
    end

    initial begin
        thread_read_data = 0; // Matches registered MLAB power-up state.
    end
endmodule

module Controller 
#(
    parameter       OPCODE_WIDTH        = 0,
    parameter       A_WORD_WIDTH        = 0,
    parameter       PC_WIDTH            = 0,
    parameter       THREAD_ADDR_WIDTH   = 0,
    parameter       THREAD_COUNT        = 0,
    parameter       RAMSTYLE            = "",
    parameter       INIT_FILE           = ""

)
(
    input   wire                        clock,
    input   wire    [A_WORD_WIDTH-1:0]  A,
    input   wire    [OPCODE_WIDTH-1:0]  op,
    input   wire    [PC_WIDTH-1:0]      D,
    input   wire                        IO_ready,
    output  reg     [PC_WIDTH-1:0]      pc 
);

    wire    [OPCODE_WIDTH-1:0]  op_pipelined;

    delay_line 
    #(
        .DEPTH  (1), 
        .WIDTH  (OPCODE_WIDTH)
    ) 
    op_pipeline
    (
        .clock  (clock),
        .in     (op),
        .out    (op_pipelined)
    );
 
    wire    [PC_WIDTH-1:0]      D_pipelined;

    delay_line 
    #(
        .DEPTH  (2), 
        .WIDTH  (PC_WIDTH)
    ) 
    D_pipeline
    (
        .clock  (clock),
        .in     (D),
        .out    (D_pipelined)
    );

    wire        IO_ready_pipelined;

    delay_line 
    #(
        .DEPTH  (2), 
        .WIDTH  (1)
    ) 
    IO_ready_pipeline
    (
        .clock  (clock),
        .in     (IO_ready),
        .out    (IO_ready_pipelined)
    );
 
    wire    A_zero;

    Controller_A_zero 
    #(
        .A_WORD_WIDTH   (A_WORD_WIDTH)
    )
    Controller_A_zero 
    (
        .clock          (clock),
        .A              (A),
        .A_zero         (A_zero)
    );

    wire    A_positive;

    Controller_A_positive 
    #(
        .A_WORD_WIDTH   (A_WORD_WIDTH)
    )
    Controller_A_positive 
    (
        .clock          (clock),
        .A              (A),
        .A_positive     (A_positive)
    );

    wire    jump;

    Controller_jump 
    #(
        .OPCODE_WIDTH   (OPCODE_WIDTH)
    )
    Controller_jump 
    (
        .clock          (clock),
        .op             (op_pipelined),
        .A_zero         (A_zero),
        .A_positive     (A_positive),
        .jump           (jump)
    );

    // ECL FIXME The following should be put into a Thread Number module.
    // -----------------------------------------------------------------
    reg     [THREAD_ADDR_WIDTH-1:0] current_thread;
    reg     [THREAD_ADDR_WIDTH-1:0] next_thread;

    // ECL Workaround to allow bit vector selection to eliminate truncation warnings
    integer one = 1;

    initial begin
        current_thread = 0;
    end

    always @(*) begin
        // ECL Doing it this way to avoid an adder/subtracter comparator. Does that work?
        if(current_thread !== THREAD_COUNT-1) begin
            next_thread <= current_thread + one[THREAD_ADDR_WIDTH-1:0];
        end
        else begin
            next_thread <= 0;
        end
    end

    always @(posedge clock) begin
        current_thread  <= next_thread;
    end
    // -----------------------------------------------------------------

    wire    [PC_WIDTH-1:0]  previous_pc;
    wire    [PC_WIDTH-1:0]  current_pc;
    reg     [PC_WIDTH-1:0]  next_pc;

    reg     [THREAD_ADDR_WIDTH-1:0] previous_thread;

    always @(posedge clock) begin
        previous_thread <= current_thread;
    end

    reg     [PC_WIDTH-1:0] pc_reg;

    Controller_threads 
    #(
        .PC_WIDTH           (PC_WIDTH * 2),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH),
        .THREAD_COUNT       (THREAD_COUNT),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    threads_pc 
    (
        .clock              (clock),
        .thread_write_addr  (previous_thread),
        .thread_write_data  ({next_pc, pc_reg}),
        .thread_read_addr   (next_thread), 
        .thread_read_data   ({current_pc, previous_pc})
    );

    reg     [PC_WIDTH-1:0] normal_pc;

    always @(*) begin
        if (jump === `HIGH) begin
            normal_pc <= D_pipelined;
        end
        else begin
            normal_pc <= current_pc;
        end
    end

    always @(*) begin
        if (IO_ready_pipelined === `HIGH) begin
            pc <= normal_pc;
        end
        else begin
            pc <= previous_pc;
        end
    end

    always @(posedge clock) begin
        pc_reg <= pc;
    end

    always @(*) begin
        next_pc  <= pc_reg + one[PC_WIDTH-1:0];
    end
endmodule
