`default_nettype none

module node_pow2_adder #(
    parameter BWIDTH = 4,
    parameter UWIDTH = 2  // it is expected that UWIDTH is always 2
)(

    input  logic [BWIDTH - 1:0]               x,
    output logic [BWIDTH - 1:0]               y
);

    /* 
    * o counts the number of ones contained in the multiplication 
    * assuming the input is represented as two unary numbers of UWIDTH
    * 2 that should be multipli
    logic [2:0] o;

    always_comb begin

        
    end
    

endmodule: node_pow2_adder
