
// On-Chip Data_Memory/Register File. Provides read and write I/O ports.
// Only the addressed write I/O port changes values on write.

// I/O port addresses are relative to local memory location zero.

// Special behaviour when read/write enable not set: 
// returns zero on reads, and read and write
// enables are disabled to save BRAM power and enforce behaviour.

// Same for when addressing an I/O port: RAM is disabled to save power.

// See RAM_SDP.v for the meaning of the READ_NEW_DATA parameter.
// Typically, you will want it enabled. (set to 1) as it enables
// write-formwarding and higher speed.

// If you do not want write-forwarding, but keep the high speed, at the price
// of indeterminate behaviour on overlapping read/writes, use "no_rw_check" as
// part of the RAMSTYLE (e.g.: "M10K, no_rw_check").

// NOTE: set_global_assignment -name ADD_PASS_THROUGH_LOGIC_TO_INFERRED_RAMS
// OFF to disable creation of write-forwarding logic, as Quartus ignores the
// "no_rw_check" RAMSTYLE for M10K BRAMs.

// The "missing" io_rden (read enable) signal should be generated externally,
// in the stage before the Data_Memory, so the io_rden signal can be provided at
// the same time as the read_addr. 
// The same applies to the read_addr_is_IO signal.

module Data_Memory
#(
    parameter   WORD_WIDTH                              = 0,
    parameter   ADDR_WIDTH                              = 0,
    parameter   MEM_DEPTH                               = 0,
    parameter   MEM_RAMSTYLE                            = "",
    parameter   MEM_INIT_FILE                           = "",
    parameter   MEM_READ_NEW_DATA                       = 0,
    parameter   IO_PORT_COUNT                           = 0,
    parameter   IO_PORT_BASE_ADDR                       = 0,
    parameter   IO_PORT_ADDR_WIDTH                      = 0
)
(
    input   wire                                        clock,

    input   wire                                        read_enable,
    input   wire    [ADDR_WIDTH-1:0]                    read_addr,
    input   wire                                        read_addr_is_IO,
    output  reg     [WORD_WIDTH-1:0]                    read_data,
    input   wire    [(WORD_WIDTH*IO_PORT_COUNT)-1:0]    io_read_data,   // io_rden generated externally, see notes above

    input   wire                                        write_enable,
    input   wire    [ADDR_WIDTH-1:0]                    write_addr,
    input   wire                                        write_addr_is_IO,
    input   wire    [WORD_WIDTH-1:0]                    write_data,
    output  reg     [IO_PORT_COUNT-1:0]                 io_wren,
    output  wire    [(WORD_WIDTH*IO_PORT_COUNT)-1:0]    io_write_data
);

