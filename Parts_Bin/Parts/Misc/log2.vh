
// Ceiling of logarithm, base 2
// Taken from Verilog-2001 standard example
// Since $clog2() doesn't exist prior to Verilog-2005 (and thus, SystemVerilog)

function integer clog2;
    input integer value;
    begin
        value = value - 1;
        for (clog2 = 0; value > 0; clog2 = clog2 + 1) begin
            value = value >> 1;
        end
    end
endfunction

