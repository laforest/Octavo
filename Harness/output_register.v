
// Just a wrapper to deal with the separate wren and data outputs of I/O ports.
// Converts them to a simple data output.

module output_register 
#(
    parameter       WIDTH           = 0
) 
(
    input   wire                    clock,
    input   wire    [WIDTH-1:0]     in,
    input   wire                    wren,
    output  reg     [WIDTH-1:0]     out
);

    always @(posedge clock) begin
        if (wren === `HIGH) begin
            out <= in;
        end
    end

endmodule

