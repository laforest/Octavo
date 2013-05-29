`include "params.v"

module controller_test_bench();

    reg             clock;
    reg     `WORD   A;
    reg     `OPCODE op;
    reg     `ADDR   D;
    wire    `ADDR   pc;

    initial begin
        clock       = 0;
        A           = 0;
        op          = 0; // XOR
        D           = 0;
        `DELAY_CLOCK_CYCLES(100) $stop;
    end

    always begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always begin
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        
        A  = `WORD_WIDTH'd0;
        op = `JMP;
        D  = `ADDR_WIDTH'd55;

        @(posedge clock);

        A  = `WORD_WIDTH'd0;
        op = `XOR;
        D  = `ADDR_WIDTH'd0;

        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
    end

controller dut (
    .clock(clock),
    .A(A),
    .op(op),
    .D(D),
    .pc(pc)
);

endmodule
