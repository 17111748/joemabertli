module count_in_tb;

    parameter DIM = 8;
    parameter WIDTH = 8;

    logic clk;
    logic reset_n;

    logic [DIM-1:0][DIM-1:0][WIDTH-1:0] in;
    logic [DIM-1:0][WIDTH-1:0] in_array;
    logic [DIM-1:0] unary_out;
    logic [DIM-1:0] neg;
    logic done;
    logic redo;
    logic [$clog2(DIM+1)-1:0] index;
    logic finished;

    assign finished = redo && done;

    vector_in #(.DIM(DIM), .WIDTH(WIDTH), .ROW(1)) counter_ins(
        .clk(clk),
        .reset_n(reset_n),
        .in(in),
        .done(done),
        .finished(finished),
        .redo(redo),
        .in_array(in_array),
        .index(index)
    );

    counter_array #(.DIM(DIM), .WIDTH(WIDTH)) top_mat(
        .clk(clk),
        .reset_n(reset_n),
        .in_array(in_array),
        .en(1'b1),
        .neg(neg),
        .unary_out(unary_out),
        .done(done)
    );

    class mat;
        rand  bit [DIM-1:0][DIM-1:0][WIDTH-1:0] matrix;
    endclass

	mat ports;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    int count;
    initial begin
        ports = new();
        ports.randomize();

        in = ports.matrix;

        reset_n = 1;
        #1 reset_n = 0;
        #1 reset_n = 1;
        @(posedge clk);


        count = 0;
        while (!finished) begin
            @(posedge clk);
            count++;
        end

        $finish;
    end

endmodule : count_in_tb