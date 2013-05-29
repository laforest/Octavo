
module Memory_address_decoder
#(
    parameter       ADDR_COUNT          = 0,
    parameter       ADDR_BASE           = 0,
    parameter       ADDR_WIDTH          = 0
)
(
    input   wire    [ADDR_WIDTH-1:0]    addr,
    output  reg                         match 
);
    integer i;
    reg             [ADDR_COUNT-1:0]    per_addr_match;

    // Check each address in range for match
    always @(*) begin
        for(i = 0; i < ADDR_COUNT; i = i + 1) begin : addr_decode
            if( addr === (ADDR_BASE + i) ) begin
                per_addr_match[i] <= `HIGH;
            end
            else begin
                per_addr_match[i] <= `LOW;
            end
        end
    end

    // Do any of them match?
    always @(*) begin : is_match
        match <= | per_addr_match;
    end 

    initial begin
        for(i = 0; i < ADDR_COUNT; i = i + 1) begin
            per_addr_match[i] = `LOW; 
        end
    end
endmodule


module Memory_wren 
#(
    parameter       OPCODE_WIDTH        = 0
)
(
    input   wire    [OPCODE_WIDTH-1:0]  op,
    input   wire                        wren_other,
    output  reg                         wren
);
    reg     op_wren;
    always @(*) begin
        case(op)
            `JMP:       op_wren <= `LOW;
            `JZE:       op_wren <= `LOW;
            `JNZ:       op_wren <= `LOW;
            `JPO:       op_wren <= `LOW;
            `JNE:       op_wren <= `LOW;
            default:    op_wren <= `HIGH;
        endcase
    end

    always @(*) begin
        wren <= op_wren & wren_other;
    end

    initial begin
        wren     = 0;
        op_wren     = 0;
    end
endmodule


module Memory_bram 
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
    (* ramstyle = RAMSTYLE *) 
    reg [WORD_WIDTH-1:0] ram [DEPTH-1:0];

    initial begin
        $readmemh(INIT_FILE, ram);
    end

    always @(posedge clock) begin
        // NEW data read-during-write behaviour
        // Grants highest BRAM operating speed
        // Also provides write forwarding
        if(wren == `HIGH) begin
            ram[write_addr] = write_data;
        end
        read_data = ram[read_addr];
    end

    initial begin
        read_data = 0;
    end
endmodule


module Memory_address_translator
#(
    parameter       ADDR_COUNT          = 0,
    parameter       ADDR_BASE           = 0,
    parameter       ADDR_WIDTH          = 0
)
(
    input   wire    [ADDR_WIDTH-1:0]    raw_address,
    output  reg     [ADDR_WIDTH-1:0]    translated_address
);

    // Since I/O addresses are not always aligned to power-of-2 boundaries and
    // may not span power-of-2 blocks, the LSB are not necessarily consecutive,
    // exhaustive, and starting at zero: their order can be rotated by the
    // offset to the nearest power-of-2 boundary. Thus, we construct a
    // translation table that should hopefully optimize down to mere rewiring
    // of the mux inputs or of its internal logic.

    
    localparam ADDR_DEPTH = 2**ADDR_WIDTH;

    integer                     i, j;
    reg     [ADDR_WIDTH-1:0]    translation_table [ADDR_DEPTH-1:0];

    initial begin
        // In the case where ADDR_COUNT < ADDR_DEPTH, make sure all entries are defined
        // This happens for a single port: ADDR_WIDTH is artificially kept at 1 instead of 0
        for(i = 0; i < ADDR_DEPTH; i = i + 1) begin
            translation_table[i] = 'h0;
        end

        // In the case of a single port, the LSB (j) will be either 1 or zero,
        // but always translates to 0, thus this should optimize away.
        j = ADDR_BASE[ADDR_WIDTH-1:0];
        for(i = 0; i < ADDR_COUNT; i = i + 1) begin
            translation_table[j] = i[ADDR_WIDTH-1:0];
            j = (j + 1) % ADDR_DEPTH; // Force wrap-around
        end
    end

    always @(*) begin
        translated_address <= translation_table[raw_address];
    end

endmodule


module Memory_io_read_port_select
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

    Memory_address_translator
    #(
        .ADDR_COUNT         (IO_READ_PORT_COUNT),
        .ADDR_BASE          (IO_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH         (IO_READ_PORT_ADDR_WIDTH)
    )
    io_read_port_address_translator
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


module Memory_io_read_data_select 
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
    Memory_address_decoder
    #(
        .ADDR_COUNT     (IO_READ_PORT_COUNT),
        .ADDR_BASE      (IO_READ_PORT_BASE_ADDR),
        .ADDR_WIDTH     (ADDR_WIDTH)
    )
    read_address_decoder
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


module Memory_io_read_port_rden
#(
    parameter       IO_READ_PORT_COUNT              = 0, 
    parameter       IO_READ_PORT_ADDR_WIDTH         = 0 
)
(
    input   wire                                    clock,
    input   wire                                    addr_in_io_range,
    input   wire    [IO_READ_PORT_ADDR_WIDTH-1:0]   port_addr,
    output  reg     [IO_READ_PORT_COUNT-1:0]        rden
);
    // Read Enables, one per port
    integer port = 0;
    always @(posedge clock) begin
        for(port = 0; port < IO_READ_PORT_COUNT; port = port + 1) begin
            if(addr_in_io_range === `HIGH && 
               port_addr        === port) 
            begin
                rden[port +: 1] <= `HIGH;
            end
            else begin
                rden[port +: 1] <= `LOW;
            end
        end 
    end
