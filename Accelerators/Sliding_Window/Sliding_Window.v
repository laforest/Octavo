
// Buffers SIMD writes into a sliding window for SIMD reads.
// Enables SIMD FIR calculations and maybe other sliding window algorithms.

// ECL XXX FIXME This code is ugly: separate into two shift register modules.

module Sliding_Window
#(
    parameter   WORD_WIDTH  = 36,
    parameter   LANES       = 8
)
(
    input   wire                                clock,
    input   wire                                in_write,
    input   wire    [(LANES * WORD_WIDTH)-1:0]  in,
    input   wire                                out_read,
    output  reg     [(LANES * WORD_WIDTH)-1:0]  out
);

    reg [WORD_WIDTH-1:0] write_window [LANES-1:0];
    reg [WORD_WIDTH-1:0] read_window  [LANES-1:0];
    integer i;

    initial begin
        for (i = 0; i < LANES; i =i + 1) begin
            write_window[i] <= 0;
            read_window[i]  <= 0;
        end
    end

    always @(posedge clock) begin
        case ({in_write, out_read})
            {`LOW, `LOW}: begin
                // nothing
            end
            {`LOW, `HIGH}: begin
                //shift

                // bottom --> top
                for (i = 0; i < LANES-1; i =i + 1) begin
                    write_window[i] <= write_window[i+1];
                end
                write_window[LANES-1] <= 0;

                // top --> top
                read_window[0] <= write_window[0];

                // top --> bottom
                for (i = 1; i < LANES; i =i + 1) begin
                    read_window[i] <= read_window[i-1];
                end
            end
            
            {`HIGH, `LOW}: begin
                // load
                for (i = 0; i < LANES; i =i + 1) begin
                    write_window[i] <= in[(i * WORD_WIDTH) +: WORD_WIDTH];
                end
            end
            
            {`HIGH, `HIGH}: begin
                // shift and load
                // Do this when there is still one value in the write_window 
                // (every LANES-1 reads)
                // to prevent a gap from the concurrent shift.

                // load
                for (i = 0; i < LANES; i =i + 1) begin
                    write_window[i] <= in[(i * WORD_WIDTH) +: WORD_WIDTH];
                end

                // top --> top
                read_window[0] <= write_window[0];

                // top --> bottom
                for (i = 1; i < LANES; i =i + 1) begin
                    read_window[i] <= read_window[i-1];
                end
            end
        endcase
    end

    always @(*) begin
        for (i = 0; i < LANES; i =i + 1) begin
            out[(i * WORD_WIDTH) +: WORD_WIDTH] <= read_window[i];
        end
    end

endmodule

