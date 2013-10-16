
// A common idiom: mux some inputs based on a consecutive, but not aligned,
// address range.

module Translated_Addressed_Mux
#(
    parameter       WORD_WIDTH                          = 0,
    parameter       ADDR_WIDTH                          = 0,
    parameter       INPUT_COUNT                         = 0,
    parameter       INPUT_BASE_ADDR                     = 0,
    parameter       INPUT_ADDR_WIDTH                    = 0,
    parameter       REGISTERED                          = `FALSE
)
(
    input   wire                                        clock,
    input   wire    [ADDR_WIDTH-1:0]                    addr,
    input   wire    [(INPUT_COUNT * WORD_WIDTH)-1:0]    data_in, 
    output  wire    [WORD_WIDTH-1:0]                    data_out
);

    wire [INPUT_ADDR_WIDTH-1:0]  addr_translated;

    Address_Translator 
    #(
        .ADDR_COUNT             (INPUT_COUNT),
        .ADDR_BASE              (INPUT_BASE_ADDR),
        .ADDR_WIDTH             (INPUT_ADDR_WIDTH)
    )
    Address_Translator
    (
        .raw_address            (addr[INPUT_ADDR_WIDTH-1:0]),
        .translated_address     (addr_translated)
    );         

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (INPUT_ADDR_WIDTH),
        .INPUT_COUNT    (INPUT_COUNT),
        .REGISTERED     (REGISTERED)
    )
    Addressed_Mux
    (
        .clock          (clock),
        .addr           (addr_translated),
        .data_in        (data_in),
        .data_out       (data_out)
    );
endmodule

