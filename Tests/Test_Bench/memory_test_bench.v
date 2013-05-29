`include "params.v"

module memory_test_bench();

    reg                                                     clock;
    reg                                                     wren;
    reg     `ADDR                                           write_addr;
    reg     `WORD                                           write_data;
    reg     `ADDR                                           read_addr_0;
    wire    `WORD                                           read_data_0;
    reg     `ADDR                                           read_addr_1;
    wire    `WORD                                           read_data_1;
    reg     `ADDR                                           instr_addr;
    wire    `WORD                                           instr_data;
    reg     `WORD_ARRAY(`IO_DEPTH * `MAPPED_DATA_PORTS)     io_in;
    wire    `IO_ARRAY(`MAPPED_DATA_PORTS)                   io_wren;
    wire    `WORD_ARRAY(`IO_DEPTH * `MAPPED_DATA_PORTS)     io_out;

    initial begin
        clock       = 0;
        wren        = 0;
        write_addr  = 0;
        write_data  = 0;
        read_addr_0 = 0;
        read_addr_1 = 0;
        instr_addr  = 0;
        io_in       = 0;
        `DELAY_CLOCK_CYCLES(100) $stop;
    end

    always begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always begin
        wren        <= `HIGH;
        read_addr_0 <= `ADDR_WIDTH'h000;
        read_addr_1 <= `ADDR_WIDTH'h000;
        instr_addr  <= `ADDR_WIDTH'h000;
        io_in       <= {`WORD_WIDTH'h111111111, `WORD_WIDTH'h222222222, `WORD_WIDTH'h333333333, `WORD_WIDTH'h444444444, `WORD_WIDTH'h555555555, `WORD_WIDTH'h666666666, `WORD_WIDTH'h777777777, `WORD_WIDTH'h888888888};

        write_addr  <= `ADDR_WIDTH'h010;
        write_data  <= `WORD_WIDTH'h000000001;
        @(posedge clock);

        write_addr  <= `ADDR_WIDTH'h020;
        write_data  <= `WORD_WIDTH'h000000002;
        @(posedge clock);

        write_addr  <= `ADDR_WIDTH'h030;
        write_data  <= `WORD_WIDTH'h000000003;
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
        @(posedge clock);

        read_addr_0 <= `ADDR_WIDTH'h010;
        read_addr_1 <= `ADDR_WIDTH'h020;
        instr_addr  <= `ADDR_WIDTH'h030;
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
        @(posedge clock);

        write_addr  <= `ADDR_WIDTH'h3FE;
        write_data  <= `WORD_WIDTH'h123456789;
        @(posedge clock);

        read_addr_0 <= `ADDR_WIDTH'h3FD;
        read_addr_1 <= `ADDR_WIDTH'h3FE;
        instr_addr  <= `ADDR_WIDTH'h3FF;
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
        @(posedge clock);

        write_addr  <= `ADDR_WIDTH'h3FF;
        write_data  <= `WORD_WIDTH'h987654321;
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
        @(posedge clock);

/*
        wren        <= `HIGH;
        write_addr  <= `ADDR_WIDTH'h3FC;
        write_data  <= `WORD_WIDTH'h121212121;
        @(posedge clock);

        wren        <= `HIGH;
        write_addr  <= `ADDR_WIDTH'h3FD;
        write_data  <= `WORD_WIDTH'h232323232;
        @(posedge clock);

        wren        <= `HIGH;
        write_addr  <= `ADDR_WIDTH'h3FE;
        write_data  <= `WORD_WIDTH'h343434343;
        @(posedge clock);

        wren        <= `HIGH;
        write_addr  <= `ADDR_WIDTH'h3FF;
        write_data  <= `WORD_WIDTH'h454545454;
        read_addr_0 <= `ADDR_WIDTH'h3FF;
        read_addr_1 <= `ADDR_WIDTH'h3FF;
        instr_addr  <= `ADDR_WIDTH'h3FF;
        @(posedge clock);
*/

    end

    memory dut(
        .clock(clock),

        .wren(wren),
        .write_addr(write_addr),
        .write_data(write_data),

        .read_addr_0(read_addr_0),
        .read_data_0(read_data_0),
        .read_addr_1(read_addr_1),
        .read_data_1(read_data_1),
        .instr_addr(instr_addr),
        .instr_data(instr_data),

        .io_in(io_in),
        .io_wren(io_wren),
        .io_out(io_out)
    );

endmodule
