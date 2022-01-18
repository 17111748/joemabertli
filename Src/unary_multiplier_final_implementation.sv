// `default_nettype none 
// `timescale 1ns/1ps



// TODO: Don't wait on 2^b cycles 
// TODO: Change unary to radix 2 
// TODO: Wallace Tree for the Adder Tree 

module temporal_mxu #(
    parameter DIM = 16, 
    parameter BIT_WIDTH = 2,
    parameter OUT_BIT_WIDTH = 2 * BIT_WIDTH,  
    parameter SIZE = BIT_WIDTH-1, 
    parameter A_ROW = DIM,
    parameter A_ROW_SIZE = $clog2(A_ROW) + 1, // bit width of A_ROW; TODO: clog2 gives the ceiling of log2(x), but in the case of x = power of 2, we need one more bit
    parameter A_COL = A_ROW,
    parameter B_ROW = A_COL,  
    parameter B_COL = A_ROW 
)(
    input  logic clk, 
    input  logic reset_n, 
    input  logic start, 
    input  logic [A_ROW-1:0][A_COL-1:0][BIT_WIDTH-1:0] A, 
    input  logic [B_ROW-1:0][B_COL-1:0][BIT_WIDTH-1:0] B, 
    input  logic [B_ROW-1:0][B_COL-1:0][BIT_WIDTH-1:0] C,
    input  logic [BIT_WIDTH-1:0] alpha, 
    input  logic [BIT_WIDTH-1:0] beta,  
    output logic out_valid, 
    output logic [A_ROW-1:0][B_COL-1:0][(BIT_WIDTH<<1)-1:0] out
);    
    logic [BIT_WIDTH-1:0] counter_out; 
    logic [A_COL-1:0][BIT_WIDTH-1:0] A_comparator_in; // Magnitude of the inputs coming in 
    logic [A_COL-1:0] A_is_negative; // Signed bit of the inputs coming in 
    logic [A_COL-1:0] A_is_odd; 
    logic [B_ROW-1:0] unary_A_comparator_out; 

    logic data_clk; // asserts high 2^b + constant clock cycles
    assign data_clk = (counter_out == 0);
    logic [A_ROW_SIZE+1:0] data_clk_count; 

    logic all_zero; 
    assign all_zero = (unary_A_comparator_out == 0);

    assign out_valid = data_clk && (data_clk_count == (A_COL)); 


    logic counter_clear; 
    assign counter_clear = ~reset_n || start || all_zero;

    logic data_counter_clear; 
    assign data_counter_clear = ~reset_n || start; 

    Counter_by_2 #(.WIDTH(BIT_WIDTH)) counter_A(.en(1'b1), .clear(counter_clear), .clk(clk), .Q(counter_out)); 
    Counter #(.WIDTH(A_ROW_SIZE+2)) counter_data_clk(.en(1'b1), .clear(data_counter_clear), .clk(data_clk), .Q(data_clk_count));

    genvar i; 
    generate 
        for (i = 0; i < A_COL; i=i+1) begin 
            LessThan_Comparator #(.WIDTH(BIT_WIDTH)) comparator_A(.counter(counter_out), .A(A_comparator_in[i]), .out(unary_A_comparator_out[i]));  
        end 
    endgenerate

    logic [A_ROW_SIZE+1:0] data_clk_count_B_max; // Prevents B from indexing out of bounds 
    assign data_clk_count_B_max = (data_clk_count < B_ROW) ? data_clk_count + 1 : B_ROW; 
        
    // Instantiate the unary binary nodes (B)
    genvar c_row, c_col; 
    generate 
        for (c_row = 0; c_row < A_ROW; c_row=c_row+1) begin 
            for (c_col = 0; c_col < B_COL; c_col=c_col+1) begin 
                unary_binary_node_by_2 #(.BIT_WIDTH(BIT_WIDTH), 
                                    .A_ROW(A_ROW), 
                                    .A_COL(A_COL), 
                                    .B_ROW(B_ROW), 
                                    .B_COL(B_COL)) 
                unary_binary_nodes (.clk(clk), 
                                    .reset_n(reset_n), 
                                    .start(start), 
                                    .data_clk(data_clk), 
                                    .unary_A(unary_A_comparator_out[c_row]), 
                                    .A_is_negative(A_is_negative[c_row]), 
                                    .A_is_odd(A_is_odd[c_row]), 
                                    .alpha(alpha), 
                                    .beta(beta), 
                                    .C(C[c_row][c_col]), 
                                    .B(B[(B_ROW - data_clk_count_B_max)][c_col]),  
                                    .out(out[c_row][c_col])); 
            end 
        end 
    endgenerate 

    


    // Combinational logic with clocking to determine A_comparator_in (systolic flow into the comparator)
    // Scheduling the A as inputs 
    always_comb begin 
        if (~reset_n) begin 
            for (int j = 0; j < A_COL; j=j+1) begin
                A_comparator_in[j] = 0;
                A_is_negative[j] = 1'b0; 
                A_is_odd[j] = 1'b0; 
            end 
        end
        else if (start) begin 
            for (int j = 0; j < A_COL; j=j+1) begin
                A_comparator_in[j] = 0;
                A_is_negative[j] = 1'b0; 
                A_is_odd[j] = 1'b0; 
            end 
        end 
        else if (data_clk_count < A_ROW) begin  
            for (int j = 0; j < A_ROW; j=j+1) begin 
                if (A[j][(A_ROW - data_clk_count - 1)][BIT_WIDTH-1]) begin 
                    A_comparator_in[j] = ~(A[j][(A_ROW - data_clk_count - 1)][BIT_WIDTH-1:0]) + 1; 
                    A_is_negative[j] = A[j][(A_ROW - data_clk_count - 1)][BIT_WIDTH-1]; 
                    A_is_odd[j] = A[j][(A_ROW - data_clk_count - 1)][0]; 
                end 
                else begin 
                    A_comparator_in[j] = A[j][(A_ROW - data_clk_count - 1)][BIT_WIDTH-1:0]; 
                    A_is_negative[j] = A[j][(A_ROW - data_clk_count - 1)][BIT_WIDTH-1]; 
                    A_is_odd[j] = A[j][(A_ROW - data_clk_count - 1)][0]; 
                end 
            end
        end  
        else begin 
            for (int j = 0; j < A_COL; j=j+1) begin
                A_comparator_in[j] = 0;
                A_is_negative[j] = 1'b0;
                A_is_odd[j] = 1'b0;  
            end 
        end 
    end 

