`default_nettype none
`timescale 1ns/10ps

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

module adder_tree 
    #(parameter NUM_ELEMENTS = 16,  //Should be same number as number of voters
      parameter INDEX_W = $clog2(NUM_ELEMENTS + 1)) 
    (input  logic [NUM_ELEMENTS-1:0] in,
     output logic [INDEX_W-1:0] sum);

    generate
        if(NUM_ELEMENTS == 1) begin
            assign sum = in[0];
        end else if(NUM_ELEMENTS == 2) begin
            assign sum = in[0] + in [1];
        end else if(NUM_ELEMENTS == 3) begin
            assign sum = in[0] + in [1] + in[2];
        end else begin
            localparam LEFT_SIZE = (NUM_ELEMENTS-1)/2; // subtract one for carry in
            localparam LEFT_END_INDEX = LEFT_SIZE;
            localparam LEFT_W = $clog2(LEFT_SIZE+1);

            localparam RIGHT_SIZE = (NUM_ELEMENTS-1) - LEFT_SIZE;
            localparam RIGHT_INDEX = LEFT_SIZE + 1;
            localparam RIGHT_END_INDEX = NUM_ELEMENTS - 1;
            localparam RIGHT_W = $clog2(RIGHT_SIZE+1);

            logic [LEFT_W-1:0] left_temp;
            logic [RIGHT_W-1:0] right_temp;

            logic carry_in;
            assign carry_in = in[0];
            adder_tree #(LEFT_SIZE) lefty (
                .in(in[LEFT_END_INDEX:1]),
                .sum(left_temp)
            );

            adder_tree #(RIGHT_SIZE) righty (
                .in(in[RIGHT_END_INDEX:RIGHT_INDEX]),
                .sum(right_temp)
            );

            always_comb begin
                sum = left_temp + right_temp + carry_in;
            end
        end
    endgenerate
endmodule

// Performs out = a*b + c 
module separate
    #(parameter SIZE = 4)
    (input  logic clk, 
     input  logic reset_n, 
     input  logic valid, // Start of when the input signal should be grabbed.
     input  logic [SIZE-1:0] a, 
     input  logic [SIZE-1:0] b, 
     input  logic [SIZE:0]   counter_out, 
     output logic ready, // Asserted when the output is ready to be read. 
     output logic [(1<<SIZE)-1:0] unary_out); 

    logic [(1<<SIZE)-1:0] unary; // Includes the c at the MSB

    // logic ready_flag; // Flag to reset the ready signal 

    logic [SIZE-1:0] a_reg; 
    logic [SIZE-1:0] b_reg; 

    // Stores the original binary input into a register 
    always_ff@(posedge clk) 
        if(valid) begin 
            a_reg <= a; 
            b_reg <= b; 
        end 


    assign ready = (counter_out >= a_reg); 

    // Turn binary input into unary input 
    always_ff@(posedge clk, negedge reset_n) 
        if(~reset_n) begin 
            unary[(1<<SIZE)-1:0]     <= (1<<SIZE)'('b0); 
        end 
        else begin 
            if(counter_out < a_reg) 
                unary[(1<<SIZE)-2:0] <= ~(((1<<SIZE)-1)'('b0)); // Change this to arbitrary size 
            else 
                unary[(1<<SIZE)-2:0] <= ((1<<SIZE)-1)'('b0); 
        end 


    // Mask the Fanned Out unary inputs with the bits of a binary number 
    genvar i; 
    generate 
        for(i = 1; i < (1<<SIZE); i = i + 1)
        begin : loop 
            assign unary_out[i-1] = unary[i-1] & b_reg[$clog2(i+1)-1]; // Masking it with the second input
        end: loop 
    endgenerate    

    // Accumulator 
    assign unary_out[(1<<SIZE)-1] = 1'b0; 



endmodule: separate


// Performs out = a*b + c 
module unary_binary_MAC
    #(parameter SIZE = 12,
      parameter SETS = 1)
    (input  logic clk, 
     input  logic reset_n, 
     input  logic valid, // Start of when the input signal should be grabbed.
     input  logic [(SETS*SIZE)-1:0] a, 
     input  logic [(SETS*SIZE)-1:0] b, 
     output logic ready, // Asserted when the output is ready to be read. 
     output logic [(SIZE<<1)+SETS-1:0] out); 

    logic [(1<<SIZE)*SETS-1:0] unary_out; // Includes the c at the MSB

    // logic ready_flag; // Flag to reset the ready signal 

    logic [(SETS*SIZE)-1:0] a_reg; 
    logic [(SETS*SIZE)-1:0] b_reg; 

    always_ff@(posedge clk) 
        if(valid) begin 
            a_reg <= a; 
            b_reg <= b; 
        end 

    logic [SIZE:0] counter_out; 
    logic [SETS-1:0] ready_out; 

    // Turn binary input into unary input 
    Counter #(SIZE+1) counter(.en(1'b1), .clear(valid), .clk(clk), .Q(counter_out)); 

    genvar j; 
    generate
        for(j = 0; j < SETS; j++) 
        begin : loop
            separate #(SIZE) s(.clk(clk), .reset_n(reset_n), .valid(valid), 
            .a(a[(j+1)*SIZE-1:j*SIZE]), .b(b[(j+1)*SIZE-1:j*SIZE]),
            .counter_out(counter_out), .ready(ready_out[j]), 
            .unary_out(unary_out[((j+1)*(1<<SIZE))-1:j*(1<<SIZE)]));
        end : loop 
    endgenerate
    
    logic [$clog2((1<<SIZE)*SETS+1)-1:0] at_out; 
    adder_tree #(.NUM_ELEMENTS((1<<SIZE)*SETS)) at (.in(unary_out), .sum(at_out)); 

    always_ff@(posedge clk, negedge reset_n) begin 
        if(~reset_n) 
            out <= 1'b0; 
        else if(valid == 1'b1)
            out <= 1'b0; 
        else 
            out <= out + at_out; 
    end 

    // FSM to control the ready signal 
    enum logic [1:0] {RESET, WAIT, READY} cs, ns; 
    always_ff @(posedge clk, negedge reset_n)
        if(~reset_n) 
            cs <= RESET; 
        else 
            cs <= ns; 
    
    always_comb begin 
        ready <= 1'b0; 
        case (cs)
            RESET: begin 
                ns = (valid) ? WAIT : RESET; 
            end 
            WAIT: begin 
                // ready <= (ready_out == ~((SETS)'('b0))) ? 1'b1 : 1'b0; 
                ns = (ready_out == ~((SETS)'('b0))) ? READY : WAIT; 
            end 
            READY: begin 
                ready <= 1'b1; 
                ns = RESET; 
            end 
        endcase
    end 


endmodule: unary_binary_MAC
