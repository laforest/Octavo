
// Declares I/O ready if ALL Empty/Full bits are Full for reads and Empty for
// Writes, if ANY of the reads and write refer to I/O ports. Otherwise, I/O
// (RAM, actually) is always ready.

module IO_Ready
#(
    parameter   IO_READ_PORT_COUNT  = 0,
    parameter   IO_WRITE_PORT_COUNT = 0,
    parameter   REGISTERED          = `FALSE
)
(
    input   wire                                clock,
    input   wire    [IO_READ_PORT_COUNT-1:0]    read_is_io,
    input   wire    [IO_WRITE_PORT_COUNT-1:0]   write_is_io,
    input   wire    [IO_READ_PORT_COUNT-1:0]    read_EF,
    input   wire    [IO_WRITE_PORT_COUNT-1:0]   write_EF,
    output  reg                                 all_io_ready
);
    integer i;

    reg     [IO_READ_PORT_COUNT-1:0]    read_EF_masked;
    reg     [IO_WRITE_PORT_COUNT-1:0]   write_EF_masked;

    always @(*) begin
        for (i = 0; i < IO_READ_PORT_COUNT; i = i + 1) begin
            if (read_is_io[i] === `HIGH) begin
                read_EF_masked <= read_EF;
            end 
            else begin
                read_EF_masked <= `FULL;
            end
        end
    end

    always @(*) begin
        for (i = 0; i < IO_WRITE_PORT_COUNT; i = i + 1) begin
            if (write_is_io[i] === `HIGH) begin
                write_EF_masked <= write_EF;
            end 
            else begin
                write_EF_masked <= `EMPTY;
            end
        end
    end

    reg     all_reads_ready;
    reg     all_writes_ready;

    always @(*) begin
        all_reads_ready  <= & read_EF_masked;
        all_writes_ready <= & ~write_EF_masked;
    end

    generate
        if (REGISTERED == `TRUE) begin
            always @(posedge clock) begin
                all_io_ready <= all_reads_ready & all_writes_ready;
            end

            initial begin
                all_io_ready = 0;
            end
        end
        else begin
            always @(*) begin
                all_io_ready <= all_reads_ready & all_writes_ready;
            end
        end
    endgenerate
endmodule

