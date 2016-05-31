
// An array of registers, 
// each with an enable bit to update their output, 
// else they stay constant.

module Enabled_Registers 
#(
    parameter       COUNT           = 0, 
    parameter       WIDTH           = 0
) 
(
    input   wire                            clock,
    input   wire    [COUNT-1:0]             enable,
    input   wire    [(COUNT*WIDTH)-1:0]     in,
    output  reg     [(COUNT*WIDTH)-1:0]     out
);
    initial begin
        out <= {(COUNT*WIDTH){`LOW}};
    end

    generate
        integer i, j;
        always @(posedge clock) begin
            for(i = 0; i < COUNT; i = i + 1) begin
                j = i * WIDTH;
                out[j +: WIDTH] = (enable[i] == `HIGH) ? in[j +: WIDTH] : out[j +: WIDTH];
            end
        end
    endgenerate
endmodule

