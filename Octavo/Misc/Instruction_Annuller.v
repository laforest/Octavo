
// Annulls an instruction
// Really just an AND gate for now, but other implementations might work better.
// Depends on the meaning of all-zero: XOR, 0, 0, 0
// The Controller depends on that too: no jump instructions reach it when annulled.

module Instruction_Annuller
#(
    parameter       INSTR_WIDTH         = 0
)
(
    input   wire    [INSTR_WIDTH-1:0]   instr_in,
    input   wire                        annul,
    output  reg     [INSTR_WIDTH-1:0]   instr_out
);
    // ECL Annuling the instruction using logic instead of synchronous clear
    // since it would require changing the delay_line, and might not be as
    // portable.

    // See http://www.altera.com/literature/hb/qts/qts_qii51007.pdf (page 14-49):

    // Creating many registers with different sload and sclr signals can make
    // packing the registers into LABs difficult for the Quartus II Fitter
    // because the sclr and sload signals are LAB-wide signals. In addition,
    // using the LAB-wide sload signal prevents the Fitter from packing
    // registers using the quick feedback path in the device architecture,
    // which means that some registers cannot be packed with other logic.

    // Synthesis tools typically restrict use of sload and sclr signals to
    // cases in which there are enough registers with common signals to allow
    // good LAB packing. Using the look-up table (LUT) to implement the signals
    // is always more flexible if it is available.  Because different device
    // families offer different numbers of control signals, inference of these
    // signals is also device-specific. For example, because Stratix II devices
    // have more flexibility than Stratix devices with respect to secondary
    // control signals, synthesis tools might infer more sload and sclr signals
    // for Stratix II devices.

    always @(*) begin
        instr_out <= instr_in & {INSTR_WIDTH{~annul}};
    end
endmodule

