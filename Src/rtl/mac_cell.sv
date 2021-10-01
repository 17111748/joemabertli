`default_nettype none

/*
 * If a and b are both high, it will increment or decrement a counter 
 * based on the value of pos.
 *
 * Parameters:
 *   - WIDTH                      The bitwidth of the output. 
 *
 * Inputs:
 *   - a                          Unary signal a.
 *   - b                          Unary signal b.
 *   - pos                        Indicates whether the multiplication of a
 *                                and b should be positive or negative.
 *
 * Outputs:
 *   - total                      The total MAC value for this cell.
 */
module mac_cell #(
    parameter WIDTH = 8
)(
    input  logic               clk,
    input  logic               reset_n,

    input  logic               a,
    input  logic               b,
    input  logic               pos,

    output logic [WIDTH - 1:0] total
);

    logic [WIDTH - 1:0] total_d;
    logic [WIDTH - 1:0] total_q;

    logic [WIDTH - 1:0] inc_val;

    assign inc_val = ((a & b) ? ((pos) ? 'b1 : {WIDTH{1'b1}}) :
                                'b0);
    assign total = total_q + inc_val;

    always_ff @(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            total_q <= 'b0;
        end

        else begin
            total_q <= total_d;
        end
    end

endmodule: mac_cell
