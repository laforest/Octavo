
// An array of registers, 
// each with a new data input,
// each with an enable bit to update its output, 
// else they stay constant.

// This is the way it is because you cannot pass multi-dimensional
// arrays through ports in Verilog-2001.

`default_nettype none

module Register_Array 
#(
    parameter       COUNT               = 0, 
    parameter       WIDTH               = 0,

    // Not for instantiation
    parameter   TOTAL_WIDTH = COUNT * WIDTH
) 
(
    input   wire                        clock,
    input   wire    [COUNT-1:0]         wren,
    input   wire    [TOTAL_WIDTH-1:0]   in,
    output  reg     [TOTAL_WIDTH-1:0]   out
);

// --------------------------------------------------------------------------

    initial begin
        out <= {TOTAL_WIDTH{1'b0}};
    end

    integer i;
    integer j;

    always @(posedge clock) begin
        for(i = 0; i < COUNT; i = i+1) begin
            j = i * WIDTH;
            out[j +: WIDTH] = (wren[i] == 1'b1) ? in[j +: WIDTH] : out[j +: WIDTH];
        end
    end

endmodule

