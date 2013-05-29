`include "params.v"

module DE4_test_bench();

    reg                                 input_clock;
    reg     [1:0]                       push_button;
    reg     [7:0]                       dip_switch;
    wire    [7:0]                       led;

    reg                                 A_dummy_in; 
    wire                                A_dummy_wren; 
    wire                                A_dummy_out; 

    reg                                 B_dummy_in; 
    wire                                B_dummy_wren; 
    wire                                B_dummy_out;

    initial begin
        input_clock     = 0;
        push_button     = 0;
        dip_switch      = 0;
        A_dummy_in      = 0;
        B_dummy_in      = 0;
        `DELAY_CLOCK_CYCLES(5000) $stop;
    end

    always begin
        `DELAY_CLOCK_HALF_PERIOD input_clock <= ~input_clock;
    end

    always begin

        // Test for steady output
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h10;

/***********************************************
        // Test individual threads
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h01;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h02;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h04;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h08;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h10;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h20;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h40;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h80;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h00;

        // Test multiple threads
        // Output should iterate between thread ids
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h11;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h22;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h44;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h88;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h18;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h24;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h42;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'h81;
        `DELAY_CLOCK_CYCLES(53)
        dip_switch = 8'hFF;
***********************************************/

    end

DE4_test DUT (
    .input_clock(input_clock),
    .push_button(push_button),
    .dip_switch(dip_switch),
    .led(led),

    .A_dummy_in(A_dummy_in), 
    .A_dummy_wren(A_dummy_wren), 
    .A_dummy_out(A_dummy_out), 

    .B_dummy_in(B_dummy_in), 
    .B_dummy_wren(B_dummy_wren), 
    .B_dummy_out(B_dummy_out) 
);

endmodule
