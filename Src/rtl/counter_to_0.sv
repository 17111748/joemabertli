`default_nettype none

/*
 * A counter that will stop counting once it hits 0.
 *
 * Inputs:
 *   - x                          Value to load into the counter.
 *   - load_x                     Valid bit to guard x.
 *   - en                         Enables counter increment.
 *                                If en and load_x are high at the same time,
 *                                load_x takes precedence.
 * 
 * Outputs:
 *   -y                           The output of the counter.
 */
module counter_to_0 #(
    parameter WIDTH = 8
)(
    input  logic               clk,
    input  logic               reset_n,

    input  logic [WIDTH - 1:0] x,
    input  logic               load_x,

    input  logic               en,

    output logic [WIDTH - 1:0] y
);

    logic  count_en;
    assign count_en = (y != 'b0) && en;

    counter #(
        .WIDTH  (WIDTH)
    ) zero_counter (
        .clk      (clk),
        .reset_n  (reset_n),
        .x        (x),
        .load_x   (load_x),
        .en       (count_en),
        .y        (y)
    );

endmodule: counter_to_0
