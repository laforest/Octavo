
// ECL Quartus synthesis will not mess with LPMs. Otherwise the CS adder gets mangled by the optimizations.
module AddSub_element_lpm 
#(
    parameter   WORD_WIDTH              = 0
)
(
    input   wire                        add_sub,
	input   wire                        cin,
	input   wire    [WORD_WIDTH-1:0]    dataa,
	input   wire    [WORD_WIDTH-1:0]    datab,
	output  wire                        cout,
	output  wire    [WORD_WIDTH-1:0]    result
);
	lpm_add_sub	
    #(
		.lpm_direction      ("UNUSED"),
		.lpm_hint           ("ONE_INPUT_IS_CONSTANT=NO,CIN_USED=YES"),
		.lpm_representation ("SIGNED"),
		.lpm_type           ("LPM_ADD_SUB"),
		.lpm_width          (WORD_WIDTH)
    )
    lmp_add_sub 
    (
        .add_sub            (add_sub),
        .cin                (cin),
        .datab              (datab),
        .dataa              (dataa),
        .cout               (cout),
        .result             (result),
        .aclr               (),
        .clken              (),
        .clock              (),
        .overflow           ()
	);
endmodule


module AddSub_Carry_Select 
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

// *************************************

    wire                            cout_lower;
    wire    [(WORD_WIDTH/2)-1:0]    result_lower;

    AddSub_element_lpm 
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

// *************************************

    wire                            cout_upper_0;
    wire    [(WORD_WIDTH/2)-1:0]    result_upper_0;

    AddSub_element_lpm 
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

// *************************************

    wire                            cout_upper_1;
    wire    [(WORD_WIDTH/2)-1:0]    result_upper_1;

    AddSub_element_lpm 
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

// *************************************

    always @(posedge clock) begin
        cout   <= (cout_lower_reg == `HIGH) ? cout_upper_1_reg                       : cout_upper_0_reg;
        result <= (cout_lower_reg == `HIGH) ? {result_upper_1_reg, result_lower_reg} : {result_upper_0_reg, result_lower_reg};
    end
endmodule

