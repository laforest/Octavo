
// Branch Arbiter: selects which outcome of a multiway branch gets taken, in
// priority order, and in turn select its cancellation bit and destination
// address.

// Note the outputs computed here are not registered in Stage 1 They will be
// registered at the Controller inputs

// Unfortunately, I'm mixing "branch" and "jump" terminology here. Sorry.

module Branch_Arbiter
#(
    parameter   PC_WIDTH                        = 0,
    parameter   BRANCH_COUNT                    = 0
)
(
    input  wire                                 clock,

    // From all the Branch Modules
    input  wire [BRANCH_COUNT-1:0]              cancels,
    input  wire [BRANCH_COUNT-1:0]              jumps,
    input  wire [(PC_WIDTH*BRANCH_COUNT)-1:0]   jump_destinations,

    // The selected branch signals
    output wire                                 cancel,  
    output reg                                  jump,  
    output wire [PC_WIDTH-1:0]                  jump_destination,  
);

// ---------------------------------------------------------------------
// Internally, we also consider cases where any or none of the options
// are selected, so we treat them as just another possible branch outcome.

    localparam BRANCH_COUNT_ALL = BRANCH_COUNT + 1;

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 0

// ---------------------------------------------------------------------
// Limit cases: no jumps set, any jumps set,
// If no jumps are active, signal that case by selecting a "no jumps"
// signal at the lowest priority position.

    reg                         jumps_none  = 0;
    reg                         jumps_any   = 0;
    reg [BRANCH_COUNT_ALL-1:0]  jumps_all    = 0;

    always @(*) begin
        jumps_any   = |jumps;
        jumps_none  = ~jumps_any;
        jumps_all   = {jumps_none,jumps};
    end

// ---------------------------------------------------------------------
// Grant jumps by priority, including granting that no jumps are set

    wire [BRANCH_COUNT_ALL-1:0] jumps_granted;

    Priority_Arbiter
    #(
        .WORD_WIDTH     (BRANCH_COUNT_ALL)
    )
    PA_BA
    (
        .requests       (jumps_all),
        .grant          (jumps_granted)
    );

// ---------------------------------------------------------------------
// Register everything at end of Stage 0
// Jump on any jump set, and use the arbitrated jump to select
// a cancel bit and branch destination in Stage 1.

    reg [BRANCH_COUNT_ALL-1:0] jumps_granted_stage1 = 0;

    always @(posedge clock) begin
        jump                    <= jumps_any;
        jumps_granted_stage1    <= jumps_granted;
    end

// ---------------------------------------------------------------------
// Limit case: any jump many cancel an instruction if no jump selected.
// Append that case at lowest priority.
// Register at the end of Stage 0

    reg                         cancels_any         = 0;
    reg [BRANCH_COUNT_ALL-1:0]  cancels_all_stage1  = 0;

    always @(posedge clock) begin
        cancels_any = |cancels;
        cancels_all = {cancels_any,cancels};
    end

// ---------------------------------------------------------------------
// Register Jump Destinations at end of Stage 0.
// Nothing to do yet.

    reg [(PC_WIDTH*BRANCH_COUNT)-1:0] jump_destinations_stage1 = 0;

    always @(*) begin
        jump_destinations_stage1 <= jump_destinations;
    end

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// Stage 1 (not registered)

// Select the cancel bit associated with the active jump else any jump may
// cancel a concurrent instruction when no jump taken.

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

// Select the Jump Destination of the selected branch, or select zero if no
// jump taken by dropping the MSB of the one-hot selector: if no jump granted,
// then no jump_destinations bit is selected, and so outputs zero.  This is an
// optmization to shrink the One_Hot_Mux by one PC_WIDTH input, since if no
// jump happens the value of the jump destination is never used.

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

