
// Holds and provides Program Counter values, including the previous one to
// re-issue annulled instructions.

// -----------------------------------------------------------

// ECL XXX This should be re-written using the RAM_SDP_no_fw module

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

// -----------------------------------------------------------

module PC_Selector
#(
    parameter       PC_WIDTH        = 0
)
(
    input   wire                    jump,
    input   wire                    IO_ready,
    input   wire    [PC_WIDTH-1:0]  current_pc,
    input   wire    [PC_WIDTH-1:0]  previous_pc,
    input   wire    [PC_WIDTH-1:0]  jump_target,
    output  reg     [PC_WIDTH-1:0]  PC
);
    reg     [PC_WIDTH-1:0] normal_pc;

    always @(*) begin
        if (jump === `HIGH) begin
            normal_pc <= jump_target;
        end
        else begin
            normal_pc <= current_pc;
        end
    end

    always @(*) begin
        if (IO_ready === `HIGH) begin
            pc <= normal_pc;
        end
        else begin
            pc <= previous_pc;
        end
    end
endmodule

// -----------------------------------------------------------

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
    input   wire    [PC_WIDTH-1:0]      branch_destination,
    input   wire                        jump,
    input   wire                        IO_ready,
    output  wire    [PC_WIDTH-1:0]      PC 
);

// -----------------------------------------------------------

    wire    [THREAD_ADDR_WIDTH-1:0] current_thread;
    wire    [THREAD_ADDR_WIDTH-1:0] next_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    Controller_Thread_Number
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        (next_thread)
    );

    wire    [PC_WIDTH-1:0]  previous_pc;
    wire    [PC_WIDTH-1:0]  current_pc;
    reg     [PC_WIDTH-1:0]  next_pc;

    reg     [THREAD_ADDR_WIDTH-1:0] previous_thread;

    always @(posedge clock) begin
        previous_thread <= current_thread;
    end

// -----------------------------------------------------------

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

// -----------------------------------------------------------

    PC_Selector
    #(
        .PC_WIDTH       (PC_WIDTH)
    )
    PC_Selector
    (
        .jump           (jump),
        .IO_ready       (IO_ready),
        .current_pc     (current_pc),
        .previous_pc    (previous_pc),
        .jump_target    (branch_destination),
        .PC             (PC)
    );

// -----------------------------------------------------------

    always @(posedge clock) begin
        pc_reg <= pc;
    end

    // Workaround to use bit vector selection to eliminate truncation warnings
    integer one = 1;

    always @(*) begin
        next_pc  <= pc_reg + one[PC_WIDTH-1:0];
    end
endmodule
