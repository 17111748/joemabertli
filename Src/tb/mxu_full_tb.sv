`include "tb_define.vh"
`default_nettype none

module mxu_full_tb ();

    class rand_matrix #(
        parameter N = 8,
        parameter M = 8,
        parameter WIDTH = 8
    );
        rand bit [N - 1:0][M - 1:0][WIDTH - 1:0] matrix;

        function logic [N - 1:0][M - 1:0][WIDTH - 1:0] gen_matrix();
            gen_matrix = matrix;
        endfunction
    endclass

    logic clk;
    logic reset_n;

    logic [`A_N - 1:0][`A_M - 1:0][`BITWIDTH - 1:0] A;
    logic [`B_N - 1:0][`B_M - 1:0][`BITWIDTH - 1:0] B;
    logic [`A_N - 1:0][`B_M - 1:0][2*`BITWIDTH - 1:0] Y;

    logic a_valid;
    logic b_valid;
    logic y_valid;

    int     i;
    longint timeout;

    rand_matrix #(.N(`A_N), .M(`A_M), .WIDTH(`BITWIDTH)) A_rand;
    rand_matrix #(.N(`B_N), .M(`B_M), .WIDTH(`BITWIDTH)) B_rand;

    multiplier #(.DIM(`A_N), .WIDTH(`BITWIDTH)) dut(
        .clk(clk),
        .reset_n(reset_n),
        .in0(B),
        .in1(A),
        .out(Y),
        .finished(y_valid)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task reset();
        reset_n  = 1'b1;
        reset_n <= 1'b0;
        @(posedge clk);
        reset_n <= 1'b1;
    endtask

    function logic [`A_N - 1:0][`B_M - 1:0][2*`BITWIDTH - 1:0] matrix_multiply();
        /* Initialize to 0 */
        for(int row = 0; row < `A_N; row++) begin
            for(int col = 0; col < `B_M; col++) begin
                matrix_multiply[row][col] = 0;
            end
        end

        /* Compute the matrix multiply */
        for(int row = 0; row < `A_N; row++) begin
            for(int col = 0; col < `B_M; col++) begin
                for(int x = 0; x < `A_M; x++) begin
                    if (A[row][x][`BITWIDTH - 1] ^ B[x][col][`BITWIDTH - 1]) begin
                        matrix_multiply[row][col] -= A[row][x] * B[x][col];
                    end
                    else begin
                        matrix_multiply[row][col] += A[row][x] * B[x][col];
                    end
                end
            end
        end
    endfunction

    task check_output();
        logic [`A_N - 1:0][`B_M - 1:0][2*`BITWIDTH - 1:0] correct;
        correct = matrix_multiply();

        for(int row = 0; row < `A_N; row++) begin
            for(int col = 0; col < `B_M; col++) begin
                if(correct[row][col] != Y[row][col]) begin
                    $display("Failed test for (row, col) = (%d, %d). Got %h, expected %h.",
                        row, col, Y[row][col], correct[row][col]);

                    `ifdef FAIL_ON_ERROR
                        $error();
                    `endif

                end
            end
        end
    endtask

    initial begin
        $dumpfile("parallel_counter.vcd");
        $dumpvars(0, mxu_full_tb);

        reset();

        for(i = 0; i < `TEST_CASES; i++) begin
            A_rand = new();
            B_rand = new();

            if(!A_rand.randomize()) $error("random gen error");
            if(!B_rand.randomize()) $error("random gen error");

            // A                  <= A_rand.gen_matrix();
            // B                  <= B_rand.gen_matrix();
            A = A_rand.matrix;
            B = B_rand.matrix;

            $write("A = [\n");
            for(int row = 0; row < `A_N; row++) begin
                $write("\t");
                for(int col = 0; col < `B_M; col++) begin
                    $write("%h ", A[row][col]);
                end
                $write("\n");
            end
            $write("    ]\n");

            $write("B = [\n");
            for(int row = 0; row < `A_N; row++) begin
                $write("\t");
                for(int col = 0; col < `B_M; col++) begin
                    $write("%h ", B[row][col]);
                end
                $write("\n");
            end
            $write("    ]\n");

            {a_valid, b_valid} <= 2'b11;

            timeout = 0;
            while(!y_valid) begin
                if(timeout >= `TIME_MAX) begin
                    $display("Reached timeout limit. Aborting.");
                    $fatal();
                end

                timeout++;
                @(posedge clk);
            end

            $write("Y = [\n");
            for(int row = 0; row < `A_N; row++) begin
                $write("\t");
                for(int col = 0; col < `B_M; col++) begin
                    $write("%h ", Y[row][col]);
                end
                $write("\n");
            end
            $write("    ]\n");

            // check_output();
        end

        @(posedge clk);
        $finish();
    end
endmodule: mxu_full_tb