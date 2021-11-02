module get_index #(
    parameter DIM = 4
) (
    input  logic clk,
    input  logic reset_n,
    input  logic done,
    input  logic finished,
    output logic redo,
    output logic [$clog2(DIM+1)-1:0] index
);

    assign redo = (index == DIM) && done;

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            index <= 'b0;
        end
        else if (finished) begin
            index <= 'b0;
        end
        else if (redo) begin
            index <= index;
        end
        else if (done) begin
            index <= index + 1;
        end
    end

endmodule : get_index

module vector_in #(
    parameter DIM = 4,
    parameter WIDTH = 8,
    parameter ROW = 1
) (
    input  logic [DIM-1:0][DIM-1:0][WIDTH-1:0] in,
    input  logic redo,
    input  logic [$clog2(DIM+1)-1:0] index,
    output logic [DIM-1:0][WIDTH-1:0] in_array
);

    genvar i;
    generate
        if (ROW) begin
            // TODO could be in_array = in[index]
            for (i=0; i < DIM; i++) begin
                assign in_array[i] = (index == DIM) ? 'b0 : in[index][i];
            end
        end
        else begin
            for (i=0; i < DIM; i++) begin
                assign in_array[i] = (index == DIM) ? 'b0 : in[i][index];
            end
        end
    endgenerate

endmodule : vector_in
