module multiplier #(
    parameter DIM = 16,
    parameter WIDTH = 4
) (
    input  logic clk,
    input  logic reset_n,
    input  logic [DIM-1:0][DIM-1:0][WIDTH-1:0] in0,
    input  logic [DIM-1:0][DIM-1:0][WIDTH-1:0] in1,
    output logic [DIM-1:0][DIM-1:0][2*WIDTH-1:0] out,
    output logic finished
);

    logic [DIM-1:0][DIM-1:0][DIM-1:0] and_out;
    logic [DIM-1:0][DIM-1:0][DIM-1:0] dec;

    logic [$clog2(DIM+1)-1:0] index;

    logic [DIM-1:0][DIM-1:0][WIDTH-1:0] in_array_top;
    logic [DIM-1:0][DIM-1:0] unary_out_top;
    logic [DIM-1:0][DIM-1:0] neg_top;
    logic [DIM-1:0] done_top;

    logic [DIM-1:0][DIM-1:0][WIDTH-1:0] in_array_left;
    logic [DIM-1:0][DIM-1:0] unary_out_left;
    logic [DIM-1:0][DIM-1:0] neg_left;
    logic [DIM-1:0] done_left;

    logic [31:0] count;

    assign finished = &done_left && |count;

    genvar d;
    generate

        for (d=0; d < DIM; d++) begin

            vector_in #(.DIM(DIM), .WIDTH(WIDTH), .ROW(1)) top_iter(
                .in(in0),
                .index(d[4:0]),
                .in_array(in_array_top[d])
            );

            counter_array #(.DIM(DIM), .WIDTH(WIDTH), .ROW(1)) top_mat(
                .clk(clk),
                .reset_n(reset_n),
                .in_array(in_array_top[d]),
                .en(1'b1),
                .save(done_left[d]),
                .neg(neg_top[d]),
                .unary_out(unary_out_top[d]),
                .done(done_top[d])
            );

            vector_in #(.DIM(DIM), .WIDTH(WIDTH), .ROW(0)) left_iter(
                .in(in1),
                .index(d[4:0]),
                .in_array(in_array_left[d])
            );

            counter_array #(.DIM(DIM), .WIDTH(WIDTH), .ROW(0)) left_mat(
                .clk(clk),
                .reset_n(reset_n),
                .in_array(in_array_left[d]),
                .en(done_top[d]),
                .save(done_left[d]),
                .neg(neg_left[d]),
                .unary_out(unary_out_left[d]),
                .done(done_left[d])
            );

        end
    endgenerate

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            count <= 32'd0;
        end
        else begin
            count <= count + 1;
        end
    end

    genvar i;
    genvar j;
    genvar di;
    generate
        for (i=0; i < DIM; i++) begin
            for (j=0; j < DIM; j++) begin

                for (di=0; di < DIM; di++) begin

                    assign and_out[di][i][j] = unary_out_top[di][j] & unary_out_left[di][i];
                    assign dec[di][i][j] = neg_top[di][j] ^ neg_left[di][i];

                end

                always_ff @(posedge clk or negedge reset_n) begin
                    if (~reset_n) begin
                        out[i][j] <= 'b0;
                    end
                    else begin
                        out[i][j] <= out[i][j] + 
                                     ((dec[0][i][j]) ? -and_out[0][i][j] : and_out[0][i][j]) +
                                     ((dec[1][i][j]) ? -and_out[1][i][j] : and_out[1][i][j]) +
                                     ((dec[2][i][j]) ? -and_out[2][i][j] : and_out[2][i][j]) +
                                     ((dec[3][i][j]) ? -and_out[3][i][j] : and_out[3][i][j]) +
                                     ((dec[4][i][j]) ? -and_out[4][i][j] : and_out[4][i][j]) +
                                     ((dec[5][i][j]) ? -and_out[5][i][j] : and_out[5][i][j]) +
                                     ((dec[6][i][j]) ? -and_out[6][i][j] : and_out[6][i][j]) +
                                     ((dec[7][i][j]) ? -and_out[7][i][j] : and_out[7][i][j]) +
                                     ((dec[8][i][j]) ? -and_out[8][i][j] : and_out[8][i][j]) +
                                     ((dec[9][i][j]) ? -and_out[9][i][j] : and_out[9][i][j]) +
                                     ((dec[10][i][j]) ? -and_out[10][i][j] : and_out[10][i][j]) +
                                     ((dec[11][i][j]) ? -and_out[11][i][j] : and_out[11][i][j]) +
                                     ((dec[12][i][j]) ? -and_out[12][i][j] : and_out[12][i][j]) +
                                     ((dec[13][i][j]) ? -and_out[13][i][j] : and_out[13][i][j]) +
                                     ((dec[14][i][j]) ? -and_out[14][i][j] : and_out[14][i][j]) +
                                     ((dec[15][i][j]) ? -and_out[15][i][j] : and_out[15][i][j]);
                    end
                end

            end
        end
    endgenerate

endmodule : multiplier