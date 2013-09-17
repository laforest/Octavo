
// Declares I/O ready if ALL Empty/Full bits are Full for reads and Empty for
// Writes, if ANY of the reads and write refer to I/O ports. Otherwise, I/O
// (RAM, actually) is always ready.

module IO_Ready
#(
    parameter   REGISTERED  = `FALSE
)
(
    input   wire            clock,

    input   wire            A_read_is_IO,
    input   wire            A_write_is_IO,
    input   wire            B_read_is_IO,
    input   wire            B_write_is_IO,

    input   wire            A_read_EF,
    input   wire            A_write_EF,
    input   wire            B_read_EF,
    input   wire            B_write_EF,

    output  reg             all_IO_ready
);
    integer i;

    reg     A_read_EF_masked;

    always @(*) begin
        if (A_read_is_io === `HIGH) begin
            A_read_EF_masked <= A_read_EF;
        end 
        else begin
            A_read_EF_masked <= `FULL;
        end
    end

    reg     A_write_EF_masked;

    always @(*) begin
        if (A_write_is_io === `HIGH) begin
            A_write_EF_masked <= A_write_EF;
        end 
        else begin
            A_write_EF_masked <= `EMPTY;
        end
    end

    reg     B_read_EF_masked;

    always @(*) begin
        if (B_read_is_io === `HIGH) begin
            B_read_EF_masked <= B_read_EF;
        end 
        else begin
            B_read_EF_masked <= `FULL;
        end
    end

    reg     B_write_EF_masked;

    always @(*) begin
        if (B_write_is_io === `HIGH) begin
            B_write_EF_masked <= B_write_EF;
        end 
        else begin
            B_write_EF_masked <= `EMPTY;
        end
    end

    reg     all_reads_ready;
    reg     all_writes_ready;

    always @(*) begin
        all_reads_ready  <= &  {A_read_EF_masked,  B_read_EF_masked};
        all_writes_ready <= & ~{A_write_EF_masked, B_write_EF_masked};
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

