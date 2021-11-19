// `include "tb_define.vh"
`default_nettype none

// module unary_multiplier_tb ();

//     class rand_matrix #(
//         parameter N = 8,
//         parameter M = 8,
//         parameter WIDTH = 8
//     );
//         rand bit [N - 1:0][M - 1:0][WIDTH - 1:0] matrix;

//         function logic [N - 1:0][M - 1:0][WIDTH - 1:0] gen_matrix();
//             gen_matrix = matrix;
//         endfunction
//     endclass

//     logic clk;
//     logic reset_n;

//     logic [`A_N - 1:0][`A_M - 1:0][`BITWIDTH - 1:0] A;
//     logic [`B_N - 1:0][`B_M - 1:0][`BITWIDTH - 1:0] B;
//     logic [`A_N - 1:0][`B_M - 1:0][2*`BITWIDTH - 1:0] Y;

//     logic a_valid;
//     logic b_valid;
//     logic y_valid;

//     int     i;
//     longint timeout;

//     logic start; 

//     rand_matrix #(.N(`A_N), .M(`A_M), .WIDTH(`BITWIDTH)) A_rand;
//     rand_matrix #(.N(`B_N), .M(`B_M), .WIDTH(`BITWIDTH)) B_rand;

//     temporal_mxu #(.DIM(`A_N), .BIT_WIDTH(`BITWIDTH)) dut(
//         .clk(clk),
//         .reset_n(reset_n),
//         .start(start), 
//         .B(B),
//         .A(A),
//         .out(Y),
//         .out_valid(y_valid)
//     );
   

//     initial begin
//         clk = 0;
//         forever #1 clk = ~clk;
//     end

//     task reset();
//         reset_n  = 1'b1;
//         reset_n <= 1'b0;
//         @(posedge clk);
//         reset_n <= 1'b1;
//     endtask

//     function logic [`A_N - 1:0][`B_M - 1:0][2*`BITWIDTH - 1:0] matrix_multiply();
//         /* Initialize to 0 */
//         for(int row = 0; row < `A_N; row++) begin
//             for(int col = 0; col < `B_M; col++) begin
//                 matrix_multiply[row][col] = 0;
//             end
//         end

//         /* Compute the matrix multiply */
//         for(int row = 0; row < `A_N; row++) begin
//             for(int col = 0; col < `B_M; col++) begin
//                 for(int x = 0; x < `A_M; x++) begin
//                     if (A[row][x][`BITWIDTH - 1] ^ B[x][col][`BITWIDTH - 1]) begin
//                         matrix_multiply[row][col] -= A[row][x] * B[x][col];
//                     end
//                     else begin
//                         matrix_multiply[row][col] += A[row][x] * B[x][col];
//                     end
//                 end
//             end
//         end
//     endfunction

//     task check_output();
//         logic [`A_N - 1:0][`B_M - 1:0][2*`BITWIDTH - 1:0] correct;
//         correct = matrix_multiply();

//         for(int row = 0; row < `A_N; row++) begin
//             for(int col = 0; col < `B_M; col++) begin
//                 if(correct[row][col] != Y[row][col]) begin
//                     $display("Failed test for (row, col) = (%d, %d). Got %h, expected %h.",
//                         row, col, Y[row][col], correct[row][col]);

//                     `ifdef FAIL_ON_ERROR
//                         $error();
//                     `endif

//                 end
//             end
//         end
//     endtask


//     initial begin
//         $monitor($time,, "start: %b, out_valid: %b", start, y_valid); 
//     end 
//     initial begin
//         $dumpfile("unary_multiplier.vcd");
//         $dumpvars(0, unary_multiplier_tb);
//         reset();

//         for(i = 0; i < `TEST_CASES; i++) begin
//             A_rand = new();
//             B_rand = new();

//             if(!A_rand.randomize()) $error("random gen error");
//             if(!B_rand.randomize()) $error("random gen error");

//             // A                  <= A_rand.gen_matrix();
//             // B                  <= B_rand.gen_matrix();
//             A = A_rand.matrix;
//             B = B_rand.matrix;

