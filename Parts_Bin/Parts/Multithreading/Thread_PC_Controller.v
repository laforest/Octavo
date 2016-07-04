
// The Controller holds and provides Program Counter values for each thread, 
// including the previous PC value to re-issue annulled instructions.

// There's a built-in Thread_Number counter, so this assumes 
// fixed round-robin thread scheduling.

// Requires one pipeline stage, due to PC memory.

// -----------------------------------------------------------

module PC_Selector
#(
    parameter       PC_WIDTH        = 0
)
(
    input   wire                    jump,
    input   wire    [PC_WIDTH-1:0]  jump_target,
    input   wire                    annul,
    input   wire    [PC_WIDTH-1:0]  current_pc,
    input   wire    [PC_WIDTH-1:0]  previous_pc,
    output  reg     [PC_WIDTH-1:0]  PC
);
    reg [PC_WIDTH-1:0] normal_pc;

    always @(*) begin
        normal_pc = (jump  == 1'b1) ? jump_target : current_pc;
        PC        = (annul == 1'b1) ? previous_pc : normal_pc;
    end
endmodule

// -----------------------------------------------------------
// -----------------------------------------------------------

module Thread_PC_Controller 
#(
    parameter       PC_WIDTH            = 0,
    parameter       THREAD_ADDR_WIDTH   = 0,
    parameter       THREAD_COUNT        = 0,
    parameter       RAMSTYLE            = "",
    parameter       INIT_FILE           = ""

)
(
    input   wire                        clock,
    input   wire                        jump,
    input   wire    [PC_WIDTH-1:0]      jump_target,
    input   wire                        annul,
    output  wire    [PC_WIDTH-1:0]      PC 
);

// -----------------------------------------------------------

    // Delay one cycle to align to output of PC_Memory below.

    reg                 annul_synced        = 0;
    reg                 jump_synced         = 0;
    reg [PC_WIDTH-1:0]  jump_target_synced  = 0;

    always @(posedge clock) begin
        annul_synced        = annul;
        jump_synced         = jump;
        jump_target_synced  = jump_target;
    end

// -----------------------------------------------------------

    wire [THREAD_ADDR_WIDTH-1:0] current_thread;
    wire [THREAD_ADDR_WIDTH-1:0] next_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        (next_thread)
    );

// -----------------------------------------------------------

    // Must be zero to overwrite PC of Thread 0, thus its first NOP runs twice.
    reg [THREAD_ADDR_WIDTH-1:0] previous_thread = 0;

    // Write address to store back next and current PCs
    // Delayed by 1 cycle to match pipelined next PC value adder below.
    always @(posedge clock) begin
        previous_thread <= current_thread;
    end

// -----------------------------------------------------------

    // No write forwarding logic needed. Writes never collide with reads.

    wire    [PC_WIDTH-1:0]  previous_pc;
    wire    [PC_WIDTH-1:0]  current_pc;
    reg     [PC_WIDTH-1:0]  next_pc;
    reg     [PC_WIDTH-1:0]  pc_reg;

    RAM_SDP_OLD 
    #(
        .PC_WIDTH           (PC_WIDTH * 2),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH),
        .THREAD_COUNT       (THREAD_COUNT),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    PC_Memory 
    (
        .clock      (clock),
        .wren       (1'b1),
        .write_addr (previous_thread),
        .write_data ({next_pc, pc_reg}),
        .rden       (1'b1)
        .read_addr  (next_thread), 
        .read_data  ({current_pc, previous_pc})
    );

// -----------------------------------------------------------

    PC_Selector
    #(
        .PC_WIDTH       (PC_WIDTH)
    )
    PC_Selector
    (,
        .jump           (jump_synced),
        .annul          (annul_synced),
        .current_pc     (current_pc),
        .previous_pc    (previous_pc),
        .jump_target    (jump_target_synced),
        .PC             (PC)
    );

// -----------------------------------------------------------

    // Prevents jump_target->PC_Memory critical path.
    // Placed here, rather than after adder, to separate PC_Selector
    // muxes from adder.

    always @(posedge clock) begin
        pc_reg <= PC;
    end

// -----------------------------------------------------------

    // Workaround to use bit vector selection to eliminate truncation warnings
    integer one = 1;

    always @(*) begin
        next_pc <= pc_reg + one[PC_WIDTH-1:0];
    end

endmodule
