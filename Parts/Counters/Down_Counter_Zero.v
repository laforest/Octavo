
// Counts downward to zero, with zero signal,
// and optional automatic reload.

// Counts down one step if run is set.

// If reload is set when the counter reaches zero,
// it reloads and resumes its countdown.

// By default, reloads to the INITIAL_COUNT value.
// Else, to the last load value written.

// Loading a value overrules a coincident reload.

module Down_Counter_Zero
#(
    parameter WORD_WIDTH                = 0,
    parameter INITIAL_COUNT             = 0
)
(
    input   wire                        clock,
    input   wire                        run,
    input   wire                        reload,
    input   wire                        load_wren,
    input   wire    [WORD_WIDTH-1:0]    load_value,
    output  wire                        zero
     
);

// --------------------------------------------------------------------

    localparam ALL_ZERO = {WORD_WIDTH{1'b0}};
    localparam ALL_ONE  = {WORD_WIDTH{1'b1}};

// --------------------------------------------------------------------

    reg [WORD_WIDTH-1:0] reload_value;
    reg                  load_wren_counter;
    reg [WORD_WIDTH-1:0] load_value_counter;

    initial begin
        reload_value = INITIAL_COUNT [WORD_WIDTH-1:0];
    end

    always @(*) begin
        load_wren_counter   = load_wren | (reload & zero);
        load_value_counter  = (load_wren == 1'b1) ? load_value : reload_value;
    end

    always @(posedge clock) begin
        reload_value <= load_value_counter;
    end

// --------------------------------------------------------------------

    reg {WORD_WIDTH-1:0] count;

    UpDown_Counter
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .INITIAL_COUNT  (INITIAL_COUNT)
    )
    (
        .clock          (clock),
        .up_down        (1'b0),     // down
        .run            (run),
        .wren           (load_wren_counter),
        .write_data     (load_value_counter),
        .count          (count),
        .next_count     ()          // N/C
    );

// --------------------------------------------------------------------

    Sentinel_Value_Check
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    is_zero
    (
        .in         (count),
        .sentinel   (ALL_ZERO), 
        .mask       (ALL_ONE),
        .match      (zero)
    );

endmodule

