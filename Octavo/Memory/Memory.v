
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
    output  wire                                                write_is_io_out,
    input   wire                                                write_is_io_in,
    input   wire    [ADDR_WIDTH-1:0]                            write_addr,
    input   wire    [WORD_WIDTH-1:0]                            write_data,

    input   wire    [ADDR_WIDTH-1:0]                            read_addr_raw,
    input   wire    [ADDR_WIDTH-1:0]                            read_addr_translated,
    output  wire    [WORD_WIDTH-1:0]                            read_data,

    input   wire                                                IO_ready,

    input   wire    [IO_READ_PORT_COUNT-1:0]                    read_EF_in,
    output  wire                                                read_EF_out,
    output  wire    [IO_READ_PORT_COUNT-1:0]                    io_rden,
    input   wire    [(WORD_WIDTH * IO_READ_PORT_COUNT)-1:0]     io_in,

    input   wire    [IO_WRITE_PORT_COUNT-1:0]                   write_EF_in,
    output  wire                                                write_EF_out,
    output  wire    [IO_WRITE_PORT_COUNT-1:0]                   io_wren,
    output  wire    [(WORD_WIDTH * IO_WRITE_PORT_COUNT)-1:0]    io_out
);
    wire    [WORD_WIDTH-1:0]        read_data_ram;

    IO_Read 
    #(
        .WORD_WIDTH                 (WORD_WIDTH),
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_READ_PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR),
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT),
        .IO_READ_PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH)
    )
    IO_Read
    (
        .clock                      (clock),
        .read_addr_raw              (read_addr_raw),
        .read_addr_translated       (read_addr_translated),
        .EmptyFull                  (read_EF_in),
        .data_IO                    (io_in),
        .data_RAM                   (read_data_ram),
        .IO_ready                   (IO_ready),
        .EmptyFull_masked           (read_EF_out),
        .active_IO                  (io_rden),
        .data_out                   (read_data)
    );

    wire    [WORD_WIDTH-1:0]        write_data_ram;
    wire    [ADDR_WIDTH-1:0]        write_addr_ram;
    wire                            wren_ram;

    IO_Write 
    #(
        .WORD_WIDTH                 (WORD_WIDTH),
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_WRITE_PORT_COUNT        (IO_WRITE_PORT_COUNT),
        .IO_WRITE_PORT_BASE_ADDR    (IO_WRITE_PORT_BASE_ADDR),
        .IO_WRITE_PORT_ADDR_WIDTH   (IO_WRITE_PORT_ADDR_WIDTH)
    )
    IO_Write
    (
        .clock                      (clock),
        .addr_raw                   (read_addr_raw),
        .EmptyFull                  (write_EF_in),
        .IO_ready                   (IO_ready),
        .ALU_result                 (write_data),
        .ALU_addr                   (write_data),
        .ALU_write_is_IO            (write_is_io_in),
        .ALU_wren                   (wren),
        .write_is_io                (write_is_io_out),
        .EmptyFull_masked           (write_EF_out),
        .active_IO                  (io_wren),
        .data_IO                    (io_out),
        .data_RAM                   (write_data_ram),
        .addr_RAM                   (write_addr_ram),
        .wren_RAM                   (wren_ram)
    );

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
        .read_addr          (read_addr_translated),
        .read_data          (read_data_ram)
    );
endmodule

