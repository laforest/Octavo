
// Selects write data between ALU and local data, giving priority to ALU
// writes. Note that the ALU data must come from the previous instruction of
// the same thread (T4, in this case) as the local data, else one thread
// will corrupt the flow of another.

module Write_Priority
#(
    parameter   WORD_WIDTH  = 0
)
(
    input   wire                        clock,
    input   wire                        ALU_wren,
    input   wire    [WORD_WIDTH-1:0]    ALU_data,
    input   wire                        local_wren,
    input   wire    [WORD_WIDTH-1:0]    local_data,
    output  wire                        wren_out,
    output  wire    [WORD_WIDTH-1:0]    data_out
    
);

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]    ALU_data_reg;

    // Synchronize from Thread 6 to Thread 4
    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (WORD_WIDTH)
    )
    ALU_data_pipeline
    (
        .clock  (clock),
        .in     (ALU_data),
        .out    (ALU_data_reg)
    );

// -----------------------------------------------------------

    wire    [WORD_WIDTH-1:0]    ALU_wren_reg;

    // Synchronize from Thread 6 to Thread 4
    delay_line
    #(
        .DEPTH  (2),
        .WIDTH  (1)
    )
    ALU_wren_pipeline
    (
        .clock  (clock),
        .in     (ALU_wren),
        .out    (ALU_wren_reg)
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
        .addr           (ALU_wren_reg),
        .data_in        ({ALU_data_reg, local_data}),
        .data_out       (data_out)
    );

// -----------------------------------------------------------

    always @(*) begin
        wren_out <= local_wren | ALU_wren_reg;
    end
endmodule
