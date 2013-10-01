
module delay_line 
#(
    parameter       DEPTH           = 0, 
    parameter       WIDTH           = 0
) 
(
    input   wire                    clock,
    input   wire    [WIDTH-1:0]     in,
    output  reg     [WIDTH-1:0]     out
);
    generate
        if (DEPTH == 0) begin
            always @(*) begin
                out <= in;
            end
        end
        else begin
            integer i;
            reg [WIDTH-1:0] stage [DEPTH-1:0];

            initial begin
                for(i = 0; i < DEPTH; i = i + 1) begin
                    stage[i] = 0;
                end
            end 

            always @(posedge clock) begin
                stage[0] <= in;
                for(i = 1; i < DEPTH; i = i + 1) begin
                    stage[i] <= stage[i-1];
                end
            end

            always @(*) begin
                out <= stage[DEPTH-1];
            end
        end
    endgenerate
endmodule
