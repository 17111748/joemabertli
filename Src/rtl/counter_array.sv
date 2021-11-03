

module counter_array #(
    parameter DIM = 4,
    parameter WIDTH = 8,
    parameter ROW = 1
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

    logic started;

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
                    if (ROW) begin
                        counts[i] <= in_array[i];
                    end
                    else begin
                        if (~started) begin
                            counts[i] <= in_array[i];
                        end
                    end
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

            // if the count is non-zero (or all the bits), output 1
            assign unary_out[i] = |counts[i];

        end
    endgenerate

    generate

        if (~ROW) begin
            always_ff @(posedge clk or negedge reset_n) begin
                if (~reset_n) begin
                    started <= 1'b0;
                end
                else if (done) begin
                    started <= 1'b1;
                end
            end
        end

    endgenerate

endmodule : counter_array