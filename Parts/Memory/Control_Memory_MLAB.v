
// Control Memory, which translates an opcode into a control word to define
// the ALU operation on the A/B operands.

// This memory is implemented as multiple MLAB sub-memories
// with explicit pipelining, decoding, and multiplexing.
// This helps improve synthesis results.

// For Cyclone/Arria/Stratix V and newer, and Stratix IV

// If we let Quartus infer a single deep MLAB-based memory with a registered
// output, it will do so, but places the single output register after the mux,
// as the behavioural code describes, rather than at the output of each MLAB.
// Furthermore, since the mux is inferred, the output register will not get
// retimed across the mux, and so becomes a critical path.

// Direct implementation yields multiple memories with registered outputs, and
// a mux placed after these. A final pipeline register (elsewhere) then
// isolates the mux. The final resource usage is the same.

// We *must* use an init file, since all-zero would provide NOPs, and we would
// be stuck.

module Control_Memory_MLAB
#(
    parameter INIT_FILE                         = ""
)
(
    input  wire                                 clock,
    input  wire                                 wren,
    input  wire [`OPCODE_WIDTH-1:0]             write_addr,
    input  wire [`TRIADIC_ALU_CTRL_WIDTH-1:0]   write_data,
    input  wire                                 rden,
    input  wire [`OPCODE_WIDTH-1:0]             read_addr,
    output wire [`TRIADIC_ALU_CTRL_WIDTH-1:0]   read_data
);

// --------------------------------------------------------------------

    wire [`OCTAVO_THREAD_ADDR_WIDTH-1:0] thread;

    Thread_Number
    #(
        .INITIAL_THREAD     (0),
        .THREAD_COUNT       (`OCTAVO_THREAD_COUNT),
        .THREAD_ADDR_WIDTH  (`OCTAVO_THREAD_ADDR_WIDTH)
    )
    TID
    (
        .clock              (clock),
        .current_thread     (thread),
        .next_thread        ()                  // N/C
    );

// --------------------------------------------------------------------
// Thread-derived addressing, extends the raw read/write addresses

    reg         upper_lower_selector    = 0;
    reg [2-1:0] output_selector         = 0;
    reg [2-1:0] output_selector_mux     = 0;

    // Selects upper/lower half of all MLABs for read/write
    // Selects one MLAB for read/write enables
    always @(*) begin
        upper_lower_selector <= thread[0];
        output_selector      <= thread[2:1];
    end

    // Used in next stage to select one MLAB output
    // (necessarily the read-enabled MLAB)
    always @(posedge clock) begin
        output_selector_mux <= output_selector;
    end 

// --------------------------------------------------------------------
// We assume that write data and addr are already synch'ed to arrive at
// the same thread

    reg [5-1:0] cm_write_addr = 0;
    reg [5-1:0] cm_read_addr  = 0;
    
    always @(*) begin
        cm_write_addr <= {upper_lower_selector,write_addr};
        cm_read_addr  <= {upper_lower_selector,read_addr};
    end

// --------------------------------------------------------------------
// Enable reads and writes to each MLAB as read/write address allows, 
// and any external address decoding also.

    reg [4-1:0] cm_wren = 0;
    reg [4-1:0] cm_rden = 0;

    generate
        genvar i;
        for(i = 0; i < 4; i = i+1) begin

            Address_Range_Decoder_Static
            #(
                .ADDR_WIDTH     (2),
                .ADDR_BASE      (0+i),
                .ADDR_BOUND     (1+i)
            )
            CM_RDEN
            (
                .enable         (rden),
                .addr           (output_selector),
                .hit            (cm_rden[i])
            );

            Address_Range_Decoder_Static
            #(
                .ADDR_WIDTH     (2),
                .ADDR_BASE      (0+i),
                .ADDR_BOUND     (1+i)
            )
            CM_WREN
            (
                .enable         (wren),
                .addr           (output_selector),
                .hit            (cm_wren[i])
            );

    end
    endgenerate

// --------------------------------------------------------------------

    reg [`TRIADIC_ALU_CTRL_WIDTH-1:0]   cm_read_data [4-1:0]    = 0;

    RAM_SDP 
    #(
        .WORD_WIDTH     (`TRIADIC_ALU_CTRL_WIDTH),
        .ADDR_WIDTH     (5),
        .DEPTH          (32),
        .RAMSTYLE       ("MLAB,no_rw_check"),
        .READ_NEW_DATA  (0),
        .USE_INIT_FILE  (1),
        .INIT_FILE      (INIT_FILE)
    )
    Control_Memory      [4-1:0]
    (
        .clock          (clock),
        .wren           (cm_wren),
        .write_addr     (cm_write_addr),
        .write_data     (write_data),
        .rden           (cm_rden),
        .read_addr      (cm_read_addr), 
        .read_data      (cm_read_data)
    );

// --------------------------------------------------------------------
// Select the output of the read-enabled MLAB

    Addressed_Mux
    #(
        .WORD_WIDTH     (`TRIADIC_ALU_CTRL_WIDTH),
        .ADDR_WIDTH     (2),
        .INPUT_COUNT    (4)
    )
    CM_MUX
    (
        .addr           (output_selector_mux),    
        .in             (cm_read_data),
        .out            (read_data)
    );

endmodule

