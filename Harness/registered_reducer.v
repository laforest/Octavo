
module registered_reducer 
#(
    parameter   integer WIDTH           = 0
) 
(
    input       wire                    clock,
    input       wire    [WIDTH-1:0]     input_port,
    output      reg                     output_port
);
    reg [WIDTH-1:0] output_registers;

    always @(posedge clock) begin
        output_registers    <= input_port;   
    end

    always @(*) begin
        output_port         <= &output_registers;
    end
endmodule
