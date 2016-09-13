
// On-Chip Memory/Register File. Provides read and write I/O ports.
// Only the addressed write I/O port changes values on write.

// Special behaviour on address zero: returns zero on reads, read and write
// enables are disabled to save power and enforce behaviour.

// Same for when addressing an I/O port: RAM is disabled to save power.
// Never map IO ports to address zero.

// If you do not want write-forwarding, but keep the high speed, at the price
// of indeterminate behaviour on overlapping read/writes, use "no_rw_check" as
// part of the RAMSTYLE (e.g.: "M10K, no_rw_check").


module Memory
#(
    parameter   WORD_WIDTH                                  = 0,
    parameter   ADDR_WIDTH                                  = 0,
    parameter   MEM_DEPTH                                   = 0,
    parameter   MEM_RAMSTYLE                                = "",
    parameter   MEM_INIT_FILE                               = "",
    parameter   IO_READ_PORT_COUNT                          = 0,
    parameter   IO_READ_PORT_BASE_ADDR                      = 0,
    parameter   IO_READ_PORT_ADDR_WIDTH                     = 0,
    parameter   IO_WRITE_PORT_COUNT                         = 0,
    parameter   IO_WRITE_PORT_BASE_ADDR                     = 0,
    parameter   IO_WRITE_PORT_ADDR_WIDTH                    = 0
)
(
    input   wire                                            clock,
    input   wire                                            IO_ready,

    input   wire    [ADDR_WIDTH-1:0]                        read_addr,
    input   wire                                            read_addr_is_IO,
    output  wire    [WORD_WIDTH-1:0]                        read_data,
    // IO_Read_Predication module generates io_rden output
    input   wire    [(WORD_WIDTH*IO_READ_PORT_COUNT)-1:0]   io_read_data,

    input   wire    [ADDR_WIDTH-1:0]                        write_addr,
    input   wire                                            write_addr_is_IO,
    input   wire    [WORD_WIDTH-1:0]                        write_data,
    output  reg                                             io_wren,
    output  wire    [(WORD_WIDTH*IO_WRITE_PORT_COUNT)-1:0]  io_write_data
);

// -----------------------------------------------------------

    localparam ZERO = {WORD_WIDTH{1'b0}};

// -----------------------------------------------------------

    initial begin
        io_wren     = 0;
    end

// -----------------------------------------------------------
// -----------------------------------------------------------
// RAM read  happens in Read  Stage 1
// RAM write happens in Write Stage 2

    wire    [WORD_WIDTH-1:0]    mem_read_data;
    reg                         mem_rden            = 0;
    reg                         mem_wren_stage2     = 0;
    reg     [WORD_WIDTH-1:0]    write_data_stage2   = 0;
    reg     [ADDR_WIDTH-1:0]    write_addr_stage2   = 0;

    RAM_SDP_NEW 
    #(
        .WORD_WIDTH (WORD_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .DEPTH      (MEM_DEPTH),
        .RAMSTYLE   (MEM_RAMSTYLE),
        .INIT_FILE  (MEM_INIT_FILE)
    )
    MEM
    (
        .clock      (clock),
        .wren       (mem_wren_stage2),
        .write_addr (write_addr_stage2),
        .write_data (write_data_stage2),
        .rden       (mem_rden),
        .read_addr  (read_addr), 
        .read_data  (mem_read_data)
    );

// -----------------------------------------------------------
// -----------------------------------------------------------
// Read Stage 1

    wire io_read_data_selected_raw;
    
    Translated_Addressed_Mux
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .INPUT_COUNT        (IO_READ_PORT_COUNT),
        .INPUT_BASE_ADDR    (IO_READ_PORT_BASE_ADDR),
        .INPUT_ADDR_WIDTH   (IO_READ_PORT_ADDR_WIDTH),
    )
    IO_Read_Select
    (
        .addr               (read_addr),
        .in                 (io_read_data), 
        .out                (io_read_data_selected_raw)
    );

    reg io_read_data_selected = 0;

    always @(posedge clock) begin
        io_read_data_selected <= io_read_data_selected_raw;
    end

// -----------------------------------------------------------

    // Disable RAM read enable if reading from IO port or from address zero
    // See later for logic to clear read data to zero.

    always @(*) begin
        mem_rden <= (~read_addr_is_IO) & (read_addr != 0);
    end

// -----------------------------------------------------------

    reg     read_addr_is_IO_stage2  = 0;
    reg     IO_ready_stage2         = 0;
    reg     mem_rden_stage2         = 0;

    always @(posedge clock) begin
        read_addr_is_IO_stage2  <= read_addr_is_IO;
        IO_ready_stage2         <= IO_ready;
        mem_rden_stage2         <= mem_rden;
    end


// -----------------------------------------------------------
// -----------------------------------------------------------
// Read Stage 2

    // If IO_ready is zero, output zero always, 
    // else output IO  read data if read_addr_is_IO is set,
    // else output RAM read data

    wire    [WORD_WIDTH-1:0]    read_data_raw;

    Addressed_Mux
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .INPUT_COUNT    (2)
    )
    Read_Select
    (
        addr            ({IO_ready_stage2,read_addr_is_IO_stage2}),  // {MSB,...,LSB}  
        in              ({io_read_data_selected,mem_read_data,ZERO,ZERO}),
        out             (read_data_raw)
    );

