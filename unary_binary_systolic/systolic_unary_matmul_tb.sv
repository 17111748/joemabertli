`default_nettype none 

module systolic_unary_matmul_tb(); 
    localparam BIT_WIDTH = 3; 
    localparam A_ROW = 2; 
    localparam A_COL = 2; 
    localparam B_ROW = A_COL; 
    localparam B_COL = 2; 

    logic clk, reset_n, input_valid, output_ready; 
    logic [A_ROW-1:0][A_COL-1:0][BIT_WIDTH-1:0] A; 
    logic [B_ROW-1:0][B_COL-1:0][BIT_WIDTH-1:0] B;
    logic [A_ROW-1:0][B_COL-1:0][(BIT_WIDTH<<1)+A_COL-1:0] C;  

    systolic_unary_matmul #(.BIT_WIDTH(BIT_WIDTH), .A_ROW(A_ROW), .A_COL(A_COL), .B_ROW(B_ROW), .B_COL(B_COL)) 
                          dut(.clk(clk), .reset_n(reset_n), .input_valid(input_valid), .A(A), .B(B), .output_ready(output_ready), 
                          .C(C));

    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end 

    task reset(); 
        reset_n = 1'b1; 
        reset_n <= 1'b0; 
        @(posedge clk); 
        reset_n <= 1'b1; 
    endtask 

    initial begin
        // $monitor($time,, "A[0][0]: %d, A[0][1]: %d, A[1][0]: %d, A[1][1]: %d, B[0][0]: %d, B[0][1]: %d, B[1][0]: %d, B[1][1]: %d, C[0][0]: %d, C[0][1]: %d, C[1][0]: %d, C[1][1]: %d", 
        // A[0][0], A[0][1], A[1][0], A[1][1], B[0][0], B[0][1], B[1][0], B[1][1], C[0][0], C[0][1], C[1][0], C[1][1]);  
                
        // $monitor($time,, {"\n\t\t     int_cur[1][0]: %d, int_cur[1][1]: %d \n\t\t     int_cur[2][0]: %d, int_cur[2][1]: %d\n", 
        //                   "\n\t\t     C[0][0]:       %d, C[0][1]:       %d \n\t\t     C[1][0]:       %d, C[1][1]:       %d"},   
        //                 dut.intermediate_data_cur[1][0], dut.intermediate_data_cur[1][1],
        //                 dut.intermediate_data_cur[2][0], dut.intermediate_data_cur[2][1],
        //                 C[0][0], C[0][1], C[1][0], C[1][1]); 

        $monitor($time,, {"\n\t\t     int_cur[1][0]: %b, int_cur[1][1]: %b \n\t\t     int_cur[2][0]: %b, int_cur[2][1]: %b\n", 
                          "\n\t\t     C[0][0]:       %b, C[0][1]:       %b \n\t\t     C[1][0]:       %b, C[1][1]:       %b", 
                          "\n\t\t     output_ready:  %b"},   
                        dut.intermediate_data_cur[1][0], dut.intermediate_data_cur[1][1],
                        dut.intermediate_data_cur[2][0], dut.intermediate_data_cur[2][1],
                        C[0][0], C[0][1], C[1][0], C[1][1], output_ready); 

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
    end 

    initial begin 
        $display("\nStart Testing\n"); 
        reset(); 
        
        // A[0][0] = 2'd1; 
        // A[0][1] = 2'd2; 
        // A[1][0] = 2'd3; 
        // A[1][1] = 2'd0;

        // B[0][0] = 2'd2; 
        // B[0][1] = 2'd2; 
        // B[1][0] = 2'd0;
        // B[1][1] = 2'd2; 

        A[0][0] = 3'b110; 
        A[0][1] = 3'b111;
        A[1][0] = 3'b101; 
        A[1][1] = 3'b000;

        B[0][0] = 3'b001; 
        B[0][1] = 3'b111; 
        B[1][0] = 3'b010;
        B[1][1] = 3'b011; 

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

        input_valid <= 1'b1; 
        @(posedge clk); 
        input_valid <= 1'b0; 
        
        for(int i = 0; i < 100; i+=1) begin 
            @(posedge clk); 
        end 

        // while(output_ready != 1'b1)
        //     @(posedge clk); 
        

        $finish; 
    end 



endmodule