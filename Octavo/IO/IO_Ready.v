
// Declares I/O ready if the Empty/Full bit is at the READY_STATE (FULL for
// reads, EMPTY for writes) and the combined EF bits from the other ports
// (AND'ed and inverted as required) are also ready.

module IO_Ready
#(
    parameter   READY_STATE = `FULL,
    parameter   REGISTERED  = `FALSE
)
(
    input   wire            clock,
    input   wire            addr_is_IO,
    input   wire            port_EF,
    input   wire            other_port_EF,
    output  reg             port_EF_masked,
    output  reg             port_IO_ready
);
    always @(*) begin
        if (addr_is_io === `HIGH) begin
            port_EF_masked <= port_EF;
        end 
        else begin
            port_EF_masked <= READY_STATE;
        end
    end

    wire ready;

    if (READY_STATE === `FULL) begin
        ready <= &  {port_EF_masked, other_port_EF};
    end
    else begin
        ready <= & ~{port_EF_masked, other_port_EF};
    end

    generate
        if (REGISTERED == `TRUE) begin
            always @(posedge clock) begin
                port_io_ready <= ready;
            end

            initial begin
                port_io_ready = 0;
            end
        end
        else begin
            always @(*) begin
                port_io_ready <= ready;
            end
        end
    endgenerate
endmodule

