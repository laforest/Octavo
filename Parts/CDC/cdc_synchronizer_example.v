
module cdc_synchronizer_example
#(
    parameter EXTRA_DEPTH = 3
)
(
    input   wire    sync_bit_from,
    input   wire    clock_to,
    output  reg     sync_bit_to
);

    cdc_synchronizer
    #(
        .EXTRA_DEPTH    (EXTRA_DEPTH)
    )
    example
    (
        .sync_bit_from  (sync_bit_from),
        .clock_to       (clock_to),
        .sync_bit_to    (sync_bit_to)
    );

endmodule

