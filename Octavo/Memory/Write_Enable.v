
module Write_Enable 
#(
    parameter       OPCODE_WIDTH        = 0
)
(
    input   wire    [OPCODE_WIDTH-1:0]  op,
    input   wire                        wren_other,
    output  reg                         wren
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
        wren <= op_wren & wren_other;
    end

    initial begin
        wren     = 0;
        op_wren  = 0;
    end
endmodule

