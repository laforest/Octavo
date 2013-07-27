
module IO_Read_Data_Select 
#(
    parameter       WORD_WIDTH              = 0,
    parameter       ADDR_WIDTH              = 0,
    parameter       IO_READ_PORT_COUNT      = 0,
    parameter       IO_READ_PORT_BASE_ADDR  = 0
)
(
    input   wire                            clock,
    input   wire    [ADDR_WIDTH-1:0]        read_addr_ram,
    input   wire    [WORD_WIDTH-1:0]        read_data_ram,
    input   wire    [WORD_WIDTH-1:0]        read_data_io,
    output  wire                            addr_in_io_range,
    output  reg     [WORD_WIDTH-1:0]        read_data
);
    Address_Decoder
    #(
        .ADDR_COUNT     (IO_READ_PORT_COUNT),
        .ADDR_BASE      (IO_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH     (ADDR_WIDTH)
    )
    IO_Read
    (
        .addr           (read_addr_ram),
        .match          (addr_in_io_range)
    );

    always @(posedge clock) begin
        if(addr_in_io_range === `HIGH) begin
            read_data <= read_data_io;
        end
        else begin
            read_data <= read_data_ram;
        end
    end

    initial begin
        read_data = 0;
    end
endmodule

