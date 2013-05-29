`include "../Misc/params.v"

// Simple switches-and-lights existence proof test for the CPU on DE4.

module DE4_test (
    input   wire                                input_clock,
    input   wire    [1:0]                       push_button,
    input   wire    [7:0]                       dip_switch,
    output  reg     [7:0]                       led,

    input   wire                                A_dummy_in, 
    output  wire                                A_dummy_wren, 
    output  wire                                A_dummy_out, 

    input   wire                                B_dummy_in, 
    output  wire                                B_dummy_wren, 
    output  wire                                B_dummy_out 
);

    wire    clock;
    wire    half_clock;

    PLL_clock PLL_clock (
        .inclk0(input_clock),
        .c0(clock),
        .c1(half_clock)
    );


// *****************************************************************

    `define A_DUMMY_IN_WIDTH ((`A_WORD_WIDTH * `A_IO_DEPTH) - 2 - 8)

    wire    [`A_DUMMY_IN_WIDTH-1:0]     dut_A_dummy_in;
    wire    `A_IO_ARRAY(1)              dut_A_dummy_wren;
    wire    `A_WORD_ARRAY(`A_IO_DEPTH)  dut_A_dummy_out;

    shift_register 
    #(.WIDTH(`A_DUMMY_IN_WIDTH))
    sr_A_io_in (
            .clock(clock),
            .input_port(A_dummy_in),
            .output_port(dut_A_dummy_in)
    );

    registered_reducer 
    #(.WIDTH(`A_IO_DEPTH)) 
    rr_A_io_wren (
            .clock(clock),
            .input_port(dut_A_dummy_wren),
            .output_port(A_dummy_wren)
        );

    registered_reducer 
    #(.WIDTH(`A_WORD_WIDTH * `A_IO_DEPTH)) 
    rr_A_io_out (
            .clock(clock),
            .input_port(dut_A_dummy_out),
            .output_port(A_dummy_out)
        );

// *****************************************************************

    `define B_DUMMY_OUT_WIDTH ((`B_WORD_WIDTH * `B_IO_DEPTH) - 8)

    wire    [`B_DUMMY_OUT_WIDTH-1:0]    dut_B_dummy_out;
    wire    [`B_IO_DEPTH-1-1:0]         dut_B_dummy_wren;
    wire    `B_WORD_ARRAY(`B_IO_DEPTH)  dut_B_dummy_in;

    shift_register 
    #(.WIDTH(`A_WORD_WIDTH * `A_IO_DEPTH))
    sr_B_io_in (
            .clock(clock),
            .input_port(B_dummy_in),
            .output_port(dut_B_dummy_in)
    );

    registered_reducer 
    #(.WIDTH(`B_IO_DEPTH - 1)) 
    rr_B_io_wren (
            .clock(clock),
            .input_port(dut_B_dummy_wren),
            .output_port(B_dummy_wren)
        );

    registered_reducer 
    #(.WIDTH(`B_DUMMY_OUT_WIDTH)) 
    rr_B_io_out (
            .clock(clock),
            .input_port(dut_B_dummy_out),
            .output_port(B_dummy_out)
        );

// *****************************************************************

    wire    [7:0]   dut_led;
    wire            led_wren;

    cpu cpu (
        .clock(clock),
        .half_clock(half_clock),

        .A_io_in({dut_A_dummy_in, push_button, dip_switch}),
        .A_io_wren(dut_A_dummy_wren),
        .A_io_out(dut_A_dummy_out),

        .B_io_in(dut_B_dummy_in),
        .B_io_wren({dut_B_dummy_wren, led_wren}),
        .B_io_out({dut_B_dummy_out, dut_led})
    );

    always @(posedge clock) begin
        if (led_wren === `HIGH) begin
            led <= dut_led;
        end
    end

endmodule

/**********************************************************
module DUT (
    input   wire                                clock,

    input   wire    `A_WORD_ARRAY(`A_IO_DEPTH)  A_io_in,
    output  wire    `A_IO_ARRAY(1)              A_io_wren,
    output  wire    `A_WORD_ARRAY(`A_IO_DEPTH)  A_io_out,

    input   wire    `B_WORD_ARRAY(`B_IO_DEPTH)  B_io_in,
    output  wire    `B_IO_ARRAY(1)              B_io_wren,
    output  wire    `B_WORD_ARRAY(`B_IO_DEPTH)  B_io_out
);

    wire    full_clock;
    wire    half_clock;

cpu cpu (
    .clock(full_clock),
    .half_clock(half_clock),

    .A_io_in(A_io_in),
    .A_io_wren(A_io_wren),
    .A_io_out(A_io_out),

    .B_io_in(B_io_in),
    .B_io_wren(B_io_wren),
    .B_io_out(B_io_out)
);

endmodule
**********************************************************/
