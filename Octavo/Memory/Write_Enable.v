
// For A/B/I/H memories. Don't write on instructions that generate garbage from
// the ALU, and only in your own address space.
// Accepts an external masking wren_other signal for extensibility.

module Write_Enable 
#(
    parameter       OPCODE_WIDTH        = 0,

    parameter       ADDR_COUNT          = 0,
    parameter       ADDR_BASE           = 0,
    parameter       ADDR_WIDTH          = 0
    
)
(
    input   wire    [OPCODE_WIDTH-1:0]  op,
    input   wire    [ADDR_WIDTH-1:0]    addr,
    input   wire                        wren_other,
    output  reg                         wren
);
    wire    addr_wren;

    Address_Decoder
    #(
        .ADDR_COUNT     (ADDR_COUNT), 
        .ADDR_BASE      (ADDR_BASE),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .REGISTERED     (`FALSE)
    )
    addr_space
    (
        .clock          (`LOW),
        .addr           (addr),
        .hit            (addr_wren)   
    );

    reg     op_wren;

    always @(*) begin
        case(op)
            `JMP:       op_wren <= `LOW;
            `JZE:       op_wren <= `LOW;
            `JNZ:       op_wren <= `LOW;
            `JPO:       op_wren <= `LOW;
            `JNE:       op_wren <= `LOW;
            default:    op_wren <= `HIGH;
        endcase
    end

    always @(*) begin
        wren <= op_wren & addr_wren & wren_other;
    end

    initial begin
        wren     = 0;
        op_wren  = 0;
    end
endmodule

