`default_nettype none

module and_mxu #(
    DIM       = 8,
    WIDTH     = 4,
    UWIDTH    = 2,
    OUT_WIDTH = 2 * IN_WIDTH
)(
    input  logic                                         clk,
    input  logic                                         reset_n,
    input  logic [DIM - 1:0][DIM - 1:0][WIDTH - 1:0]     in0,
    input  logic [DIM - 1:0][DIM - 1:0][WIDTH - 1:0]     in1,
    output logic [DIM - 1:0][DIM - 1:0][OUT_WIDTH - 1:0] out,
    output logic                                         finished
);

    logic [DIM - 1:0][DIM - 1:0][UWIDTH - 1:0] north, south, east, west;
    generate
    for(genvar i = 0; i < DIM; i++) begin
        for(genvar j = 0; j < DIM; j++) begin
            systolic_node #(
                .UWIDTH(UWIDTH),
                .BWIDTH(OUT_WIDTH)
            ) node (
                .clk (clk),
                .reset_n (reset_n),
                .north(north[i][j]),
                .west(west[i][j]),
                .east(east[i][j]),
                .south(south[i][j]),
                .mac(out[i][j])
            );
        end
    end
    endgenerate


    


endmodule: 
