
// Simple Dual Port RAM, which returns the old value on coincident read and
// write (no write-forwarding). 
// This is well-suited for LUT-based memory, such as MLABs.

// Adding "no_rw_check" to RAMSTYLE can be useful if you know reads and writes
// will never collide. Might give better synthesis results.

// Also, we don't want a synchronous clear on the
// output: any register driving it cannot be retimed.

module RAM_SDP_OLD
#(
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       DEPTH               = 0,
    parameter       RAMSTYLE            = "",
    parameter       USE_INIT_FILE       = 0,
    parameter       INIT_FILE           = ""
)
(
    input  wire                         clock,
    input  wire                         wren,
    input  wire     [ADDR_WIDTH-1:0]    write_addr,
    input  wire     [WORD_WIDTH-1:0]    write_data,
    input  wire                         rden,
    input  wire     [ADDR_WIDTH-1:0]    read_addr, 
    output reg      [WORD_WIDTH-1:0]    read_data
);

// --------------------------------------------------------------------

    initial begin
        read_data = 0;
    end

// --------------------------------------------------------------------

    // Example: "MLAB, no_rw_check"
    (* ramstyle = RAMSTYLE *) 
    reg [WORD_WIDTH-1:0] ram [DEPTH-1:0];

    always @(posedge clock) begin
        // Not in ?: form since this is for RAM inference
        // There is nothing to do if wren is X/Z
        if(wren == `HIGH) begin
            ram[write_addr] <= write_data;
        end
        if(rden == `HIGH) begin
            read_data <= ram[read_addr];
        end
    end

// --------------------------------------------------------------------

    // If not using an init file, initially set all memory to zero.
    // The CAD tool should generate a memory initialization file from that.

    // This is useful to cleanly implement small collections of registers (via
    // RAMSTYLE), without having to deal with an init file.

    // Giving a non-1/0 value to USE_INIT_FILE is undefined.
    // (Quartus fails with a strange error, and fills with zeros anyway.)

    generate
        if (USE_INIT_FILE == 1) begin
            initial begin
                $readmemh(INIT_FILE, ram);
            end
        end
        else if (USE_INIT_FILE == 0) begin
            integer i;
            initial begin
                for (i = 0; i < DEPTH; i = i + 1) begin
                    ram[i] = 0;
                end
            end
        end
    endgenerate

endmodule