//             //$write("A = [\n");
//             for(int row = 0; row < `A_N; row++) begin
//                 //$write("\t");
//                 for(int col = 0; col < `B_M; col++) begin
//                     //$write("%h ", A[row][col]);
//                 end
//                 //$write("\n");
//             end
//             //$write("    ]\n");

//             //$write("B = [\n");
//             for(int row = 0; row < `A_N; row++) begin
//                 //$write("\t");
//                 for(int col = 0; col < `B_M; col++) begin
//                     //$write("%h ", B[row][col]);
//                 end
//                 //$write("\n");
//             end
//             //$write("    ]\n");

//             @(posedge clk); 
//             start <= 1'b1; 
//             @(posedge clk); 
//             start <= 1'b0; 
//             {a_valid, b_valid} <= 2'b11;

//             timeout = 0;
//             while(!y_valid) begin
//                 if(timeout >= `TIME_MAX) begin
//                     $display("Reached timeout limit. Aborting.");
//                     $fatal();
//                 end

//                 timeout++;
//                 @(posedge clk);
//             end

//             //$write("Y = [\n");
//             for(int row = 0; row < `A_N; row++) begin
//                 //$write("\t");
//                 for(int col = 0; col < `B_M; col++) begin
//                     //$write("%h ", Y[row][col]);
//                 end
//                 //$write("\n");
//             end
//             //$write("    ]\n");

//             // check_output();
//         end

//         @(posedge clk);
//         $finish();
//     end
// endmodule: unary_multiplier_tb



