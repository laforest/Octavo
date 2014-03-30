
// Holds and provides Program Counter values, including the previous one to
// re-issue annulled instructions.

// -----------------------------------------------------------

// ECL XXX This should be re-written using the RAM_SDP_no_fw module

// ECL XXX Re-implement with RAM_SDP_no_fw instance, tying wren high.

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

// Not optionally registered because we use the final PC in two ways at the
// end, one of which might not have a pipelined output depending on the
// Controlle's position in the ControlPath.

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
            PC <= normal_pc;
        end
        else begin
            PC <= previous_pc;
        end
    end
endmodule

// -----------------------------------------------------------

module Controller 
#(
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

    // ECL XXX For simulation, to measure ALU usage
    always @(posedge clock) begin
        $display("PC: %d", PC);
    end

// -----------------------------------------------------------

    wire    IO_ready_synced;

    delay_line 
    #(
        .DEPTH  (2),
        .WIDTH  (1)
    ) 
    IO_ready_pipeline
    (
        .clock  (clock),
        .in     (IO_ready),
        .out    (IO_ready_synced)
    );

// -----------------------------------------------------------

    wire    jump_synced;

    delay_line 
    #(
        .DEPTH  (2),
        .WIDTH  (1)
    ) 
    jump_pipeline
    (
        .clock  (clock),
        .in     (jump),
        .out    (jump_synced)
    );

// -----------------------------------------------------------

    wire    [PC_WIDTH-1:0]  branch_destination_synced;

    delay_line 
    #(
        .DEPTH  (2),
        .WIDTH  (PC_WIDTH)
    ) 
    branch_destination_pipeline
    (
        .clock  (clock),
        .in     (branch_destination),
        .out    (branch_destination_synced)
    );

// -----------------------------------------------------------

    wire    [THREAD_ADDR_WIDTH-1:0] current_thread;
    wire    [THREAD_ADDR_WIDTH-1:0] next_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (0), // ECL XXX hardcoded...but doesn't matter here, and see below.
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    Controller_Thread_Number
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        (next_thread)
    );

// -----------------------------------------------------------

    reg     [THREAD_ADDR_WIDTH-1:0] previous_thread;

    // Used to store back next and current PCs, delayed by 1 cycle for adder.
    always @(posedge clock) begin
        previous_thread <= current_thread;
    end

    // ECL XXX hardcoded...must be zero to overwrite PC of Thread 0, thus its first NOP runs twice.
    initial begin
        previous_thread = 0;
    end

// -----------------------------------------------------------

    wire    [PC_WIDTH-1:0]  previous_pc;
    wire    [PC_WIDTH-1:0]  current_pc;
    reg     [PC_WIDTH-1:0]  next_pc;
    wire    [PC_WIDTH-1:0]  pc_reg;

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

    wire    [PC_WIDTH-1:0]  pc_raw;

    PC_Selector
    #(
        .PC_WIDTH       (PC_WIDTH)
    )
    PC_Selector
    (
        .jump           (jump_synced),
        .IO_ready       (IO_ready_synced),
        .current_pc     (current_pc),
        .previous_pc    (previous_pc),
        .jump_target    (branch_destination_synced),
        .PC             (pc_raw)
    );

// -----------------------------------------------------------

    delay_line 
    #(
        .DEPTH  (0),
        .WIDTH  (PC_WIDTH)
    ) 
    PC_pipeline
    (
        .clock  (clock),
        .in     (pc_raw),
        .out    (PC)
    );

// -----------------------------------------------------------

    // prevents JMP->PCM critical path.
    // Redundant with PC_pipeline, but better to duplicate and let tool deduplicate if needed.
    delay_line 
    #(
        .DEPTH  (1),
        .WIDTH  (PC_WIDTH)
    ) 
    pc_reg_pipeline
    (
        .clock  (clock),
        .in     (pc_raw),
        .out    (pc_reg)
    );

// -----------------------------------------------------------

    // Workaround to use bit vector selection to eliminate truncation warnings
    integer one = 1;

    always @(*) begin
        next_pc  <= pc_reg + one[PC_WIDTH-1:0];
    end

endmodule
