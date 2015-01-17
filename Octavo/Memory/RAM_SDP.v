
// Preferably for M9K and similar: NEW data
// read-during-write behaviour grants highest BRAM
// operating speed and provides write forwarding

// Also, we don't want a synchronous clear on the
// output: any register driving it cannot be retimed.

module RAM_SDP 
#(
    parameter       WORD_WIDTH          = 0,
    parameter       ADDR_WIDTH          = 0,
    parameter       DEPTH               = 0,
    parameter       RAMSTYLE            = "",
    parameter       INIT_FILE           = ""
)
(
    input  wire                         clock,
    input  wire                         wren,
    input  wire     [ADDR_WIDTH-1:0]    write_addr,
    input  wire     [WORD_WIDTH-1:0]    write_data,
    input  wire     [ADDR_WIDTH-1:0]    read_addr, 
    output reg      [WORD_WIDTH-1:0]    read_data
);
    // Exmaple: "M9K"
    (* ramstyle = RAMSTYLE *) 
    reg [WORD_WIDTH-1:0] ram [DEPTH-1:0];

    initial begin
        $readmemh(INIT_FILE, ram);
    end

    always @(posedge clock) begin
        if(wren == `HIGH) begin
            ram[write_addr] = write_data;
        end
        read_data = ram[read_addr];
    end

    initial begin
        read_data = 0;
    end
endmodule

