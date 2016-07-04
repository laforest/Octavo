
// Generates a 2-stage pipelines Ripple-Carry Adder-Subtractor for any *even*
// word-width. For most cases, 2 pipeline stages suffice to reach
// a high-enough Fmax to not be a bottleneck.

// The CAD tool should re-time registers as needed to map to the actual
// carry-chain logic on the device.

module AddSub_Ripple_Carry_2stages
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

// --------------------------------------------------------------------

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

    wire                            cout_lower;
    wire    [(WORD_WIDTH/2)-1:0]    result_lower;

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
    reg                             add_sub_upper;
    reg     [(WORD_WIDTH/2)-1:0]    dataa_upper;
    reg     [(WORD_WIDTH/2)-1:0]    datab_upper;

    always @(posedge clock) begin
        cout_lower_reg   <= cout_lower;
        result_lower_reg <= result_lower;
        add_sub_upper    <= add_sub;
        dataa_upper      <= upper_half_word(dataa);
        datab_upper      <= upper_half_word(datab);
    end

    initial begin
        cout_lower_reg   = 0;
        result_lower_reg = 0;
        add_sub_upper    = 0;
        dataa_upper      = 0;
        datab_upper      = 0;
    end

// --------------------------------------------------------------------


    wire                            cout_upper;
    wire    [(WORD_WIDTH/2)-1:0]    result_upper;

    AddSub_Ripple_Carry 
    #(
        .WORD_WIDTH     (WORD_WIDTH/2)
    )
    addsub_upper
    (
        .add_sub        (add_sub_upper),
        .cin            (cout_lower_reg),
        .dataa          (dataa_upper),
        .datab          (datab_upper),
        .cout           (cout_upper),
        .result         (result_upper)
    );

    reg                           cout_upper_reg;
    reg     [(WORD_WIDTH/2)-1:0]  result_upper_reg;
    reg     [(WORD_WIDTH/2)-1:0]  result_lower_reg_1;    

    always @(posedge clock) begin
        cout_upper_reg     <= cout_upper;
        result_upper_reg   <= result_upper;
        result_lower_reg_1 <= result_lower_reg;
    end

    initial begin
        cout_upper_reg     = 0;
        result_upper_reg   = 0;
        result_lower_reg_1 = 0;
    end

// --------------------------------------------------------------------

    always @(*) begin
        cout   <= cout_upper_reg;
        result <= {result_upper_reg, result_lower_reg_1};
    end
endmodule

