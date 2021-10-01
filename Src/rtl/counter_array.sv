

module counter_array #(
    parameter DIM = 4,
    parameter WIDTH = 8
) (
    input  logic clk,
    input  logic reset_n,
    input  logic [DIM-1:0][WIDTH-1:0] in_array,
    input  logic en,
    input  logic save,
    output logic [DIM-1:0] neg,
    output logic [DIM-1:0] unary_out,
    output logic done
);

    logic [DIM-1:0][WIDTH-1:0] counts;
    logic [DIM-1:0][WIDTH-1:0] prev_arr;

    // TODO consider doing ~|counts
    assign done = (counts == 0);

    genvar i;
    generate
        for (i=0; i < DIM; i++) begin

            assign neg[i] = counts[i][WIDTH-1];

            always_ff @(posedge clk or negedge reset_n) begin
                if (~reset_n) begin
                    prev_arr[i] <= 'b0;
                end
                else if (save) begin
                    prev_arr[i] <= in_array[i];
                end
            end

            always_ff @(posedge clk or negedge reset_n) begin
                if (~reset_n) begin
                    counts[i] <= 'b0;
                end
                else if (save) begin
                    counts[i] <= in_array[i];
                end
                else if (done) begin
                    counts[i] <= prev_arr[i];
                end
                else if (en && |counts[i]) begin
                    if (neg[i]) begin
                        counts[i] <= counts[i] + 1;
                    end
                    else begin
                        counts[i] <= counts[i] - 1;
                    end
                end
            end

            // counter_to_0 #(.WIDTH(WIDTH)) count0(
            //     .clk(clk),
            //     .reset_n(reset_n),
            //     .x(in_array[i]),
            //     .load_x(done),
            //     .en(en),
            //     .y(counts[i])
            // );

            // if the count is non-zero (or all the bits), output 1
            assign unary_out[i] = |counts[i];

        end
    endgenerate

endmodule : counter_array