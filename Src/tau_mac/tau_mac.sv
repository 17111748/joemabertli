`default_nettype none

module tau_encoder #(
    parameter BITWIDTH =, 8
)(
    input  logic                  clk,
    input  logic                  reset_n,
    input  logic [BITWIDTH - 1:0] n,
    input  logic                  start,
    output logic [BITWIDTH - 1:0] count_by,
    output logic                  done
);

    logic [$clog2(BITWIDTH):0] count_d, count_q;
    logic [BITWIDTH - 1:0] n_q;

    always_comb begin

        if(start) begin
            count_d = 'b0;
        end

        else begin
            count_d = count_q;
        end

        count_by = 'b0;
        for(count_d = count_q; count_d < BITWIDTH; count_d++) begin
            if(n[BITWIDTH - count_d - 1] == 1'b1) begin
                count_by[BITWIDTH - count_d - 1] = 1'b1;
                count_d++;
                break;
            end
        end

        done = (count_d == BITWIDTH);
    end

    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            count_q <= 'b0;
            n_q     <= 'b0;
        end
        else begin
            count_q <= count_d;
        end
    end

endmodule: tau_encoder

module tau_shift #(
    parameter BITWIDTH = 8,
    parameter OUT_BITS = 2 * BITWIDTH
)(
    input  logic [BITWIDTH - 1:0] count_by,
    input  logic [BITWIDTH - 1:0] b, // binary input 
    output logic [OUT_BITS - 1:0] shifted_b
);

    // TODO: Make this generic
    always_comb begin
        unique case(count_by)
            8'h01: shifted_b = b << 1;
            8'h02: shifted_b = b << 2;
            8'h04: shifted_b = b << 3;
            8'h08: shifted_b = b << 4;
            8'h10: shifted_b = b << 5;
            8'h20: shifted_b = b << 6;
            8'h40: shifted_b = b << 7;
            8'h80: shifted_b = b << 8;
        endcase
    end

endmodule: tau_shift

module tau_mac #(
    parameter BITWIDTH = 8 
)(
    input  logic clk,
    input  logic reset_n,
    input  logic [BITWIDTH - 1:0] a,  // will be converted to unary
    input  logic [BITWIDTH - 1:0] b,  // binary
    input  logic start,
    output logic mac,
    output logic mac_valid
);

    logic [BITWIDTH - 1:0] count_by;
    logic done;
    tau_encoder encoder (
        .clk       (clk),
        .reset_n   (reset_n),
        .start     (start),
        .done      (done),
        .n         (a),
        .count_by  (count_by)
    );

    logic [BITWIDTH - 1:0] shifted_b;
    tau_shift shifter (
        .count_by   (count_by),
        .b          (b),
        .shifted_b  (shifted_b)
    );




endmodule: tau_mac
