`default_nettype none

module half_adder (
    input  logic a,
    input  logic c_in,
    output logic y,
    output logic c_out
);

    xor out    (y, a, 1'b1);
    and carry  (c_out, c_in, a);

endmodule: half_adder

/*
 * Combinationally increments the input by one, structurally implemented.
 */
module incrementer #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH - 1:0] x,
    output logic [WIDTH - 1:0] x_plus_1
);

    logic [WIDTH - 1:0] c;
    assign c[0] = 1'b1;

    genvar i;
    generate 
        for(i = 0; i < WIDTH; i++) begin
            half_adder ha (
                .a      (x[i]),
                .c_in   (c[i]),
                .y      (x_plus_1[i]),
                .c_out  (c[i + 1])
            );
        end
    endgenerate

endmodule: incrementer
