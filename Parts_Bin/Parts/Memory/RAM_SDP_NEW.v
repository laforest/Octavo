
// Simple Dual Port RAM, returns new data on coincident read and write
// (write-forwarding). Good for M10K.

// The inferred write-forwarding logic also allows the RAM to operate at
// higher frequency, since a read corrupted by a simultaneous write to the
// same address will be discarded and replaced by the write value at the
// output mux of the forwarding logic.

// If you do not want write-forwarding, but keep the high speed, at the price
// of indeterminate behaviour on overlapping read/writes, use "no_rw_check" as
// part of the RAMSTYLE (e.g.: "M10K, no_rw_check").

// Also, we don't want a synchronous clear on the
// output: any register driving it cannot be retimed.

module RAM_SDP_NEW 
#(
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       DEPTH               = 0,
    parameter       RAMSTYLE            = "",
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
    // Exmaple: "M10K"
    (* ramstyle = RAMSTYLE *) 
    reg [WORD_WIDTH-1:0] ram [DEPTH-1:0];

    always @(posedge clock) begin
        // Not in ?: form since this is for RAM inference
        // There is nothing to do if wren is X/Z
        if(wren == `HIGH) begin
            ram[write_addr] = write_data;
        end
        if(rden == `HIGH) begin
            read_data = ram[read_addr];
        end
    end

    initial begin
        read_data = 0;
        $readmemh(INIT_FILE, ram);
    end
endmodule

