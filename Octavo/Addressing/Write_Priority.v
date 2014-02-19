
// Selects write data between ALU and local data, giving priority to ALU
// writes. Note that the ALU data must come from the previous instruction of
// the same thread (T4, in this case) as the local data, else one thread
// will corrupt the flow of another. See Write_Synchronize also.

module Write_Priority
#(
    parameter   WORD_WIDTH              = 0,
    parameter   ADDR_WIDTH              = 0
)
(
    input   wire                        clock,

    input   wire                        ALU_wren,
    input   wire    [ADDR_WIDTH-1:0]    ALU_write_addr,
    input   wire    [WORD_WIDTH-1:0]    ALU_write_data,

    input   wire                        local_wren,
    input   wire    [ADDR_WIDTH-1:0]    local_write_addr,
    input   wire    [WORD_WIDTH-1:0]    local_write_data,

    output  reg                         wren,
    output  wire    [ADDR_WIDTH-1:0]    write_addr,
    output  wire    [WORD_WIDTH-1:0]    write_data
    
);

// -----------------------------------------------------------

    always @(*) begin
        wren <= local_wren | ALU_wren;
    end

// -----------------------------------------------------------

    Addressed_Mux
    #(
        .WORD_WIDTH     (ADDR_WIDTH),
        .ADDR_WIDTH     (1),
        .INPUT_COUNT    (2),
        .REGISTERED     (`FALSE) 
    )
    write_addr_selector
    (
        .clock          (clock),
        .addr           (ALU_wren),
        .data_in        ({ALU_write_addr, local_write_addr}),
        .data_out       (write_addr)
    );

// -----------------------------------------------------------

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (1),
        .INPUT_COUNT    (2),
        .REGISTERED     (`FALSE) 
    )
    write_data_selector
    (
        .clock          (clock),
        .addr           (ALU_wren),
        .data_in        ({ALU_write_data, local_write_data}),
        .data_out       (write_data)
    );

endmodule
