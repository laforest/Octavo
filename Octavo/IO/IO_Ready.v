
// Declares I/O ready if the Empty/Full bit is at the READY_STATE (FULL for
// reads, EMPTY for writes) and the combined EF bits from the other ports
// (AND'ed and inverted as required) are also ready.

// We output both registered and unregistered I/O ready.  The unregistered
// version is for global I/O ready signalling, for predication.

module IO_Ready
#(
    parameter   READY_STATE = `FULL
)
(
    input   wire            clock,
    input   wire            addr_is_IO,
    input   wire            port_EF,
    input   wire            other_port_EF,

    output  reg             port_IO_ready
    output  reg             port_EF_masked,
    output  reg             port_IO_ready_reg
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

    always @(*) begin
        port_io_ready <= ready;
    end

    always @(posedge clock) begin
        port_io_ready_reg <= ready;
    end

    initial begin
        port_io_ready_reg = 0;
    end
endmodule

