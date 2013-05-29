`include "params.v"

module alu_test_bench();

    reg                 clock;
    reg                 half_clock;
    reg     `OPCODE     op;
    reg     `A_WORD     A;
    reg     `B_WORD     B;
    wire    `ALU_WORD     R;
    wire    `OPCODE     op_out;

    initial begin
        clock       = 0;
        half_clock  = 0;
        op          = `XOR;
        A           = 0;
        B           = 0;
        `DELAY_CLOCK_CYCLES(100) $stop;
    end

    always begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always begin
        @(posedge clock)
        half_clock <= ~half_clock;
    end

    always begin
        op <= `XOR;
        A  <= `A_WORD_WIDTH'hAAAAAAAAA;
        B  <= `B_WORD_WIDTH'h555555555;
        @(posedge clock);

        op <= `AND;
        A  <= `A_WORD_WIDTH'hAAAAAAAAA;
        B  <= `B_WORD_WIDTH'h555555555;
        @(posedge clock);

        op <= `OR;
        A  <= `A_WORD_WIDTH'hAAAAAAAAA;
        B  <= `B_WORD_WIDTH'h555555555;
        @(posedge clock);

        op <= `SRL;
        A  <= `A_WORD_WIDTH'h808080808;
        B  <= `B_WORD_WIDTH'hFFFFFFFFF;
        @(posedge clock);

        op <= `SRA;
        A  <= `A_WORD_WIDTH'h808080808;
        B  <= `B_WORD_WIDTH'hFFFFFFFFF;
        @(posedge clock);

        op <= `ADD;
        A  <= `A_WORD_WIDTH'hFFFFFFFFF;
        B  <= `B_WORD_WIDTH'h000000001;
        @(posedge clock);

        op <= `SUB;
        A  <= `A_WORD_WIDTH'h000000002;
        B  <= `B_WORD_WIDTH'h000000003;
        @(posedge clock);

        op <= `SUB;
        A  <= `A_WORD_WIDTH'h000000001;
        B  <= `B_WORD_WIDTH'h000000003;
        @(posedge clock);

        op <= `YES;
        A  <= `A_WORD_WIDTH'h808080808;
        B  <= `B_WORD_WIDTH'h101010101;
        @(posedge clock);


        op <= `MLO;
        A  <= `A_WORD_WIDTH'h0000FFFFF;
        B  <= `B_WORD_WIDTH'h0000FFFFF;
        @(posedge clock);

        op <= `MHI;
        A  <= `A_WORD_WIDTH'h0000FFFFF;
        B  <= `B_WORD_WIDTH'h0000FFFFF;
        @(posedge clock);
    end

    alu dut(
        .clock(clock),
        .half_clock(half_clock),
        .op_in(op),
        .A(A),
        .B(B),
        .R(R),
        .op_out(op_out)
    );

endmodule
