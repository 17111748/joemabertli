`default_nettype none

module unary_block_gen #(
    parameter UWIDTH = 2,
    parameter BWIDTH = 4
)(
    input  logic                clk,
    input  logic                reset_n,
    input  logic [BWIDTH - 1:0] bin_in,
    input  logic                bin_in_valid,
    output logic [UWIDTH - 1:0] u_out,
    output logic                done
);

    always_comb begin
        if(bin_in_valid) begin
            bin_in_d = bin_in;
        end

        else begin
            bin_in_d = bin_in 
    end

    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            bin_q <= 'b0;
        end
        else begin
            bin_q <= bin_d;
        end
    end
    

endmodule: unary_block_gen
