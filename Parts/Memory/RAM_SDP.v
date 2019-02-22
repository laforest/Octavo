
// Simple Dual Port RAM, made for on-chip Block RAMs (BRAMs) and LUT-RAM.
// One write port and one read port, separately addressed, with common clock.
// Common data width on both ports.

// The READ_NEW_DATA parameter control the behaviour of simultaneous reads
// and writes to the same address. This is the most important parameter when
// considering what kind of memory block the CAD tool will infer.

// READ_NEW_DATA = 0 
// describes a memory which returns the OLD value (in the memory) on
// coincident read and write (no write-forwarding).
// This is well-suited for LUT-based memory, such as MLABs.

// READ_NEW_DATA = 1 (or any non-zero value)
// describes a memory which returns NEW data (from the write) on coincident
// read and write, usually by inferring some surrounding write-forwarding logic.
// Good for dedicated Block RAMs, such as M10K.

// The inferred write-forwarding logic also allows the RAM to operate at
// higher frequency, since a read corrupted by a simultaneous write to the
// same address will be discarded and replaced by the write value at the
// output mux of the forwarding logic.

// If you do not want write-forwarding, but keep the high speed, at the price
// of indeterminate behaviour on coincident read/writes, use "no_rw_check" as
// part of the RAMSTYLE (e.g.: "M10K, no_rw_check").
// Depending on the FPGA hardware, this may also help when returning OLD data.

// NOTE: set_global_assignment -name ADD_PASS_THROUGH_LOGIC_TO_INFERRED_RAMS
// OFF to disable creation of write-forwarding logic, as Quartus ignores the
// "no_rw_check" RAMSTYLE for M10K BRAMs.

// Also, we don't want a synchronous clear on the output: 
// any register driving it cannot be retimed, and it may not be as portable.

`default_nettype none

module RAM_SDP 
#(
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       DEPTH               = 0,
    parameter       RAMSTYLE            = "",
    parameter       READ_NEW_DATA       = 0,
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

    localparam ZERO = {WORD_WIDTH{1'b0}};

    initial begin
        read_data = ZERO;
    end

// --------------------------------------------------------------------

    // Example: "M10K"
    (* ramstyle = RAMSTYLE *) 
    reg [WORD_WIDTH-1:0] ram [DEPTH-1:0];

    // The only difference is the use of blocking/non-blocking assignments.
    
    // Blocking assignments make the write happen logically before the read,
    // as ordered here, and thus describe write-forwarding behaviour.

    // NOTE: Using blocking assignments in a clocked always block isn't
    // strictly correct, as they could cause simulation race conditions
    // depending on the order of evaluation of the always blocks. However,
    // I see no simpler way to describe "write-before-read" behaviour while
    // letting the CAD tool decide if it can synthesize it, and how. It might
    // add forwarding logic, or could simply declare the read data "don't
    // care" under a concurrent write to the same address. Check your
    // synthesis results!

    // Non-blocking assignments make them take effect simultaneously at the
    // end of the always block, so the read takes its data from the memory.

    // Conditions not expressed in ?: form since this is for RAM inference
    // There is nothing to do if enables are X or Z

    generate
        // Returns OLD data
        if (READ_NEW_DATA == 0) begin
            always @(posedge clock) begin
                if(wren == 1'b1) begin
                    ram[write_addr] <= write_data;
                end
                if(rden == 1'b1) begin
                    read_data <= ram[read_addr];
                end
            end
        end
        // Returns NEW data
        // This isn't proper, but that's what the CAD tool expects for inference.
        // verilator lint_off BLKSEQ
        else begin
            always @(posedge clock) begin
                if(wren == 1'b1) begin
                    ram[write_addr] = write_data;
                end
                if(rden == 1'b1) begin
                    read_data = ram[read_addr];
                end
            end
        end
        // verilator lint_on BLKSEQ
    endgenerate

// --------------------------------------------------------------------

    // If not using an init file, initially set all memory to zero.
    // The CAD tool should generate a memory initialization file from that.

    // This is useful to cleanly implement small collections of registers (via
    // RAMSTYLE = "logic"), without having to deal with an init file.

    generate
        if (USE_INIT_FILE == 0) begin
            integer i;
            initial begin
                for (i = 0; i < DEPTH; i = i + 1) begin
                    ram[i] = ZERO;
                end
            end
        end
        else begin
            initial begin
                $readmemh(INIT_FILE, ram);
            end
        end
    endgenerate

endmodule

