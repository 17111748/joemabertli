`default_nettype none
`include "tb_define.vh"

module mxu_tb ();
    typedef logic [`DIM - 1:0][`DIM - 1:0][`BITWIDTH - 1:0] matrix_a_t;
    typedef logic [`DIM - 1:0][`DIM - 1:0][`BITWIDTH - 1:0] matrix_b_t;
    typedef logic [`DIM - 1:0][`DIM - 1:0][`OUT_BITWIDTH - 1:0] matrix_y_t;

    typedef logic [`BITWIDTH - 1:0] matrix_mem_t [`MAX_TRACES * (`DIM*`DIM + `DIM*`DIM) - 1:0];

    matrix_a_t matrix_a_queue [$];
    matrix_b_t matrix_b_queue [$];
    matrix_y_t matrix_y_queue [$];

    longint timeout;

    matrix_y_t Y_write;

    /* DUT ports */
    logic clk;
    logic reset_n;
    logic in_valid;

    matrix_a_t A_in;
    matrix_b_t B_in;
    matrix_y_t Y;

    logic y_valid;

    multiplier #(
        .DIM    (`DIM),
        .WIDTH  (`BITWIDTH)
    ) dut (
        .clk       (clk),
        .reset_n   (reset_n),
        .in0       (A_in),
        .in1       (B_in),
        .out       (Y),
        .finished  (y_valid)
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

    function void parse_trace();
        int    trace_file_desc; // file descriptor
        string trace_filename;
        int    num_read;

        int    rows, cols;
        string matrix_str;
        string format_str;

        int count;

        matrix_a_t A;
        matrix_b_t B;

        matrix_mem_t matrix_mem;
        int num_traces;

        if(!$value$plusargs("NUM_TRACES=%d", num_traces)) begin
            $display("Need to specify number of traces. Use +NUM_TRACES=<X>");
            $fatal();
        end

        if(num_traces > `MAX_TRACES) begin
            $display("Exceeding the maximum amount of traces: %0d", 
                `MAX_TRACES);
            $fatal();
        end

        if(!$value$plusargs("TRACE=%s", trace_filename)) begin
            $display("No trace file specified. Use +TRACE=<trace filename>");
            $fatal();
        end

        $readmemb(trace_filename, matrix_mem);

        for(int n = 0; n < num_traces; n++) begin
            count = 0;
            for(int r = 0; r < `DIM; r++) begin
                for(int c = 0; c < `DIM; c++) begin
                    A[r][c] = matrix_mem[n * (`DIM*`DIM + `DIM*`DIM) + count];
                    count++;
                end
            end

            for(int r = 0; r < `DIM; r++) begin
                for(int c = 0; c < `DIM; c++) begin
                    B[r][c] = matrix_mem[n * (`DIM*`DIM + `DIM*`DIM) + count];
                    count++;
                end
            end

            matrix_a_queue.push_back(A);
            matrix_b_queue.push_back(B);
        end

    endfunction

    function void write_output();
        int fd;

        fd = $fopen("mxu_tb_out.log", "w");

        while(matrix_y_queue.size() > 0) begin
            Y_write = matrix_y_queue.pop_front();

            for(int r = 0; r < `DIM; r++) begin
                for(int c = 0; c < `DIM; c++) begin
                    $fdisplay(fd, "%b", Y_write[r][c]);
                end
            end
        end

        $fclose(fd);

    endfunction

    initial begin
        $dumpfile("mxu.vcd");
        $dumpvars(0, mxu_tb);

        reset();
        parse_trace();

        while(matrix_a_queue.size() > 0) begin

            /* Pass inputs */
            A_in     <= matrix_a_queue.pop_front();
            B_in     <= matrix_b_queue.pop_front();
            in_valid <= 1'b1;
            @(posedge clk);
            in_valid <= 1'b0;

            /* Wait for outputs */
            timeout = 0;
            while(!y_valid) begin

                `ifdef `TIME_MAX
                if(timeout >= `TIME_MAX) begin
                    $display("Timeout at time %0d. Aborting...", $time);
                    $finish();
                end
                `endif // TIME_MAX

                timeout++;
                @(posedge clk);
            end

            matrix_y_queue.push_back(Y);
        end

        write_output();

        @(posedge clk);
        $finish();
    end
endmodule: mxu_tb
