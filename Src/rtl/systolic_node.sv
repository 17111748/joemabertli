`default_nettype none

module systolic_node #(
    parameter UWIDTH = 2,
    parameter BWIDTH = 8
)(
    input  logic                clk,
    input  logic                reset_n,
    input  logic [UWIDTH - 1:0] north,
    input  logic [UWIDTH - 1:0] west,
    output logic [UWIDTH - 1:0] south,
    output logic [UWIDTH - 1:0] east,
    output logic [BWIDTH - 1:0] mac
);

    /* o represents the output of north * west */ 
    logic [$clog2(UWIDTH * UWIDTH):0] o;

    logic [BWIDTH - 1:0] mac_d;
    logic [BWIDTH - 1:0] mac_q;

    generate

    /* Right now, only works with UWIDTH == 2 */
    if(UWIDTH == 2) begin
        always_comb begin
            o[2] = north[0] & north[1] & west[0] & west[1];
            o[1] = north[0] & west[0] & (north[1] ^ west[1]);
            o[0] = north[0] & west[0] & ~north[1] & ~west[1];
        end

        /* intermediate carries */
        logic [BWIDTH:1] c;

        half_adder b0 (
            .a      (mac_q[0]),
            .c_in   (o[0]),
            .y      (mac_d[0]),
            .c_out  (c[1])
        );

        for(genvar i = 1; i <= 2; i++) begin
            full_adder fa (
                .a      (mac_q[i]),
                .b      (o[i]),
                .c_in   (c[i]),
                .y      (mac_d[i]),
                .c_out  (c[i + 1])
            );
        end

        for(genvar i = 0; i < BWIDTH - 3; i++) begin
            half_adder ha (
                .a      (mac_q[i + 3]),
                .c_in   (c[i + 3]),
                .y      (mac_d[i + 3]),
                .c_out  (c[i + 4])
            );
        end
    end

    else begin
        /* ones is the output of the matrix of and gates */
        logic [UWIDTH - 1:0][UWIDTH - 1:0] ones;
        for(genvar i = 0; i < UWIDTH; i++) begin
            for(genvar j = 0; j < UWIDTH; j++) begin
                and g0 (ones[i][j], north[j], west[i]);
            end
        end
    end

    endgenerate

    assign mac = mac_q;

    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            mac_q <= 'b0;
            south <= 'b0;
            east  <= 'b0;
        end

        else begin
            mac_q <= mac_d;
            south <= north;
            east  <= west;
        end
    end
    

endmodule: systolic_node