endmodule


module Memory_io_read_port 
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
    output  wire    [IO_READ_PORT_COUNT-1:0]                    read_data_io_rden_out,
    output  wire    [WORD_WIDTH-1:0]                            read_data_out  
);

    wire    [IO_READ_PORT_ADDR_WIDTH-1:0]   port_addr;
    wire    [WORD_WIDTH-1:0]                read_data_io_out;

    Memory_io_read_port_select
    #(
        .WORD_WIDTH                 (WORD_WIDTH), 
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_READ_PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR), 
        .IO_READ_PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH),
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT)
    )
    io_read_port_select
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

    Memory_io_read_data_select 
    #(
        .WORD_WIDTH                 (WORD_WIDTH), 
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT),
        .IO_READ_PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR) 
    )
    io_read_data_select
    (
        .clock (clock),
        .read_addr_ram              (read_addr_data_select),
        .read_data_ram              (read_data_ram_in),
        .read_data_io               (read_data_io_out),
        .addr_in_io_range           (addr_in_io_range),
        .read_data                  (read_data_out)
    );

    Memory_io_read_port_rden
    #(
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT), 
        .IO_READ_PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH)
    )
    io_read_port_rden
    (
        .clock                      (clock),
        .addr_in_io_range           (addr_in_io_range),
        .port_addr                  (port_addr),
        .rden                       (read_data_io_rden_out)
    );
endmodule

module Memory_io_write_port 
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

    Memory_address_decoder
    #(
        .ADDR_COUNT     (IO_WRITE_PORT_COUNT),
        .ADDR_BASE      (IO_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH     (ADDR_WIDTH)
    )
    write_address_decoder
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

    Memory_address_translator
    #(
        .ADDR_COUNT         (IO_WRITE_PORT_COUNT),
        .ADDR_BASE          (IO_WRITE_PORT_BASE_ADDR),
        .ADDR_WIDTH         (IO_WRITE_PORT_ADDR_WIDTH)
    )
    io_write_address_translator
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
    output  wire    [IO_READ_PORT_COUNT-1:0]                    io_rden,
    input   wire    [(WORD_WIDTH * IO_READ_PORT_COUNT)-1:0]     io_in,
    output  wire    [IO_WRITE_PORT_COUNT-1:0]                   io_wren,
    output  wire    [(WORD_WIDTH * IO_WRITE_PORT_COUNT)-1:0]    io_out
);

    wire                        wren_ram;
    wire    [ADDR_WIDTH-1:0]    write_addr_ram;
    wire    [WORD_WIDTH-1:0]    write_data_ram;

    Memory_io_write_port 
    #(
        .WORD_WIDTH                 (WORD_WIDTH),
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_WRITE_PORT_COUNT        (IO_WRITE_PORT_COUNT),
        .IO_WRITE_PORT_BASE_ADDR    (IO_WRITE_PORT_BASE_ADDR),
        .IO_WRITE_PORT_ADDR_WIDTH   (IO_WRITE_PORT_ADDR_WIDTH)
    )
    io_write_port 
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

    Memory_bram 
    #(
        .WORD_WIDTH         (WORD_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DEPTH              (DEPTH),
        .RAMSTYLE           (RAMSTYLE),
        .INIT_FILE          (INIT_FILE)
    )
    ram 
    (
        .clock              (clock),
        .wren               (wren_ram),
        .write_addr         (write_addr_ram),
        .write_data         (write_data_ram),
        .read_addr          (read_addr),
        .read_data          (read_data_ram)
    );

    Memory_io_read_port 
    #(
        .WORD_WIDTH                 (WORD_WIDTH),
        .ADDR_WIDTH                 (ADDR_WIDTH),
        .IO_READ_PORT_BASE_ADDR     (IO_READ_PORT_BASE_ADDR),
        .IO_READ_PORT_COUNT         (IO_READ_PORT_COUNT),
        .IO_READ_PORT_ADDR_WIDTH    (IO_READ_PORT_ADDR_WIDTH)
    )
    io_read_port
    (
        .clock                      (clock),
        .read_addr                  (read_addr),
        .read_data_ram_in           (read_data_ram),
        .read_data_io_in            (io_in),
        .read_data_io_rden_out      (io_rden),
        .read_data_out              (read_data)
    );
endmodule

