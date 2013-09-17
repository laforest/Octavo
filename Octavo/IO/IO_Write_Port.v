
// Simply passes the I/O write enables along, and fans out the ALU output to
// all the write ports. All the decoding has already been done earlier.

module IO_Write 
#(
    parameter       A_WORD_WIDTH                                = 0,
    parameter       B_WORD_WIDTH                                = 0,
    parameter       ALU_WORD_WIDTH                              = 0,
    parameter       A_WRITE_PORT_COUNT                          = 0,
    parameter       B_WRITE_PORT_COUNT                          = 0
)
(
    input   wire                                                clock,

    input   wire    [A_WRITE_PORT_COUNT-1:0]                    A_write_in,
    input   wire    [B_WRITE_PORT_COUNT-1:0]                    B_write_in,

    input   wire    [ALU_WORD_WIDTH-1:0]                        write_data_in,

    output  reg     [A_WRITE_PORT_COUNT-:0]                     A_write_out,
    output  reg     [(A_WORD_WIDTH * A_WRITE_PORT_COUNT)-1:0]   A_write_data_out    

    output  reg     [B_WRITE_PORT_COUNT-:0]                     B_write_out,
    output  reg     [(B_WORD_WIDTH * B_WRITE_PORT_COUNT)-1:0]   B_write_data_out    
);

    // Pass-through 
    always @(posedge clock) begin
        A_write_out <= A_write_in;
        B_write_out <= B_write_in;
    end

    // Write Data, fan-out to all ports
    always @(posedge clock) begin
        for(port = 0; port < A_WRITE_PORT_COUNT; port = port + 1) begin
            A_write_data_out[(port * A_WORD_WIDTH) +: A_WORD_WIDTH] <= write_data_in[A_WORD_WIDTH-1:0];
        end
    end

    always @(posedge clock) begin
        for(port = 0; port < B_WRITE_PORT_COUNT; port = port + 1) begin
            B_write_data_out[(port * B_WORD_WIDTH) +: B_WORD_WIDTH] <= write_data_in[B_WORD_WIDTH-1:0];
        end
    end

    initial begin
        A_write_out      = 0;
        B_write_out      = 0;
        A_write_data_out = 0;
        B_write_data_out = 0;
    end
endmodule

