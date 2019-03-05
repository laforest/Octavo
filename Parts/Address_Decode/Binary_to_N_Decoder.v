
// Generates a bit vector of up to 2^N bits with one bit set representing the
// binary value fed to it.

// The output vector width may be more or less than all possible binary values.
// If the binary value does not map to any of the output bits, the vector
// stays at zero.

// This may fail for binary words of more than 32 bits.

`default_nettype none

module Binary_to_N_Decoder
#(
    parameter       BINARY_WIDTH        = 0,
    parameter       OUTPUT_WIDTH        = 0 
)
(
    input   wire    [BINARY_WIDTH-1:0]  in,
    output  reg     [OUTPUT_WIDTH-1:0]  out
);

    initial begin
        out = {OUTPUT_WIDTH{1'b0}};
    end

    integer count;

    always @(*) begin
        for(count = 0; count < OUTPUT_WIDTH; count = count + 1) begin
            out[count +: 1] = (count[BINARY_WIDTH-1:0] == in);
        end 
    end

endmodule

