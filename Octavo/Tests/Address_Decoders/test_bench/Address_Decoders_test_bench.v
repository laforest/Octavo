
module Address_Decoders_test_bench
#(
    parameter       WORD_WIDTH          = 36
)
(
);

// --------------------------------------------------------------------

    integer                             cycle;
    reg                                 clock;

    reg     [WORD_WIDTH-1:0]            base_addr;
    reg     [WORD_WIDTH-1:0]            bound_addr;
    reg     [WORD_WIDTH-1:0]            addr;
    
    reg                                 hit_static;
    reg                                 hit_arithm;
    reg                                 hit_struct;

    initial begin
        $dumpfile("Address_Decoders_test_bench.vcd");
        //$dumpvars(0);
        cycle       = 0;
        clock       = 0;
        base_addr   = 'd557;
        bound_addr  = 'd666;
        addr        = 'd0;
        `DELAY_CLOCK_CYCLES(1024) $finish;
    end

    always @(*) begin
        `DELAY_CLOCK_HALF_PERIOD clock <= ~clock;
    end

    always @(posedge clock) begin
        cycle <= cycle + 1;
    end

    always @(posedge clock) begin
        `DELAY_CLOCK_CYCLES(1);
        addr = addr + 'd1;   
    end

// --------------------------------------------------------------------

    Address_Decoder_Static
    #(
        .ADDR_WIDTH (WORD_WIDTH),
        .ADDR_BASE  (base_addr),
        .ADDR_BOUND (bound_addr)
    )
    Static
    (
        .addr       (addr_in),
        .hit        (hit_static)
    );

    Address_Decoder_Arithmetic
    #(
        .ADDR_WIDTH (WORD_WIDTH)
    )
    Arithm
    (
        .base_addr  (base_addr),
        .bound_addr (bound_addr),
        .addr       (addr_in),
        .hit        (hit_arithm)
    );

    Address_Decoder_Arithmetic_Structural
    #(
        .ADDR_WIDTH (WORD_WIDTH)
    )
    Struct
    (
        .base_addr  (base_addr),
        .bound_addr (bound_addr),
        .addr       (addr_in),
        .hit        (hit_struct)
    );

endmodule

