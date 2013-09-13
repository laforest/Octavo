
// Empty/Full Bit to control I/O between read/write ports 
// Some extra logic added to support pipelined simultaneous reads/writes.

// ECL I'm not really happy with this yet: can we clarify the implementation?

// read, write, EF  ||  EF (next), read_EF, write_EF
// 0 0 0 || 0 0 0
// 0 0 1 || 1 1 1
// 0 1 0 || 1 0 0
// 0 1 1 || 1 1 1
// 1 0 0 || 0 0 0
// 1 0 1 || 0 1 1
// 1 1 0 || 1 0 0
// 1 1 1 || 1 1 0 *write_EF appears empty instead, allowing pipelined operation*

module EmptyFullBit
// #(
// )
(
    input   wire    clock,
    input   wire    read,
    input   wire    write,
    output  reg     read_EF,
    output  reg     write_EF
);
    reg     EmptyFull;

    always @(*) begin
        read_EF     <= EmptyFull;
        write_EF    <= (~read | ~write) & EmptyFull;
    end

    always @(posedge clock) begin
        EmptyFull   <= write | (~read & EmptyFull);        
    end

    initial begin
        EmptyFull   = `EMPTY;
    end

endmodule


