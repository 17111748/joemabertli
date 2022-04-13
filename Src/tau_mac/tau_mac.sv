`default_nettype none

/*
 * tau_encoder
 * __________________
 *
 * Encodes a binary number into our "tau" encoding. For example, if the
 * binary value 1011 is passed as input, the encoder will output the
 * following:
 *
 *      1000
 *      0010
 *      0001
 *
 * It's assumed that the input n does not change between the start and end
 * signals.
 *
 * Parameters:
 *   - BITWIDTH (8)
 *
 * Inputs:
 *   - n					      The binary input.
 *   - start					  Signifies that n is valid and the encoder
 *                                should start producing its output. Should
 *                                only stay high for one cycle.
 *
 * Outputs:
 * 	 - count_by 				  The one-hot encoder output.
 * 	 - count_by_valid 	     	  Valid signal for count_by.
 */
module tau_encoder #(
    parameter BITWIDTH = 8
)(
    input  logic                  clk,
    input  logic                  reset_n,
    input  logic [BITWIDTH - 1:0] n,
    input  logic                  start,
    output logic [BITWIDTH - 1:0] count_by,
    output logic                  count_by_valid
);

    logic [$clog2(BITWIDTH):0] count_d, count_q;

    always_comb begin
        if(start) begin
            count_d = 'b0;
        end

        else begin
            count_d = count_q;
        end

        count_by = 'b0;
        for(; count_d < BITWIDTH; count_d++) begin
            if(n[BITWIDTH - count_d - 1] == 1'b1) begin
                count_by[BITWIDTH - count_d - 1] = 1'b1;
                break;
            end
        end

        count_by_valid = (count_d < BITWIDTH);
    end

    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            count_q <= 'b0;
        end
        else begin
            count_q <= count_d + 1;
        end
    end
endmodule: tau_encoder

/*
 * tau_shift
 * __________________
 *
 * Shifts the binary input b according to the encoded unary value, count_by.
 * count_by is expected to be one-hot and is treated as a tau-encoded unary
 * value.
 *
 * Parameters:
 *   - BITWIDTH (8)    			  TODO: This is currently fixed at 8
 *   - OUT_BITS (2 * BITWIDTH)    (fixed)
 *
 * Inputs:
 *   - count_by					  One-hot tau-encoded unary value to shift by.
 *   - b    					  A binary integer to be shifted.
 *
 * Outputs:
 * 	 - shifted_b 				  The shifted version of b. Has twice the bits.
 */
module tau_shift #(
    parameter BITWIDTH = 8,
    parameter OUT_BITS = 2 * BITWIDTH
)(
    input  logic [BITWIDTH - 1:0] count_by,
    input  logic [BITWIDTH - 1:0] b, // binary input
    output logic [OUT_BITS - 1:0] shifted_b
);

    logic [OUT_BITS - 1:0] b_padded;
    assign b_padded = {(OUT_BITS - BITWIDTH)'(1'b0), b};

    always_comb begin
        unique case(count_by)
            8'h01: shifted_b = b_padded << 'd0;
            8'h02: shifted_b = b_padded << 'd1;
            8'h04: shifted_b = b_padded << 'd2;
            8'h08: shifted_b = b_padded << 'd3;
            8'h10: shifted_b = b_padded << 'd4;
            8'h20: shifted_b = b_padded << 'd5;
            8'h40: shifted_b = b_padded << 'd6;
            8'h80: shifted_b = b_padded << 'd7;
            8'h00: shifted_b = 'b0; // reset case, should never happen 
        endcase
    end
endmodule: tau_shift

/*
 * tau_mac
 * __________________
 *
 * Performs serial multiply-accumulate using our tau-encoded scheme. Each
 * cycle, a and b are provided, which are multiplied together and accumulated
 * in an internal register.
 *
 * Parameters:
 *   - BITWIDTH  (8)   			  TODO: This is currently fixed at 8.
 *   - OUT_WIDTH (2 * BITWIDTH)   (fixed)
 *
 * Inputs:
 *   - a					      Operand 1, binary. Will be converted to
 *                                tau-unary.
 *   - b					      Operand 2, binary. Will remain binary.
 *   - start                      Signifies that both a and b are valid.
 *
 * Outputs:
 * 	 - mac 				          The output of the MAC.
 * 	 - mac_valid 				  Valid signal for the output.
 */
module tau_mac #(
    parameter BITWIDTH  = 8,
    parameter OUT_WIDTH = 2 * BITWIDTH
)(
    input  logic clk,
    input  logic reset_n,
    input  logic [BITWIDTH - 1:0] a,
    input  logic [BITWIDTH - 1:0] b,
    input  logic start,
    output logic [OUT_WIDTH - 1:0] mac,
    output logic mac_valid
);

    logic [OUT_WIDTH - 1:0] acc_q, acc_d; // the accumulate register

    logic [BITWIDTH - 1:0] count_by;
    logic computing;
    tau_encoder encoder (
        .clk             (clk),
        .reset_n         (reset_n),
        .start           (start),
        .n               (a),
        .count_by        (count_by),
        .count_by_valid  (computing)
    );

    logic [OUT_WIDTH - 1:0] shifted_b;
    tau_shift shifter (
        .count_by   (count_by),
        .b          (b),
        .shifted_b  (shifted_b)
    );

    assign acc_d = (computing) ? acc_q + shifted_b : acc_q;

    assign mac = acc_q;
    assign mac_valid = ~computing;

    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            acc_q <= 'b0;
        end
        else begin
            acc_q <= acc_d;
        end
    end
endmodule: tau_mac