endmodule 


// unary_binary_node that has the AND gates and adder tree 
module unary_binary_node_by_2 #(
    parameter BIT_WIDTH = 4, 
    parameter SIZE = BIT_WIDTH-1, 
    parameter A_ROW = 8,
    parameter A_COL = 8,
    parameter B_ROW = A_COL,  
    parameter B_COL = 8 
) (
    input  logic clk, 
    input  logic reset_n, 
    input  logic start, 
    input  logic data_clk, 
    input  logic unary_A, 
    input  logic A_is_negative, 
    input  logic A_is_odd, 
    input  logic [BIT_WIDTH-1:0] B, 
    input  logic [BIT_WIDTH-1:0] C, 
    input  logic [BIT_WIDTH-1:0] alpha, 
    input  logic [BIT_WIDTH-1:0] beta, 
    output logic [(BIT_WIDTH<<1)-1:0] out 
); 

    logic [(1<<SIZE)-1:0] unary_out; 
    assign unary_out[(1<<SIZE)-1] = 1'b0;

    logic [SIZE-1:0] translated_B; // Convert to Signed Magnitude 
    assign translated_B = (B[BIT_WIDTH-1]) ? (~(B[BIT_WIDTH-2:0]) + 1) : B[BIT_WIDTH-2:0]; 

    // Mask the Fanned Out unary inputs with the bits of a binary number 
    genvar i; 
    generate 
        for(i = 1; i < (1<<SIZE); i=i+1) begin 
            assign unary_out[i-1] = unary_A & translated_B[$clog2(i+1)-1]; // Masking it with the second input
        end
    endgenerate  

    logic [$clog2((1<<SIZE)+1)-1:0] adder_tree_out; 
    adder_tree #(.NUM_ELEMENTS((1<<SIZE))) at (.in(unary_out), .sum(adder_tree_out));

    always_ff@(posedge clk, negedge reset_n) begin 
        if (~reset_n) begin  
            out <= beta * C; 
        end 
        else if (start) begin 
            out <= beta * C;  
        end 
        else begin 
            if (B[BIT_WIDTH-1] != A_is_negative) begin 
                if (data_clk && (A_is_odd)) begin 
                    out <= out - (alpha * adder_tree_out); 
                end 
                else begin 
                    out <= out - (alpha * (adder_tree_out << 1)); 
                end 
            end 
            else begin 
                if (data_clk && (A_is_odd)) begin 
                    out <= out + (alpha * adder_tree_out); 
                end 
                else begin 
                    out <= out + (alpha * (adder_tree_out << 1)); 
                end 
            end 
        end   
    end 

      
endmodule : unary_binary_node_by_2



module Counter 
  #(parameter WIDTH = 4) 
  (input  logic en, 
   input  logic clear, 
   input  logic clk, 
   output logic [WIDTH-1:0] Q);

   always_ff @(posedge clk, posedge clear) begin  
    if(clear)
      Q <= 0; 
    else if (en)
      Q <= Q + 1; 
    end 

endmodule : Counter 

module Counter_by_2 
  #(parameter WIDTH = 4) 
  (input  logic en, 
   input  logic clear, 
   input  logic clk, 
   output logic [WIDTH-1:0] Q);

   always_ff @(posedge clk, posedge clear) begin 
    if(clear)
      Q <= 0; 
    else if (en) begin 
      Q <= Q + 2; 
    end
   end 

