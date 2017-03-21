
// Control Memory, which translates an opcode into a control word to define
// the ALU operation on the A/B operands. 

// Multithreaded, and can use simple or composite RAM for
// portability/performance.

module Control_Memory
#(
    // If USE_COMPOSITE == 1: use a monolithic inferred RAM
    parameter       USE_COMPOSITE       = 0,
    parameter       INIT_FILE           = "",
    // else if USE_COMPOSITE == 0: use a composite inferred RAM
    // Individual sub-RAM parameters
    parameter       SUB_INIT_FILE       = "",
    parameter       SUB_ADDR_WIDTH      = 0,
    parameter       SUB_DEPTH           = 0,
    // Common to composite and monolithic
    parameter       RAMSTYLE            = "",
    parameter       READ_NEW_DATA       = 0,
    // Interface (per thread)
    parameter       OPCODE_WIDTH        = 0,
    parameter       CONTROL_WIDTH       = 0,
    // Multithreading
    parameter       THREAD_COUNT        = 0,
    parameter       THREAD_COUNT_WIDTH  = 0
)
(
    input  wire                     clock,
    input  wire                     wren,
    input  wire [OPCODE_WIDTH-1:0]  write_addr,
    input  wire [CONTROL_WIDTH-1:0] write_data,
    input  wire                     rden,
    input  wire [OPCODE_WIDTH-1:0]  read_addr,
    output wire [CONTROL_WIDTH-1:0] read_data
);

// -----------------------------------------------------------

    localparam CM_ADDR_WIDTH = OPCODE_WIDTH      + THREAD_COUNT_WIDTH;
    localparam CM_DEPTH      = (2**OPCODE_WIDTH) * THREAD_COUNT;

// -----------------------------------------------------------

    wire [THREAD_COUNT_WIDTH-1:0] current_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_COUNT_WIDTH (THREAD_COUNT_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        ()                  // N/C
    );

// --------------------------------------------------------------------

    reg [CM_ADDR_WIDTH-1:0] cm_read_addr  = 0;
    reg [CM_ADDR_WIDTH-1:0] cm_write_addr = 0;

    always @(*) begin
        cm_read_addr    <= {current_thread, read_addr};
        cm_write_addr   <= {current_thread, write_addr};
    end

// --------------------------------------------------------------------
// Select composite/monolithic RAM. 
// Coded to fail on invalid parameter value.

    generate
        if (USE_COMPOSITE == 1) begin
            RAM_SDP_Composite
            #(
                .WORD_WIDTH     (CONTROL_WIDTH),
                .ADDR_WIDTH     (CM_ADDR_WIDTH),
                .DEPTH          (CM_DEPTH),
                .RAMSTYLE       (RAMSTYLE),
                .READ_NEW_DATA  (READ_NEW_DATA),
                // Must use an init file, else all zero init decodes to all NOPs
                .USE_INIT_FILE  (1),
                .SUB_INIT_FILE  (SUB_INIT_FILE),
                .SUB_ADDR_WIDTH (SUB_ADDR_WIDTH),
                .SUB_DEPTH      (SUB_DEPTH)
            )
            CM
            (
                .clock          (clock),
                .wren           (wren),
                .write_addr     (cm_write_addr),
                .write_data     (write_data),
                .rden           (rden),
                .read_addr      (cm_read_addr), 
                .read_data      (read_data)
            );
        end
        else begin
            if (USE_COMPOSITE == 0) begin
                RAM_SDP
                #(
                    .WORD_WIDTH     (CONTROL_WIDTH),
                    .ADDR_WIDTH     (CM_ADDR_WIDTH),
                    .DEPTH          (CM_DEPTH),
                    .RAMSTYLE       (RAMSTYLE),
                    .READ_NEW_DATA  (READ_NEW_DATA),
                    // Must use an init file, else all zero init decodes to all NOPs
                    .USE_INIT_FILE  (1),
                    .INIT_FILE      (INIT_FILE)
                )
                CM
                (
                    .clock          (clock),
                    .wren           (wren),
                    .write_addr     (cm_write_addr),
                    .write_data     (write_data),
                    .rden           (rden),
                    .read_addr      (cm_read_addr), 
                    .read_data      (read_data)
                );
            end
        end
    endgenerate

endmodule

