`default_nettype none

module Counter 
  #(parameter WIDTH = 4) 
  (input  logic en, clear, clk, 
   output logic [WIDTH-1:0] Q);

   always_ff @(posedge clk) 
    if(clear)
      Q <= 0; 
    else if (en)
      Q <= Q + 1; 

endmodule: Counter

module Counter_Down
  #(parameter WIDTH = 4) 
  (input  logic en, load, clk, 
   input  logic [WIDTH-1:0] D, 
   output logic [WIDTH-1:0] Q);

   always_ff @(posedge clk) 
    if(load)
      Q <= D; 
    else if (en)
      Q <= Q - 1; 

endmodule: Counter_Down

module FA 
  (input  logic A, 
   input  logic B,
   input  logic Cin, 
   output logic sum, 
   output logic Cout);

    logic temp_1; 
    logic temp_2; 
    logic temp_3; 

    xor G1(temp_1, A, B); 
    xor G2(sum, temp_1, Cin); 
    and G3(temp_2, Cin, temp_1); 
    and G4(temp_3, A, B); 
    or  G5(Cout, temp_2, temp_3); 

endmodule: FA

module HA
  (input  logic A, 
   input  logic B,
   output logic sum, 
   output logic Cout); 

    xor G1 (sum, A, B); 
    and G2 (Cout, A, B); 

endmodule: HA