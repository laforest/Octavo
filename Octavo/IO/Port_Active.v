
// Generates an "active" signal for each port.
// Takes an external enable to allow for expansion of control.

module Port_Active
#(
    parameter       PORT_COUNT              = 0, 
    parameter       PORT_ADDR_WIDTH         = 0,
    parameter       REGISTERED              = `FALSE 
)
(
    input   wire                            clock,
    input   wire                            enable,
    input   wire    [PORT_ADDR_WIDTH-1:0]   port_addr,
    output  reg     [PORT_COUNT-1:0]        active
);
    integer                     port;
    reg     [PORT_COUNT-1:0]    active_internal;

    always @(*) begin
        for(port = 0; port < PORT_COUNT; port = port + 1) begin
            active_internal[port +: 1] <= enable && (port_addr == port);
        end 
    end

    generate
        if (REGISTERED == `TRUE) begin
            always @(posedge clock) begin
                active <= active_internal;
            end

            initial begin
                active = 0;
            end
        end
        else begin
            always @(*) begin
                active <= active_internal;
            end
        end
    endgenerate
endmodule

