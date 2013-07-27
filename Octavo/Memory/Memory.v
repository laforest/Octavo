
module Memory 
#(
    parameter       WORD_WIDTH                                  = 0,
    parameter       ADDR_WIDTH                                  = 0,
    parameter       DEPTH                                       = 0,
    parameter       RAMSTYLE                                    = "",
    parameter       INIT_FILE                                   = "",
    parameter       IO_READ_PORT_COUNT                          = 0,
    parameter       IO_READ_PORT_BASE_ADDR                      = 0,
    parameter       IO_READ_PORT_ADDR_WIDTH                     = 0,
    parameter       IO_WRITE_PORT_COUNT                         = 0,
    parameter       IO_WRITE_PORT_BASE_ADDR                     = 0,
    parameter       IO_WRITE_PORT_ADDR_WIDTH                    = 0
)
(
    input   wire                                                clock,
    input   wire                                                wren,
    input   wire    [ADDR_WIDTH-1:0]                            write_addr,
    input   wire    [WORD_WIDTH-1:0]                            write_data,
    input   wire    [ADDR_WIDTH-1:0]                            read_addr,
    output  wire    [WORD_WIDTH-1:0]                            read_data,
    output  wire    [IO_READ_PORT_COUNT-1:0]                    io_req,
    input   wire    [(WORD_WIDTH * IO_READ_PORT_COUNT)-1:0]     io_in,
    output  wire    [IO_WRITE_PORT_COUNT-1:0]                   io_wren,
    output  wire    [(WORD_WIDTH * IO_WRITE_PORT_COUNT)-1:0]    io_out
);

    wire                        wren_ram;
    wire    [ADDR_WIDTH-1:0]    write_addr_ram;
    wire    [WORD_WIDTH-1:0]    write_data_ram;

    IO_Write_Port 
    #(
        .WORD_WIDTH                 (WORD_WIDTH),
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_WRITE_PORT_COUNT        (IO_WRITE_PORT_COUNT),
        .IO_WRITE_PORT_BASE_ADDR    (IO_WRITE_PORT_BASE_ADDR),
        .IO_WRITE_PORT_ADDR_WIDTH   (IO_WRITE_PORT_ADDR_WIDTH)
    )
    IOWP 
    (
        .clock                      (clock),
        .wren_in                    (wren),
        .write_addr_in              (write_addr),
        .write_data_in              (write_data),

        // Pass-through
        .wren_out_ram               (wren_ram),
        .write_addr_out_ram         (write_addr_ram),
        .write_data_out_ram         (write_data_ram),

        .wren_out_io                (io_wren),
        .write_data_out_io          (io_out)    
    );

    wire    [WORD_WIDTH-1:0]    read_data_ram;

    RAM_SDP
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    RAM
    (
        .clock              (clock),
        .wren               (wren_ram),
        .write_addr         (write_addr_ram),
        .write_data         (write_data_ram),
        .read_addr          (read_addr),
        .read_data          (read_data_ram)
    );

    IO_Read_Port 
    #(
        .WORD_WIDTH                 (WORD_WIDTH),
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_READ_PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR),
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT),
        .IO_READ_PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH)
    )
    IORP
    (
        .clock                      (clock),
        .read_addr                  (read_addr),
        .read_data_ram_in           (read_data_ram),
        .read_data_io_in            (io_in),
        .read_data_io_req_out       (io_req),
        .read_data_out              (read_data)
    );
endmodule

