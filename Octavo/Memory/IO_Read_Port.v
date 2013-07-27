
module IO_Read_Port 
#(
    parameter       WORD_WIDTH                                  = 0,
    parameter       ADDR_WIDTH                                  = 0, 
    parameter       IO_READ_PORT_BASE_ADDR                      = 0, 
    parameter       IO_READ_PORT_COUNT                          = 0, 
    parameter       IO_READ_PORT_ADDR_WIDTH                     = 0 
)
(
    input   wire                                                clock,
    input   wire    [ADDR_WIDTH-1:0]                            read_addr,         
    input   wire    [WORD_WIDTH-1:0]                            read_data_ram_in,
    input   wire    [(WORD_WIDTH * IO_READ_PORT_COUNT)-1:0]     read_data_io_in,
    output  wire    [IO_READ_PORT_COUNT-1:0]                    read_data_io_req_out,
    output  wire    [WORD_WIDTH-1:0]                            read_data_out  
);

    wire    [IO_READ_PORT_ADDR_WIDTH-1:0]   port_addr;
    wire    [WORD_WIDTH-1:0]                read_data_io_out;

    IO_Port_Read_Select
    #(
        .WORD_WIDTH                 (WORD_WIDTH), 
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_READ_PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR), 
        .IO_READ_PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH),
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT)
    )
    IOPRS
    (
        .clock                      (clock),
        .read_addr_in               (read_addr),    
        .read_data_in               (read_data_io_in),
        .port_addr_out              (port_addr),   
        .read_data_out              (read_data_io_out)
    );

    reg     [ADDR_WIDTH-1:0]        read_addr_data_select;

    // Match latency of port select and RAM
    always @(posedge clock) begin
        read_addr_data_select <= read_addr;
    end

    wire    addr_in_io_range;

    IO_Read_Data_Select 
    #(
        .WORD_WIDTH                 (WORD_WIDTH), 
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT),
        .IO_READ_PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR) 
    )
    IORDS
    (
        .clock (clock),
        .read_addr_ram              (read_addr_data_select),
        .read_data_ram              (read_data_ram_in),
        .read_data_io               (read_data_io_out),
        .addr_in_io_range           (addr_in_io_range),
        .read_data                  (read_data_out)
    );

    IO_Read_Port_Req
    #(
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT), 
        .IO_READ_PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH)
    )
    IORPR
    (
        .clock                      (clock),
        .addr_in_io_range           (addr_in_io_range),
        .port_addr                  (port_addr),
        .req                        (read_data_io_req_out)
    );
endmodule


