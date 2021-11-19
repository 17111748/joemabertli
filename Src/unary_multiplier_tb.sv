// `timescale 1ns/1ps


module unary_multiplier_tb();
    localparam BIT_WIDTH = 8;
    localparam DIM = 16;
    localparam A_ROW = DIM;
    localparam A_COL = DIM;
    localparam B_ROW = DIM;
    localparam B_COL = DIM;

    logic clk, reset_n, start, out_valid;
    logic [BIT_WIDTH-1:0] alpha;
    logic [A_ROW-1:0][A_COL-1:0][BIT_WIDTH-1:0] A;
    logic [B_ROW-1:0][B_COL-1:0][BIT_WIDTH-1:0] B;
    // logic [A_ROW-1:0][B_COL-1:0][(BIT_WIDTH<<1)+A_COL-1:0] C;
    logic [A_ROW-1:0][B_COL-1:0][(BIT_WIDTH<<1)-1:0] C;

    temporal_mxu #(
        .BIT_WIDTH(BIT_WIDTH),
        .DIM(DIM)
    )  dut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .alpha(alpha),
        .A(A),
        .B(B),
        .out_valid(out_valid),
        .out(C)
    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end


    initial begin
        //$monitor($time,, "out_valid: %b", out_valid);
        // $monitor($time,, "C[0][0]: %d, C[15][15]: %d", C[0][0], C[15][15]);
        $monitor($time,, {"out_valid: %b \n\t\t     ",
                          "alpha: %d \n\t\t     ",
                          "counter_alpha_out: %d \n\t\t     ",
                          "counter_en: %d \n\t\t     ",
                          "counter_alpha_clear: %d \n\t\t     ",
                          //"A[0][0]: %d, A[0][1]: %d, A[1][0]: %d, A[1][1]: %d, \n\t\t     ",
                          //"B[0][0]: %d, B[0][1]: %d, B[1][0]: %d, B[1][1]: %d, \n\t\t     ",
                          "C[0][0]: %b, C[0][1]: %b, C[1][0]: %b, C[1][1]: %b"},
        out_valid, alpha,  dut.counter_alpha_out, dut.counter_en, dut.counter_alpha_clear,
        //A[0][0], A[0][1], A[1][0], A[1][1], B[0][0], B[0][1], B[1][0], B[1][1],
        C[0][0], C[0][1], C[1][0], C[1][1]);

        // $monitor($time,, {"\n\t\t     int_cur[1][0]: %d, int_cur[1][1]: %d \n\t\t     int_cur[2][0]: %d, int_cur[2][1]: %d\n",
        //                   "\n\t\t     C[0][0]:       %d, C[0][1]:       %d \n\t\t     C[1][0]:       %d, C[1][1]:       %d"},
        //                 dut.intermediate_data_cur[1][0], dut.intermediate_data_cur[1][1],
        //                 dut.intermediate_data_cur[2][0], dut.intermediate_data_cur[2][1],
        //                 C[0][0], C[0][1], C[1][0], C[1][1]);

        // $monitor($time,, {"\n\t\t     C[0][0]:       %b, C[0][1]:       %b \n\t\t     C[1][0]:       %b, C[1][1]:       %b",
        //                   "\n\t\t     out_valid:  %b"},
        //                 C[0][0], C[0][1], C[1][0], C[1][1], out_valid);

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
        reset_n = 1'b1;
        reset_n <= 1'b0;
        @(posedge clk);
        reset_n <= 1'b1;

        // reset();

        alpha = 4'd3;

        for(int row = 0; row < A_ROW; row++) begin
            for(int col = 0; col < B_ROW; col++) begin
                A[row][col] = 4'b1;
                B[row][col] = 4'b1;
            end
        end

        // A[0][0] = 2'd1;
        // A[0][1] = 2'd2;
        // A[1][0] = 2'd3;
        // A[1][1] = 2'd0;

        // B[0][0] = 2'd2;
        // B[0][1] = 2'd2;
        // B[1][0] = 2'd0;
        // B[1][1] = 2'd2;

        // A[0][0] = 4'b1000;
        // A[0][1] = 4'b1000;
        // A[1][0] = 4'b1000;
        // A[1][1] = 4'b1000;

        // B[0][0] = 4'b1000;
        // B[0][1] = 4'b1000;
        // B[1][0] = 4'b1000;
        // B[1][1] = 4'b1000;

        // A[0][0] = 4'b0001;
        // A[0][1] = 4'b0001;
        // A[1][0] = 4'b0001;
        // A[1][1] = 4'b0001;

        // B[0][0] = 4'b0001;
        // B[0][1] = 4'b0001;
        // B[1][0] = 4'b0001;
        // B[1][1] = 4'b0001;

        // start <= 1'b1;
        // @(posedge clk);
        // start <= 1'b0;

        // while (out_valid != 1'b1) begin
        //     @(posedge clk);
        // end

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
        @(posedge clk);
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