module unary_multiplier_tb(); 
    localparam BIT_WIDTH = 4; 
    localparam DIM = 2; 
    localparam A_ROW = DIM;
    localparam A_COL = DIM;
    localparam B_ROW = DIM; 
    localparam B_COL = DIM; 

    logic clk, reset_n, start, out_valid; 
    logic [A_ROW-1:0][A_COL-1:0][BIT_WIDTH-1:0] A; 
    logic [B_ROW-1:0][B_COL-1:0][BIT_WIDTH-1:0] B;
    logic [B_ROW-1:0][B_COL-1:0][BIT_WIDTH-1:0] Cin;
    // logic [A_ROW-1:0][B_COL-1:0][(BIT_WIDTH<<1)+A_COL-1:0] C;  
    logic [A_ROW-1:0][B_COL-1:0][(BIT_WIDTH<<1)-1:0] C;  
    logic [BIT_WIDTH-1:0] alpha; 
    logic [BIT_WIDTH-1:0] beta; 

    temporal_mxu #(
        .BIT_WIDTH(BIT_WIDTH), 
        .DIM(DIM)
    )  dut (
        .clk(clk), 
        .reset_n(reset_n), 
        .start(start), 
        .A(A), 
        .B(B), 
        .alpha(alpha),
        .beta(beta), 
        .C(Cin), 
        .out_valid(out_valid), 
        .out(C)
    );

    initial begin 
        clk = 0; 
        forever #1 clk = ~clk; 
    end 


    initial begin
        // $monitor($time,, "out_valid: %b", out_valid); 
        // $monitor($time,, "C[0][0]: %d, C[15][15]: %d", C[0][0], C[15][15]); 
        // $monitor($time,, "A[0][0]: %d, A[0][1]: %d, A[1][0]: %d, A[1][1]: %d, B[0][0]: %d, B[0][1]: %d, B[1][0]: %d, B[1][1]: %d, C[0][0]: %d, C[0][1]: %d, C[1][0]: %d, C[1][1]: %d", 
        // A[0][0], A[0][1], A[1][0], A[1][1], B[0][0], B[0][1], B[1][0], B[1][1], C[0][0], C[0][1], C[1][0], C[1][1]);  
                
        // $monitor($time,, {"\n\t\t     int_cur[1][0]: %d, int_cur[1][1]: %d \n\t\t     int_cur[2][0]: %d, int_cur[2][1]: %d\n", 
        //                   "\n\t\t     C[0][0]:       %d, C[0][1]:       %d \n\t\t     C[1][0]:       %d, C[1][1]:       %d"},   
        //                 dut.intermediate_data_cur[1][0], dut.intermediate_data_cur[1][1],
        //                 dut.intermediate_data_cur[2][0], dut.intermediate_data_cur[2][1],
        //                 C[0][0], C[0][1], C[1][0], C[1][1]); 

        $monitor($time,, {"\n\t\t     C[0][0]:       %b, C[0][1]:       %b \n\t\t     C[1][0]:       %b, C[1][1]:       %b", 
                          "\n\t\t     out_valid:  %b"},   
                        C[0][0], C[0][1], C[1][0], C[1][1], out_valid); 

        // $monitor($time,, {"\n\t\t     int_cur[1][0]: %d, int_cur[1][1]: %d", 
        //                   "\n\t\t     int_cur[2][0]: %d, int_cur[2][1]: %d",
        //                   "\n\t\t     int_cur[3][0]: %d, int_cur[3][1]: %d\n",  
        //                   "\n\t\t     C[0][0]:       %d, C[0][1]:       %d", 
        //                   "\n\t\t     C[1][0]:       %d, C[1][1]:       %d"},   
        //                 dut.intermediate_data_cur[1][0], dut.intermediate_data_cur[1][1], 
        //                 dut.intermediate_data_cur[2][0], dut.intermediate_data_cur[2][1], 
        //                 dut.intermediate_data_cur[3][0], dut.intermediate_data_cur[3][1],
        //                 C[0][0], C[0][1], C[1][0], C[1][1]); 

        // $monitor($time,, {"\n\t\t     int_cur[1][0]: %d, int_cur[1][1]: %d, int_cur[1][2]: %d", 
        //                   "\n\t\t     int_cur[2][0]: %d, int_cur[2][1]: %d, int_cur[2][2]: %d",
        //                   "\n\t\t     int_cur[3][0]: %d, int_cur[3][1]: %d, int_cur[3][2]: %d\n",  
        //                   "\n\t\t     C[0][0]:       %d, C[0][1]:       %d, C[0][2]:       %d", 
        //                   "\n\t\t     C[1][0]:       %d, C[1][1]:       %d, C[1][2]:       %d",
        //                   "\n\t\t     C[2][0]:       %d, C[2][1]:       %d, C[2][2]:       %d"},   
        //                 dut.intermediate_data_cur[1][0], dut.intermediate_data_cur[1][1], dut.intermediate_data_cur[1][2],
        //                 dut.intermediate_data_cur[2][0], dut.intermediate_data_cur[2][1], dut.intermediate_data_cur[2][2],
        //                 dut.intermediate_data_cur[3][0], dut.intermediate_data_cur[3][1], dut.intermediate_data_cur[3][2],
        //                 C[0][0], C[0][1], C[0][2], C[1][0], C[1][1], C[1][2], C[2][0], C[2][1], C[2][2]); 
        // $monitor($time,, {"\n\t\t     int_cur[1][0]: %d, int_cur[1][1]: %d, int_cur[1][2]: %d", 
        //                   "\n\t\t     int_cur[2][0]: %d, int_cur[2][1]: %d, int_cur[2][2]: %d",
        //                   "\n\t\t     int_cur[3][0]: %d, int_cur[3][1]: %d, int_cur[3][2]: %d\n",  
        //                   "\n\t\t     C[0][0]:       %b, C[0][1]:       %b, C[0][2]:       %b", 
        //                   "\n\t\t     C[1][0]:       %b, C[1][1]:       %b, C[1][2]:       %b",
        //                   "\n\t\t     C[2][0]:       %b, C[2][1]:       %b, C[2][2]:       %b"},   
        //                 dut.intermediate_data_cur[1][0], dut.intermediate_data_cur[1][1], dut.intermediate_data_cur[1][2],
        //                 dut.intermediate_data_cur[2][0], dut.intermediate_data_cur[2][1], dut.intermediate_data_cur[2][2],
        //                 dut.intermediate_data_cur[3][0], dut.intermediate_data_cur[3][1], dut.intermediate_data_cur[3][2],
        //                 C[0][0], C[0][1], C[0][2], C[1][0], C[1][1], C[1][2], C[2][0], C[2][1], C[2][2]); 
    end 

    initial begin 
        $display("\nStart Testing\n");
        $dumpfile("unary_multiplier.vcd");
        $dumpvars(0, unary_multiplier_tb);
        reset_n = 1'b1; 
        reset_n <= 1'b0; 
        @(posedge clk); 
        reset_n <= 1'b1; 

        // reset(); 

        // for(int row = 0; row < A_ROW; row++) begin
        //     for(int col = 0; col < B_ROW; col++) begin
        //         A[row][col] = 8'b1; 
        //         B[row][col] = 8'b1; 
        //     end 
        // end 
        
        A[0][0] = 4'b0001; 
        A[0][1] = 4'b0001;
        A[1][0] = 4'b0001; 
        A[1][1] = 4'b0001;

        B[0][0] = 4'b0001; 
        B[0][1] = 4'b0001; 
        B[1][0] = 4'b0001;
        B[1][1] = 4'b0001;

        Cin[0][0] = 4'b0001; 
        Cin[0][1] = 4'b0010;
        Cin[1][0] = 4'b0100; 
        Cin[1][1] = 4'b1111;

        alpha = 4'b0010;
        beta = 4'b0001; 

        // A[0][0] = 4'b0001; 
        // A[0][1] = 4'b1111;
        // A[1][0] = 4'b1110; 
        // A[1][1] = 4'b1011;

        // B[0][0] = 4'b1011; 
        // B[0][1] = 4'b0011; 
        // B[1][0] = 4'b0010;
        // B[1][1] = 4'b0111; 

        // A[0][0] = 4'b0010;
        // A[0][1] = 4'b1000;
        // A[1][0] = 4'b1100;
        // A[1][1] = 4'b1110;
        // B[0][0] = 4'b0110;
        // B[0][1] = 4'b1100;
        // B[1][0] = 4'b1100;
        // B[1][1] = 4'b1001;

        // A[0][0] = 2'd1; 
        // A[0][1] = 2'd2; 
        // A[0][2] = 2'd3; 
        // A[1][0] = 2'd3;
        // A[1][1] = 2'd1; 
        // A[1][2] = 2'd2; 

        // B[0][0] = 2'd2; 
        // B[0][1] = 2'd2; 
        // B[1][0] = 2'd1;
        // B[1][1] = 2'd2; 
        // B[2][0] = 2'd3; 
        // B[2][1] = 2'd1; 
        
        // A[0][0] = 2'd1; 
        // A[0][1] = 2'd2; 
        // A[0][2] = 2'd3; 
        // A[1][0] = 2'd3;
        // A[1][1] = 2'd1; 
        // A[1][2] = 2'd2; 
        // A[2][0] = 2'd1; 
        // A[2][1] = 2'd2; 
        // A[2][2] = 2'd3; 


        // B[0][0] = 2'd2; 
        // B[0][1] = 2'd2; 
        // B[0][2] = 2'd3; 
        // B[1][0] = 2'd1;
        // B[1][1] = 2'd2; 
        // B[1][2] = 2'd3; 
        // B[2][0] = 2'd3; 
        // B[2][1] = 2'd1;
        // B[2][2] = 2'd1; 

        // A[0][0] = 4'b1000;  
        // A[0][1] = 4'b1111; 
        // A[0][2] = 4'b1101; 
        // A[1][0] = 4'b0000;
        // A[1][1] = 4'b1000; 
        // A[1][2] = 4'b1111; 
        // A[2][0] = 4'b0100; 
        // A[2][1] = 4'b1011; 
        // A[2][2] = 4'b0010; 


        // B[0][0] = 4'b1101;  
        // B[0][1] = 4'b0010; 
        // B[0][2] = 4'b0100; 
        // B[1][0] = 4'b1010;
        // B[1][1] = 4'b1000; 
        // B[1][2] = 4'b1100; 
        // B[2][0] = 4'b0000; 
        // B[2][1] = 4'b1010; 
        // B[2][2] = 4'b1000; 

        start <= 1'b1; 
        @(posedge clk); 
        start <= 1'b0; 
        
        while (out_valid != 1'b1) begin 
            @(posedge clk); 
        end 

        // $display("C[0][0]: %d, C[15][15]: %d", C[0][0], C[15][15]); 

        $finish; 
    end 



endmodule