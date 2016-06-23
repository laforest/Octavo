
// Translates the instruction opcode into control bits
// The opcode simply indexes into a memory
// We can write the resultant control bits for each opcode

module InstructionDecoder
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
    input   wire    [OPCODE_COUNT-1:0]  write_addr,
    input   wire    [OPCODE_WIDTH-1:0]  write_data,
    input   wire                        rden,
    input   wire    [OPCODE_WIDTH-1:0]  opcode,
    output  wire    [CONTROL_WIDTH-1:0] control
);

// -----------------------------------------------------------

    wire    [THREAD_ADDR_WIDTH-1:0]     current_thread;

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

    localparam  DECODER_RAM_ADDR_WIDTH  = THREAD_ADDR_WIDTH + OPCODE_WIDTH;
    localparam  DECODER_RAM_DEPTH       = THREAD_COUNT      * OPCODE_COUNT;

    reg         [DECODER_RAM_ADDR_WIDTH-1:0]    thread_opcode;
    reg         [DECODER_RAM_ADDR_WIDTH-1:0]    thread_write_addr;
    wire        [CONTROL_WIDTH-1:0]             control_internal;

    always @(*) begin
        thread_opcode       = {current_thread,opcode};
        thread_write_addr   = {current_thread,write_addr};
    end

    RAM_SDP_no_fw
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
        .write_addr         (thread_write_addr),
        .write_data         (write_data),
        .rden               (rden),
        .read_addr          (thread_opcode),
        .read_data          (control_internal)
    );

// -----------------------------------------------------------

    delay_line
    #(
        .DEPTH  (1),
        .WIDTH  (CONTROL_WIDTH)
    )
    Decoder_pipeline
    (
        .clock  (clock),
        .in     (control_internal),
        .out    (control)
    );

endmodule

