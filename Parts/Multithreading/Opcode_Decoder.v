
// Translates an instruction opcode into a number of control bits
// The opcode simply indexes into a memory
// We can write the desired control bits for each opcode
// Each thread has its own opcode definition

module Opcode_Decoder
#(
    parameter   OPCODE_COUNT            = 0,
    parameter   OPCODE_WIDTH            = 0,
    parameter   CONTROL_WIDTH           = 0,
    parameter   THREAD_COUNT            = 0,
    parameter   THREAD_ADDR_WIDTH       = 0,
    parameter   INITIAL_THREAD          = 0,
    parameter   RAMSTYLE                = 0,
    parameter   INIT_FILE               = 0
)
(
    input   wire                        clock,
    input   wire                        wren,
    input   wire    [OPCODE_COUNT-1:0]  opcode_write,
    input   wire    [OPCODE_WIDTH-1:0]  control_write,
    input   wire                        rden,
    input   wire    [OPCODE_WIDTH-1:0]  opcode_read,
    output  wire    [CONTROL_WIDTH-1:0] control_read
);

// -----------------------------------------------------------

    wire [THREAD_ADDR_WIDTH-1:0] current_thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (INITIAL_THREAD),
        .THREAD_COUNT       (THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (THREAD_ADDR_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .current_thread     (current_thread),
        .next_thread        ()                  // N/C
    );

// -----------------------------------------------------------

    // Expand Decoder memory to contain control bits for each thread.

    localparam  DECODER_RAM_ADDR_WIDTH  = THREAD_ADDR_WIDTH + OPCODE_WIDTH;
    localparam  DECODER_RAM_DEPTH       = THREAD_COUNT      * OPCODE_COUNT;

    reg     [DECODER_RAM_ADDR_WIDTH-1:0]    thread_opcode_read;
    reg     [DECODER_RAM_ADDR_WIDTH-1:0]    thread_opcode_write;

    // Place TID in MSB, just to make the memory map simple.

    always @(*) begin
        thread_opcode_read  = {current_thread,opcode_read};
        thread_opcode_write = {current_thread,opcode_write};
    end

    // XXX We assume reads and writes don't collide here.
    // And that you use MLABs or similar.
    // You may have to change memory type if that's not true.

    RAM_SDP_OLD
    #(
        .WORD_WIDTH         (CONTROL_WIDTH),
        .ADDR_WIDTH         (DECODER_RAM_ADDR_WIDTH),
        .DEPTH              (DECODER_RAM_DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    Decoder
    (
        .clock              (clock),
        .wren               (wren),
        .write_addr         (thread_opcode_write),
        .write_data         (control_write),
        .rden               (rden),
        .read_addr          (thread_opcode_read),
        .read_data          (control_read)
    );
endmodule