endmodule : Counter_by_2 

module LessThan_Comparator #(
    parameter WIDTH = 4
) (
    input  logic [WIDTH-1:0] counter, 
    input  logic [WIDTH-1:0] A, 
    output logic out
); 

    assign out = (counter < A); 

endmodule : LessThan_Comparator 


// TODO: Change this to Wallace T
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


module half_adder(
    input  logic x,
    input  logic y,
    output logic s,
    output logic c_out
);

    assign s = x ^ y;
    assign c_out = x & y;

endmodule : half_adder

module full_adder(
    input  logic x,
    input  logic y,
    input  logic c_in,
    output logic s,
    output logic c_out
);

    logic half_sum;

    assign half_sum = x ^ y;

    assign s = c_in ^ half_sum;
    assign c_out = (half_sum & c_in) | (x & y);

endmodule

module rca #(
    parameter BIT_WIDTH = 8,
    parameter CIN = 1
) (
    input  logic [BIT_WIDTH-1:0] a,
    input  logic [BIT_WIDTH-1:0] b,
    input  logic                 c_in,
    output logic [BIT_WIDTH:0]   s
);

    logic [BIT_WIDTH-1:0] c;

    assign s[BIT_WIDTH] = c[BIT_WIDTH-1];

    generate
        if (CIN) begin
            full_adder  first(
                .x(a[0]),
                .y(b[0]),
                .c_in(c_in),
                .s(s[0]),
                .c_out(c[0])
            );            
        end
        else begin
            half_adder  first(
                .x(a[0]),
                .y(b[0]),
                .s(s[0]),
                .c_out(c[0])
            );
        end
    endgenerate

    genvar i;
    generate
        for (i=1; i < BIT_WIDTH; i++) begin

            full_adder  full_adder0(
                .x(a[i]),
                .y(b[i]),
                .c_in(c[i-1]),
                .s(s[i]),
                .c_out(c[i])
            );

        end
    endgenerate
    
endmodule : rca

module wallace_tree #(
    parameter NUM_ELEMENTS = 16,
    parameter INDEX_W = $clog2(NUM_ELEMENTS + 1),
    parameter I = $clog2(NUM_ELEMENTS)
) (
    input  logic [NUM_ELEMENTS-1:0] in,
    output logic [INDEX_W-1:0]      sum
);

    genvar i;
    generate
        if (NUM_ELEMENTS == 1) begin
            assign sum = in;
        end
        else if (NUM_ELEMENTS == 2) begin
            half_adder add_first(
                .x(in[0]),
                .y(in[1]),
                .s(sum[0]),
                .c_out(sum[1])
            );
        end
        else if (NUM_ELEMENTS == 3) begin
            full_adder add_first(
                .x(in[0]),
                .y(in[1]),
                .c_in(in[2]),
                .s(sum[0]),
                .c_out(sum[1])
            );
        end
        else begin
            localparam LEFT_SIZE = ((2 << I) - 1 == NUM_ELEMENTS) ? (2 << (I - 1)) - 1 : NUM_ELEMENTS/2;
            localparam LEFT_END_INDEX = LEFT_SIZE - 1;

            localparam RIGHT_SIZE = ((2 << I) - 1 == NUM_ELEMENTS) ? LEFT_SIZE : NUM_ELEMENTS - LEFT_SIZE;
            localparam RIGHT_INDEX = LEFT_END_INDEX + 1;
            localparam RIGHT_END_INDEX = ((2 << I) - 1 == NUM_ELEMENTS) ? LEFT_END_INDEX + RIGHT_SIZE : NUM_ELEMENTS - 1;

            localparam LEFT_W = $clog2(LEFT_SIZE+1);
            localparam RIGHT_W = $clog2(RIGHT_SIZE+1);

            logic [LEFT_W-1:0] left_out;
            logic [RIGHT_W-1:0] right_out;
            
            wallace_tree #(LEFT_SIZE) left(
                .in(in[LEFT_END_INDEX:0]),
                .sum(left_out)
            );

            wallace_tree #(RIGHT_SIZE) right(
                .in(in[RIGHT_END_INDEX:RIGHT_INDEX]),
                .sum(right_out)
            );

            if ((2 << I) - 1 == NUM_ELEMENTS) begin
                rca #(.BIT_WIDTH(RIGHT_W)) sum1(
                    .a(left_out),
                    .b(right_out),
                    .c_in(in[NUM_ELEMENTS-1]),
                    .s(sum)
                );
            end
            else begin
                rca #(.BIT_WIDTH(RIGHT_W), .CIN(0)) sum2(
                    .a(left_out),
                    .b(right_out),
                    .c_in(1'b0),
                    .s(sum)
                );
            end
        end
    endgenerate


endmodule : wallace_tree
