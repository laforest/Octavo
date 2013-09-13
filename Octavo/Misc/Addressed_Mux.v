
module Addressed_Mux
#(
    parameter       WORD_WIDTH                          = 0,
    parameter       ADDR_WIDTH                          = 0,
    parameter       INPUT_COUNT                         = 0,
    parameter       REGISTERED                          = `FALSE
)
(
    input   wire                                        clock,
    input   wire    [ADDR_WIDTH-1:0]                    addr,    
    input   wire    [(WORD_WIDTH * INPUT_COUNT)-1:0]    data_in,
    output  reg     [WORD_WIDTH-1:0]                    data_out
);
    generate
        if (REGISTERED == `TRUE) begin
            always @(posedge clock) begin
                data_out   <= data_in[(addr * WORD_WIDTH) +: WORD_WIDTH];
            end

            initial begin
                data_out = 0;
            end
        end
        else begin
            always @(*) begin
                data_out   <= data_in[(addr * WORD_WIDTH) +: WORD_WIDTH];
            end
        end
    endgenerate
endmodule

