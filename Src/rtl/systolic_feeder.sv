`default_nettype none

module systolic_feeder #(
    parameter DIM      = 8,
    parameter UWIDTH   = 2,
    parameter BWIDTH   = 4
)(
    input  logic                           clk,
    input  logic                           reset_n,
    input  logic [DIM - 1:0][BWIDTH - 1:0] row_in,
    input  logic                           start,
    output logic [DIM - 1:0][UWIDTH - 1:0] syst_arr_in,
    output logic                           done
);

    logic [$clog2(DIM) - 1:0] curr_col_d;
    logic [$clog2(DIM) - 1:0] curr_col_q;
    logic [BWIDTH - 1:0] curr_bin_input_d; 
    logic [BWIDTH - 1:0] curr_bin_input_q; 
    logic [UWIDTH - 1:0] next_u_input;

    /* Unary input generation */
    always_comb begin
        curr_bin_input_d = row_in[
        
    end


    logic [DIM - 1:0][UWIDTH - 1:0] syst_arr_in_d;
    logic [DIM - 1:0][UWIDTH - 1:0] syst_arr_in_q;

    assign syst_arr_in = syst_arr_in_q;

    /* Column iterator */
    always_comb begin
        curr_col_d = curr_col_q;

        if(start) begin
            curr_col_d = 'b0;
        end

        else if(curr_col_q < DIM) begin
            curr_col_d = curr_col_q + 'b1;
        end
    end

    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            curr_col_q    <= 'b0;
            syst_arr_in_q <= 'b0;
        end

        else begin
            curr_col_q    <= curr_col_d;
            syst_arr_in_q <= syst_arr_in_d;
        end
    end
    
    

endmodule: systolic_feeder
