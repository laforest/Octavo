
// A Carry-Select adder/subtractor can reach a higher speed in fewer stages
// than a Ripple-Carry equivalent. However, by default Quartus mangles the
// design back into a (bad) Ripple-Carry circuit. The "keep" directives are an
// attempt to portably preserve the three individual sub-adders.

// Two pipeline stages suffice to reach a very, very high speed.
// This is only useful in designs where you want to exceed the speed of
// a Block RAM, and you don't want to create a 4-stage Rippler-Carry adder.

// WORD_WIDTH must be an *even* number.

`default_nettype none

module AddSub_Carry_Select_2stages
#(
    parameter               WORD_WIDTH          = 0
)
(
    input   wire                                clock,
	input   wire                                add_sub,
	input   wire                                cin,
	input   wire    signed  [WORD_WIDTH-1:0]    dataa,
	input   wire    signed  [WORD_WIDTH-1:0]    datab,
	output  reg                                 cout,
	output  reg     signed  [WORD_WIDTH-1:0]    result
);

    function [(WORD_WIDTH/2)-1:0] lower_half_word
    (
        input reg [WORD_WIDTH-1:0] word     
    ); 
        lower_half_word = word[(WORD_WIDTH/2)-1:0];
    endfunction


    function [(WORD_WIDTH/2)-1:0] upper_half_word
    (
        input reg [WORD_WIDTH-1:0] word     
    ); 
        upper_half_word = word[WORD_WIDTH-1:(WORD_WIDTH/2)];
    endfunction

// --------------------------------------------------------------------

    wire                            cout_lower;     /* synthesis keep */
    wire    [(WORD_WIDTH/2)-1:0]    result_lower;   /* synthesis keep */

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (WORD_WIDTH/2)
    )
    alu_lower
    (
        .add_sub        (add_sub),
        .cin            (cin),
        .dataa          (lower_half_word(dataa)),
        .datab          (lower_half_word(datab)),
        .cout           (cout_lower),
        .result         (result_lower)
    );

    reg                             cout_lower_reg;
    reg     [(WORD_WIDTH/2)-1:0]    result_lower_reg;

    always @(posedge clock) begin
        cout_lower_reg      <=  cout_lower;
        result_lower_reg    <=  result_lower;
    end

// --------------------------------------------------------------------

    wire                            cout_upper_0;   /* synthesis keep */
    wire    [(WORD_WIDTH/2)-1:0]    result_upper_0; /* synthesis keep */

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (WORD_WIDTH/2)
    )
    alu_upper_0
    (
        .add_sub        (add_sub),
        .cin            (`LOW),
        .dataa          (upper_half_word(dataa)),
        .datab          (upper_half_word(datab)),
        .cout           (cout_upper_0),
        .result         (result_upper_0)
    );

    reg                             cout_upper_0_reg;
    reg     [(WORD_WIDTH/2)-1:0]    result_upper_0_reg;

    always @(posedge clock) begin
        cout_upper_0_reg      <=  cout_upper_0;
        result_upper_0_reg    <=  result_upper_0;
    end

// --------------------------------------------------------------------

    wire                            cout_upper_1;   /* synthesis keep */
    wire    [(WORD_WIDTH/2)-1:0]    result_upper_1; /* synthesis keep */

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (WORD_WIDTH/2)
    )
    alu_upper_1
    (
        .add_sub        (add_sub),
        .cin            (`HIGH),
        .dataa          (upper_half_word(dataa)),
        .datab          (upper_half_word(datab)),
        .cout           (cout_upper_1),
        .result         (result_upper_1)
    );

    reg                             cout_upper_1_reg;
    reg     [(WORD_WIDTH/2)-1:0]    result_upper_1_reg;

    always @(posedge clock) begin
        cout_upper_1_reg      <=  cout_upper_1;
        result_upper_1_reg    <=  result_upper_1;
    end

// --------------------------------------------------------------------

    always @(posedge clock) begin
        cout   <= (cout_lower_reg == 1'b1) ? cout_upper_1_reg                       : cout_upper_0_reg;
        result <= (cout_lower_reg == 1'b1) ? {result_upper_1_reg, result_lower_reg} : {result_upper_0_reg, result_lower_reg};
    end
endmodule

