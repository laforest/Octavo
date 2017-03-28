
// Branch Priority Arbiter: selects which branch in a multiway branch gets
// taken, along with its instruction cancellation, if any.

module Branch_Priority_Arbiter
#(
    parameter   PC_WIDTH                        = 0,
    parameter   BRANCH_COUNT                    = 0
)
(
    input  wire                                 clock,

    input  wire [BRANCH_COUNT-1:0]              cancels,
    input  wire [BRANCH_COUNT-1:0]              jumps,
    input  wire [(PC_WIDTH*BRANCH_COUNT)-1:0]   jump_destinations,

    output wire                                 cancel,  
    output reg                                  jump,  
    output wire [PC_WIDTH-1:0]                  jump_destination,  
);

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 0

// ---------------------------------------------------------------------
// Limit cases: no jumps set, any jumps set, and any cancels set

    reg jumps_none  = 0;
    reg jumps_any   = 0;
    reg cancels_any = 0;

    always @(*) begin
        jumps_none  <= !|jumps;
        jumps_any   <=  |jumps;
        cancels_any <=  |cancels;
    end

// ---------------------------------------------------------------------
// Append some limit cases to the inputs, at lowest priority (MSB),
// so we can select any cancel and no destination if no branches are taken

    localparam BRANCH_COUNT_ALL = BRANCH_COUNT + 1;

    reg [BRANCH_COUNT_ALL-1:0] jumps_all    = 0;
    reg [BRANCH_COUNT_ALL-1:0] cancels_all  = 0;

    always @(*) begin
        jumps_all   <= {jumps_none,jumps};
        cancels_all <= {cancels_any,cancels};
    end

// ---------------------------------------------------------------------
// Grant jumps by priority, including granting that no jumps are set

    wire [BRANCH_COUNT_ALL-1:0] jumps_granted;

    Priority_Arbiter
    #(
        .WORD_WIDTH     (BRANCH_COUNT_ALL)
    )
    PO_WREN_SELECT
    (
        .requests       (jumps_all),
        .grant          (jumps_granted)
    );

// ---------------------------------------------------------------------
// Register everything at end of Stage 0

    reg [BRANCH_COUNT_ALL-1:0]          jumps_granted_stage1        = 0;
    reg                                 cancels_all_stage1          = 0;
    reg [(PC_WIDTH*BRANCH_COUNT)-1:0]   jump_destinations_stage1    = 0;

    always @(posedge clock) begin
        cancels_all_stage1          <= cancels_all;
        jump                        <= jumps_any;
        jumps_granted_stage1        <= jumps_granted;
        jump_destinations_stage1    <= jump_destinations;
    end

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 1
// Note outputs computed here are not registered
// They will be registered at the Controller inputs

// ---------------------------------------------------------------------
// Select the cancel bit associated with the active jump
// else pass the cancel_any bit through
// (a jump may cancel a concurrent instruction when not taken)

    One_Hot_Mux
    #(
        .WORD_WIDTH     (1),
        .WORD_COUNT     (BRANCH_COUNT_ALL) 
    )
    CANCEL_SELECTOR
    (
        .selectors      (jumps_granted_stage1),
        .in             (cancels_all_stage1),
        .out            (cancel)
    );

// ---------------------------------------------------------------------
// Drop the MSB of the selector: if no jump set, then no jump_destination
// is selected, and so outputs zero.
// This is an optmization to shrink the One_Hot_Mux by one PC_WIDTH input, 
// since if no jump happens the value of the destination is never used.

    One_Hot_Mux
    #(
        .WORD_WIDTH     (PC_WIDTH),
        .WORD_COUNT     (BRANCH_COUNT) 
    )
    DESTINATION_SELECTOR
    (
        .selectors      (jumps_granted_stage1[BRANCH_COUNT-1:0]),
        .in             (jump_destinations_stage1),
        .out            (jump_destination)
    );

endmodule