// -----------------------------------------------------------

    // When we need a zero of definite width.

    localparam ZERO = {WORD_WIDTH{1'b0}};

// -----------------------------------------------------------

    initial begin
        read_data = 0;
        io_wren   = 0;
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

    RAM_SDP 
    #(
        .WORD_WIDTH     (WORD_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DEPTH          (MEM_DEPTH),
        .RAMSTYLE       (MEM_RAMSTYLE),
        .READ_NEW_DATA  (MEM_READ_NEW_DATA),
        .USE_INIT_FILE  (1),
        .INIT_FILE      (MEM_INIT_FILE)
    )
    DMEM
    (
        .clock          (clock),
        .wren           (mem_wren_stage2),
        .write_addr     (write_addr_stage2),
        .write_data     (write_data_stage2),
        .rden           (mem_rden),
        .read_addr      (read_addr),
        .read_data      (mem_read_data)
    );

// -----------------------------------------------------------
// -----------------------------------------------------------
// Read Stage 1

    wire [WORD_WIDTH-1:0] io_read_data_selected_raw;
    
    Translated_Addressed_Mux
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .INPUT_COUNT        (IO_PORT_COUNT),
        .INPUT_BASE_ADDR    (IO_PORT_BASE_ADDR),
        .INPUT_ADDR_WIDTH   (IO_PORT_ADDR_WIDTH)
    )
    IO_Read_Select
    (
        .addr               (read_addr),
        .in                 (io_read_data), 
        .out                (io_read_data_selected_raw)
    );

    reg [WORD_WIDTH-1:0] io_read_data_selected = 0;

    always @(posedge clock) begin
        io_read_data_selected <= io_read_data_selected_raw;
    end

// -----------------------------------------------------------

    // Disable RAM read enable if reading from IO port 
    // or if reads are not enabled in general.

    always @(*) begin
        mem_rden <= (read_addr_is_IO == 0) & (read_enable == 1);
    end

// -----------------------------------------------------------

    reg                         read_enable_stage2         = 0;
    reg                         read_addr_is_IO_stage2  = 0;

    always @(posedge clock) begin
        read_enable_stage2      <= read_enable; 
        read_addr_is_IO_stage2  <= read_addr_is_IO;
    end


// -----------------------------------------------------------
// -----------------------------------------------------------
// Read Stage 2

    // Select I/O read data or Memory read data
    // See later for logic to clear read data to zero.

    reg [WORD_WIDTH-1:0] read_data_raw = 0;

    always @(*) begin
        read_data_raw <= (read_addr_is_IO_stage2 == 1) ? io_read_data_selected : mem_read_data;
    end

// -----------------------------------------------------------

    // Special case logic: clear read data to zero if read enable not set.
    // Does not depend on the read enable output behaviour of the particular RAM used.

    wire [WORD_WIDTH-1:0] read_data_annulled;

    Annuller
    #(
        .WORD_WIDTH (WORD_WIDTH)
    )
    Read_Data_Clear
    (
        .annul      ((read_enable_stage2 == 0)),
        .in         (read_data_raw),
        .out        (read_data_annulled)
    );

    always @(posedge clock) begin
        read_data <= read_data_annulled;
    end



// -----------------------------------------------------------
// -----------------------------------------------------------
// Write Stage 1

    reg     write_enable_io = 0;

    always @(*) begin
        write_enable_io = (write_addr_is_IO == 1) & (write_enable == 1);
    end

// -----------------------------------------------------------

    wire    [IO_PORT_COUNT-1:0]    io_wren_raw;

    IO_Active
    #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .PORT_COUNT         (IO_PORT_COUNT),
        .PORT_BASE_ADDR     (IO_PORT_BASE_ADDR),
        .PORT_ADDR_WIDTH    (IO_PORT_ADDR_WIDTH)
    )
    Write_IO_Active
    (
        .enable             (write_enable_io),
        .addr               (write_addr),
        .active             (io_wren_raw)
    );

    reg     [IO_PORT_COUNT-1:0]     io_wren_stage2          = 0;
    reg                             write_addr_is_IO_stage2 = 0;
    reg                             write_enable_stage2     = 0;

// -----------------------------------------------------------

    always @(posedge clock) begin
        io_wren_stage2          <= io_wren_raw;
        write_addr_is_IO_stage2 <= write_addr_is_IO;
        write_addr_stage2       <= write_addr;
        write_data_stage2       <= write_data;
        write_enable_stage2     <= write_enable;
    end

// -----------------------------------------------------------
// -----------------------------------------------------------
// Write Stage 2

    // Disable RAM write enable if writing to IO port 
    // or if writes are not enabled in general.

    always @(*) begin
        mem_wren_stage2 <= (write_addr_is_IO_stage2 == 0) & & (write_enable_stage2 == 1);
    end

// -----------------------------------------------------------

    // Pass the IO write enables to the output

    always @(posedge clock) begin
        io_wren <= io_wren_stage2;
    end

// -----------------------------------------------------------

    // Only the word with the corresponding io_wren set changes.
    // We only have one wren set at a time, so we replicate the new data word
    // to fit the input.

    Register_Array 
    #(
        .COUNT      (IO_PORT_COUNT), 
        .WIDTH      (WORD_WIDTH)
    ) 
    Write_IO
    (
        .clock     (clock),
        .wren       (io_wren_stage2),
        .in         ({IO_PORT_COUNT{write_data_stage2}}),
        .out        (io_write_data)
    );

endmodule

