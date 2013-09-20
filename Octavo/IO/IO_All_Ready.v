
// Simply ANDs and registers all the masked Empty/Full bits, producing the
// global signal that all addressed I/O ports are ready.  EF bits from write
// ports must be inverted first, since `EMPTY is their ready state.

module IO_All_Ready
#(
    parameter   READ_PORT_COUNT             = 0,
    parameter   WRITE_PORT_COUNT            = 0
)
(
    input   wire                            clock,
    input   wire    [READ_PORT_COUNT-1:0]   read_EF,
    input   wire    [WRITE_PORT_COUNT-1:0]  write_EF,
    output  reg                             ready
);
    wire read_ready;
    wire write_ready;

    read_ready  <= &  read_EF;
    write_ready <= & ~write_EF;

    always @(posedge clock) begin
        ready <= read_ready & write_ready;
    end

    initial begin
        ready = 0;
    end
endmodule

