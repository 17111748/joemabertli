`default_nettype none
`timescale 1ns/10ps

module row_mac
    #(parameter DIM = 4,
      parameter DIM_BITS = $clog2(DIM),
      parameter BIT_WIDTH = 4,
      parameter OUT_BIT_WIDTH = 2 * BIT_WIDTH)
    (input  logic clk,
     input  logic reset_n,
     input  logic [DIM-1:0][BIT_WIDTH-1:0] A_row,
     input  logic [DIM-1:0][DIM-1:0][BIT_WIDTH-1:0] B_trans,
     input  logic start,
     output logic [DIM-1:0][OUT_BIT_WIDTH-1:0] out_row,
     output logic done);

    logic col_en, col_cl;
    logic [DIM_BITS-1:0] B_col;

    logic next_col;
    logic value_rdy;
    logic [OUT_BIT_WIDTH-1:0] mac_out; // TODO: I think the MAC outputs a diff # bits tho
    logic last_col;

    Counter #(DIM_BITS) col(.clk(clk),
                            .en(col_en),
                            .clear(col_cl),
                            .Q(B_col));

    unary_binary_MAC #(.SIZE(BIT_WIDTH), .SETS(DIM)) mac(.clk(clk),
                                                         .reset_n(reset_n),
                                                         .valid(next_col),
                                                         .a(A_row),
                                                         .b(B_trans[B_col]),
                                                         .ready(value_rdy),
                                                         .out(mac_out));

    // Store resulting values in registers
    genvar i;
    generate
        for (i = 0; i < DIM; i++) begin
            always_ff @(posedge clk) begin
                if (value_rdy && (B_col == i))
                    out_row[i] <= mac_out;
                else
                    out_row[i] <= out_row[i];
            end
        end
    endgenerate

    enum logic [1:0] {INIT, COMP, NEXT, DONE} curr_state, next_state;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) curr_state <= INIT;
        else          curr_state <= next_state;
    end

    assign last_col = (B_col == (DIM - 1)); // TODO: or is it B_col == DIM?

    always_comb begin
        col_en   = 1'b0;
        col_cl   = 1'b0;
        next_col = 1'b0;
        done     = 1'b0;
        case (curr_state)
            INIT: begin
                  if (start) begin
                      next_col = 1'b1;
                      col_en   = 1'b1;
                      next_state = COMP;
                  end
                  else next_state = INIT;
            end
            COMP: begin
                  if (value_rdy) begin
                      col_en    = 1'b1;
                      next_state = NEXT;
                  end
                  else next_state = COMP;
            end
            NEXT: begin
                  if (last_col) begin
                      done = 1'b1;
                      next_state = DONE;
                  end
                  else begin
                      next_col = 1'b1;
                      next_state = COMP;
                  end
            end
            DONE: begin
                  if (start) begin
                      next_col = 1'b1;
                      col_en   = 1'b1;
                      next_state = COMP;
                  end
                  else begin // Keep done high so top module knows when all MACs are finished
                      done = 1'b1;
                      next_state = DONE;
                  end
            end
        endcase
    end

endmodule: row_mac

module temporal_mxu
    #(parameter DIM = 4,
      parameter DIM_BITS = $clog2(DIM),
      parameter BIT_WIDTH = 4,
      parameter OUT_BIT_WIDTH = 2 * BIT_WIDTH)
    (input  logic clk,
     input  logic reset_n,
     input  logic [DIM-1:0][DIM-1:0][BIT_WIDTH-1:0] A,
     input  logic [DIM-1:0][DIM-1:0][BIT_WIDTH-1:0] B,
     input  logic start,
     output logic [DIM-1:0][DIM-1:0][OUT_BIT_WIDTH-1:0] out,
     output logic out_valid);

    logic [DIM-1:0] done; // One done signal for each row_mac
    logic [DIM-1:0][OUT_BIT_WIDTH-1:0] mac_out;
    logic [DIM-1:0][DIM-1:0][BIT_WIDTH-1:0] B_trans; // Transposed B matrix

    genvar i, j;
    generate
        for (i = 0; i < DIM; i++) begin: transpose
            for (j = 0; j < DIM; j++) begin
                assign B_trans[i][j] = B[j][i];
            end
        end: transpose
    endgenerate

    genvar k;
    generate
        for (k = 0; k < DIM; k++) begin: MACs
            row_mac #(.DIM(DIM), .DIM_BITS(DIM_BITS), .BIT_WIDTH(BIT_WIDTH), .OUT_BIT_WIDTH(OUT_BIT_WIDTH))
                    row(.clk(clk),
                        .reset_n(reset_n),
                        .A_row(A[k]),
                        .B_trans(B_trans),
                        .start(start),
                        .out_row(mac_out[k]),
                        .done(done[k]));

            // Store results in registers
            always_ff @(posedge clk) begin
                if (done[k])
                    out[k] <= mac_out[k];
                else
                    out[k] <= out[k];
            end
        end: MACs
    endgenerate

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            out_valid <= 1'b0;
        end
        else if (~done == (DIM)'('b0)) begin
            out_valid <= 1'b1;
        end
    end

endmodule: temporal_mxu
