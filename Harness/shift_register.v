
module  shift_register
#(
    parameter   integer WIDTH           = 0
)
(
    input       wire                    clock,    
    input       wire                    input_port,
    input       wire                    read_enable,
    output      reg     [WIDTH-1:0]     output_port
);
    always @(posedge clock) begin
        if (read_enable === `HIGH) begin
            output_port <= output_port << 1 | input_port;   
        end
    end
endmodule

