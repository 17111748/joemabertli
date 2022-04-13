`default_nettype none

module multiplier #(
    parameter DIM      = 16,
    parameter BITWIDTH = 8,
    parameter OUT_BITS = 2 * BITWIDTH
)(
    input  logic                                        clk,
    input  logic                                        reset_n,
    input  logic [DIM - 1:0][DIM - 1:0][BITWIDTH - 1:0] in0,
    input  logic [DIM - 1:0][DIM - 1:0][BITWIDTH - 1:0] in1,
    input  logic                                        in_valid,
    output logic [DIM - 1:0][DIM - 1:0][OUT_BITS - 1:0] out,
    output logic                                        finished
);

    logic [DIM - 1:0][BITWIDTH - 1:0] active_in0;
    logic [DIM - 1:0][BITWIDTH - 1:0] active_in1;
    logic [DIM - 1:0][DIM - 1:0]      mac_valid;
    logic                             start;

    /* Array of MACs */
    generate
    for(genvar i = 0; i < DIM; i++) begin
        for(genvar j = 0; j < DIM; j++) begin
            tau_mac mac (
                .clk        (clk),
                .reset_n    (reset_n),
                .a          (active_in0[i]),
                .b          (active_in1[j]),
                .start      (start),
                .mac        (out[i][j]),
                .mac_valid  (mac_valid[i][j])
            );
        end
    end
    endgenerate

    logic [$clog2(BITWIDTH):0] cycle_counter_d, cycle_counter_q;
    always_comb begin

        
    end

    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            cycle_counter_q <= 'b0;
            active_in0 <= 'b0;
            active_in1 <= 'b0;
        end

        else if(in_valid)
    end


endmodule: tau_gemm