// -----------------------------------------------------------

    // Special case logic: clear read data to zero if reading address zero.
    // This works because no IO port is to be mapped at address 0.
    // Doing it this way is clearer than expanding the Read_Select mux and
    // does not depend on the read enable output behaviour of the particular RAM used.

    wire [WORD_WIDTH-1:0] read_data_annulled;

    Annuller
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Read_Data_Clear
    (
        .annul      ((mem_rden_stage2 == 0)),
        .in         (read_data_raw),
        .out        (read_data_annulled)
    );

    always @(posedge clock) begin
        read_data <= read_data_annulled;
    end



// -----------------------------------------------------------
// -----------------------------------------------------------
// Write Stage 1

    wire    [IO_WRITE_PORT_COUNT-1:0]    io_wren_raw;

    IO_Active
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (IO_WRITE_PORT_COUNT),
        .PORT_BASE_ADDR     (IO_WRITE_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (IO_WRITE_PORT_ADDR_WIDTH)
    )
    Write_IO_Active
    (
        .enable             (write_addr_is_IO),
        .addr               (write_addr),
        .active             (io_wren_raw)
    );

    reg     [IO_WRITE_PORT_COUNT-1:0]   io_wren_stage2          = 0;
    reg                                 write_addr_is_IO_stage2 = 0;

// -----------------------------------------------------------

    always @(posedge clock) begin
        io_wren_stage2          <= io_wren_raw;
        write_addr_is_IO_stage2 <= write_addr_is_IO;
        write_addr_stage2       <= write_addr;
        write_data_stage2       <= write_data;
    end

// -----------------------------------------------------------
// -----------------------------------------------------------
// Write Stage 2

    // Disable RAM write enable if writing to IO port or to address zero
    // Note that no IO port is to be mapped at address 0.

    always @(*) begin
        mem_wren_stage2 <= (~write_addr_is_IO_stage2) & (write_addr_stage2 != 1'b0);
    end

// -----------------------------------------------------------

    // Pass the IO write enables to the output

    always @(posedge clock) begin
        io_wren <= io_wren_stage2;
    end

// -----------------------------------------------------------

    // Only the word with the corresponding io_wren set changes.

    Register_Array 
    #(
        .COUNT      (IO_WRITE_PORT_COUNT), 
        .WIDTH      (WORD_WIDTH)
    ) 
    Write_IO
    (
        .clocki     (clock),
        .wren       (io_wren_stage2),
        .in         (write_data_stage2),
        .out        (io_write_data)
    );

endmodule

