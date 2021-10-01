

module multiplier #(
    parameter DIM = 4,
    parameter WIDTH = 4
) (
    input  logic clk,
    input  logic reset_n,
    input  logic [DIM-1:0][DIM-1:0][WIDTH-1:0] in0,
    input  logic [DIM-1:0][DIM-1:0][WIDTH-1:0] in1,
    output logic [DIM-1:0][DIM-1:0][2*WIDTH-1:0] out,
    output logic finished
);

    logic [DIM-1:0][DIM-1:0] and_out;
    logic [DIM-1:0][DIM-1:0] dec;

    logic redo;
    logic [$clog2(DIM+1)-1:0] index;

    logic [DIM-1:0][WIDTH-1:0] in_array_top;
    logic [DIM-1:0] unary_out_top;
    logic [DIM-1:0] neg_top;
    logic done_top;

    logic [DIM-1:0][WIDTH-1:0] in_array_left;
    logic [DIM-1:0] unary_out_left;
    logic [DIM-1:0] neg_left;
    logic done_left;

    assign finished = redo;// && done_left;

    get_index #(.DIM(DIM)) idx(
        .clk(clk),
        .reset_n(reset_n),
        .done(done_left),
        .finished(finished),
        .redo(redo),
        .index(index)
    );

    vector_in #(.DIM(DIM), .WIDTH(WIDTH), .ROW(1)) top_iter(
        .in(in0),
        .redo(redo),
        .index(index),
        .in_array(in_array_top)
    );

    counter_array #(.DIM(DIM), .WIDTH(WIDTH)) top_mat(
        .clk(clk),
        .reset_n(reset_n),
        .in_array(in_array_top),
        .en(1'b1),
        .save(done_left),
        .neg(neg_top),
        .unary_out(unary_out_top),
        .done(done_top)
    );

    vector_in #(.DIM(DIM), .WIDTH(WIDTH), .ROW(0)) left_iter(
        .in(in1),
        .redo(redo),
        .index(index),
        .in_array(in_array_left)
    );

    counter_array #(.DIM(DIM), .WIDTH(WIDTH)) left_mat(
        .clk(clk),
        .reset_n(reset_n),
        .in_array(in_array_left),
        .en(done_top),
        .save(done_left),
        .neg(neg_left),
        .unary_out(unary_out_left),
        .done(done_left)
    );

    genvar i;
    genvar j;
    generate
        for (i=0; i < DIM; i++) begin
            for (j=0; j < DIM; j++) begin

                assign and_out[i][j] = unary_out_top[j] & unary_out_left[i];
                assign dec[i][j] = neg_top[j] ^ neg_left[i];

                always_ff @(posedge clk or negedge reset_n) begin
                    if (~reset_n) begin
                        out[i][j] <= 'b0;
                    end
                    else begin
                        if (dec[i][j]) begin
                            out[i][j] <= out[i][j] - and_out[i][j];
                        end
                        else begin
                            out[i][j] <= out[i][j] + and_out[i][j];
                        end
                    end
                end

            end
        end
    endgenerate

endmodule : multiplier