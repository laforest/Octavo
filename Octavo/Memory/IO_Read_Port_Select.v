
module IO_Read_Port_Select
#(
    parameter       WORD_WIDTH                              = 0,
    parameter       ADDR_WIDTH                              = 0,
    parameter       IO_READ_PORT_BASE_ADDR                  = 0,
    parameter       IO_READ_PORT_ADDR_WIDTH                 = 0,
    parameter       IO_READ_PORT_COUNT                      = 0
)
(
    input   wire                                            clock,
    input   wire    [ADDR_WIDTH-1:0]                        read_addr_in,    
    input   wire    [(WORD_WIDTH * IO_READ_PORT_COUNT)-1:0] read_data_in,
    output  reg     [IO_READ_PORT_ADDR_WIDTH-1:0]           port_addr_out,   
    output  reg     [WORD_WIDTH-1:0]                        read_data_out
);
    // Read Mux: selects I/O read port using LSB of address
    // Use MSB of address in later module to select RAM vs. I/O Port data
    reg     [IO_READ_PORT_ADDR_WIDTH-1:0]   port_addr;
    wire    [IO_READ_PORT_ADDR_WIDTH-1:0]   port_addr_translated;

    always @(*) begin
        port_addr <= read_addr_in[IO_READ_PORT_ADDR_WIDTH-1:0];
    end

    Address_Translator
    #(
        .ADDR_COUNT         (IO_READ_PORT_COUNT),
        .ADDR_BASE          (IO_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH         (IO_READ_PORT_ADDR_WIDTH)
    )
    IO_Read_Port
    (
        .raw_address        (port_addr),
        .translated_address (port_addr_translated)    
    );

    always @(*) begin
        port_addr_out <= port_addr_translated;
    end

    // Register data output to match RAM latency
    always @(posedge clock) begin
        read_data_out   <= read_data_in[(port_addr_translated * WORD_WIDTH) +: WORD_WIDTH];
    end

    initial begin
        read_data_out = 0;
    end
endmodule

