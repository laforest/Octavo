
module IO_Write_Port 
#(
    parameter       WORD_WIDTH                                  = 0,
    parameter       ADDR_WIDTH                                  = 0,
    parameter       IO_WRITE_PORT_COUNT                         = 0,
    parameter       IO_WRITE_PORT_ADDR_WIDTH                    = 0,
    parameter       IO_WRITE_PORT_BASE_ADDR                     = 0
)
(
    input   wire                                                clock,
    input   wire                                                wren_in,
    input   wire    [ADDR_WIDTH-1:0]                            write_addr_in,
    input   wire    [WORD_WIDTH-1:0]                            write_data_in,
    output  reg                                                 wren_out_ram,
    output  reg     [ADDR_WIDTH-1:0]                            write_addr_out_ram,
    output  reg     [WORD_WIDTH-1:0]                            write_data_out_ram,
    output  reg     [IO_WRITE_PORT_COUNT-1:0]                   wren_out_io,
    output  reg     [(WORD_WIDTH * IO_WRITE_PORT_COUNT)-1:0]    write_data_out_io    
);

    // Pass-through to RAM
    always @(posedge clock) begin
        wren_out_ram          <= wren_in;
        write_addr_out_ram    <= write_addr_in;
        write_data_out_ram    <= write_data_in;
    end

    wire    addr_in_io_range;

    Address_Decoder
    #(
        .ADDR_COUNT     (IO_WRITE_PORT_COUNT),
        .ADDR_BASE      (IO_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH     (ADDR_WIDTH)
    )
    IOWAD
    (
        .addr           (write_addr_in),
        .match          (addr_in_io_range)
    );

    integer                                 port = 0;
    reg     [IO_WRITE_PORT_ADDR_WIDTH-1:0]  port_select;
    wire    [IO_WRITE_PORT_ADDR_WIDTH-1:0]  port_select_translated;

    always @(*) begin
        port_select     <= write_addr_in[IO_WRITE_PORT_ADDR_WIDTH-1:0];
    end

    Address_Translator
    #(
        .ADDR_COUNT         (IO_WRITE_PORT_COUNT),
        .ADDR_BASE          (IO_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH         (IO_WRITE_PORT_ADDR_WIDTH)
    )
    IOWAT
    (
        .raw_address        (port_select),
        .translated_address (port_select_translated)    
    );


    // Write Enables, one per port
    always @(posedge clock) begin
        for(port = 0; port < IO_WRITE_PORT_COUNT; port = port + 1) begin
            if(addr_in_io_range === `HIGH      && 
               port_select_translated === port && 
               wren_in === `HIGH)
            begin
                wren_out_io[port +: 1] <= `HIGH;
            end
            else begin
                wren_out_io[port +: 1] <= `LOW;
            end
        end 
    end
    
    // Write Data, fan-out to all ports
    always @(posedge clock) begin
        for(port = 0; port < IO_WRITE_PORT_COUNT; port = port + 1) begin
            write_data_out_io[(port * WORD_WIDTH) +: WORD_WIDTH] <= write_data_in;
        end
    end

    initial begin
        wren_out_ram        = 0;
        write_addr_out_ram  = 0;
        write_data_out_ram  = 0;
        wren_out_io         = 0;
        write_data_out_io   = 0;
    end
endmodule

