`default_nettype none

/*
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
module counter #(
    parameter WIDTH = 8
)(
    input  logic               clk,
    input  logic               reset_n,

    input  logic [WIDTH - 1:0] x,
    input  logic               load_x,

    input  logic               en,

    output logic [WIDTH - 1:0] y
);

    logic [WIDTH - 1:0] counter_d;
    logic [WIDTH - 1:0] counter_q;
    logic [WIDTH - 1:0] q_plus_1;

    incrementer #(
        .WIDTH(WIDTH)
    ) inc (
        .x         (counter_q),
        .x_plus_1  (q_plus_1)
    );

    always_comb begin
        counter_d = counter_q;

        if(load_x) begin
            counter_d = x;
        end

        else if(en) begin
            counter_d = q_plus_1;
        end
    end

    assign y = counter_q;

    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            counter_q <= 'b0;
        end

        else begin
            counter_q <= counter_d;
        end
    end

endmodule: counter

