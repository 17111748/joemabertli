`default_nettype none

module half_adder (
    input  logic a,
    input  logic c_in,
    output logic y,
    output logic c_out
);

    xor out    (y, a, c_in);
    and carry  (c_out, c_in, a);

endmodule: half_adder

module full_adder (
    input  logic a,
    input  logic b,
    input  logic c_in,
    output logic y,
    output logic c_out
);
    logic a_xor_b;
    logic a_and_b;
    logic c_and_axb;
    
    xor axb    (a_xor_b, a, b);
    and aab    (a_and_b, a, b);
    and caaxb  (c_and_axb, a_and_b, c_in);
    or  carry  (c_out, c_and_axb, a_and_b);
    xor out    (y, a_xor_b, c_in);

endmodule: full_adder

/*
 * Combinationally increments the input by one, structurally implemented.
 */
module incrementer #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH - 1:0] x,
    output logic [WIDTH - 1:0] x_plus_1
);

    logic [WIDTH:0] c;
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
