
// True Dual Port RAM, made for on-chip Block RAMs (BRAMs) and LUT-RAM.
// Two read/write ports, separately addressed, with a common clock.
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

module RAM_TDP 
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

    input  wire                         wren_A,
    input  wire     [ADDR_WIDTH-1:0]    addr_A,
    input  wire     [WORD_WIDTH-1:0]    write_data_A,
    output reg      [WORD_WIDTH-1:0]    read_data_A,

    input  wire                         wren_B,
    input  wire     [ADDR_WIDTH-1:0]    addr_B,
    input  wire     [WORD_WIDTH-1:0]    write_data_B,
    output reg      [WORD_WIDTH-1:0]    read_data_B
);

// --------------------------------------------------------------------

    initial begin
        read_data_A = 0;
        read_data_B = 0;
    end

// --------------------------------------------------------------------

    // Example: "M10K"
    (* ramstyle  = RAMSTYLE *) 
    (* ram_style = RAMSTYLE *) 
    reg [WORD_WIDTH-1:0] ram [DEPTH-1:0];

    // The only difference is the use of blocking/non-blocking assignments.
    
    // Blocking assignments make the write happen logically before the read,
    // as ordered here, and thus describe write-forwarding behaviour.

    // Non-blocking assignments make them take effect simultaneously at the
    // end of the always block, so the read takes its data from the memory.

    // Conditions not expressed in ?: form since this is for RAM inference
    // There is nothing to do if enables are X or Z

    // We place ports A and B in their own always blocks to express they
    // have no priority between them. (Else, in the blocking assignment case,
    // the first port would have priority over the second, and that may not
    // infer properly as Block RAM.)

    generate
        // Returns OLD data
        if (READ_NEW_DATA == 0) begin
            always @(posedge clock) begin
                if(wren_A == 1) begin
                    ram[addr_A] <= write_data_A;
                end
                read_data_A <= ram[addr_A];
            end

            always @(posedge clock) begin
                if(wren_B == 1) begin
                    ram[addr_B] <= write_data_B;
                end
                read_data_B <= ram[addr_B];
            end
        end
        // Returns NEW data
        else begin
            always @(posedge clock) begin
                if(wren_A == 1) begin
                    ram[addr_A] = write_data_A;
                end
                read_data_A = ram[addr_A];
            end

            always @(posedge clock) begin
                if(wren_B == 1) begin
                    ram[addr_B] = write_data_B;
                end
                read_data_B = ram[addr_B];
            end
        end
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
                    ram[i] = 0;
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

