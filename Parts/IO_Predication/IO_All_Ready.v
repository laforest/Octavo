
// Simply ANDs all the masked Empty/Full bits, producing the global signal
// that all I/O ports addressed by an instruction are ready.

// EF bits from write ports must be inverted first, since EMPTY (0) is their
// ready state.

`default_nettype none

module IO_All_Ready
#(
    parameter   READ_PORT_COUNT             = 0,
    parameter   WRITE_PORT_COUNT            = 0
)
(
    input   wire    [READ_PORT_COUNT-1:0]   read_EF,
    input   wire    [WRITE_PORT_COUNT-1:0]  write_EF,
    output  reg                             IO_ready
);

    initial begin
        IO_ready = 0;
    end

    reg read_ready  = 0;
    reg write_ready = 0;

    always @(*) begin
        read_ready  = &read_EF;
        write_ready = &(~write_EF);
        IO_ready    = read_ready & write_ready;
    end

endmodule

