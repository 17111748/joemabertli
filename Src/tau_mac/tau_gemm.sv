`default_nettype none

module gemm_fsm #(
    parameter BITWIDTH = 8
)(
    input  logic clk,
    input  logic reset_n,
    input  logic in_valid,
    input  logic macs_done,
    input  logic finished,
    output logic inc_input,
    output logic start
);

    enum {
        WAIT,
        COMPUTE
    } state_d, state_q;

    logic [$clog2(BITWIDTH):0] counter_d, counter_q;

    always_comb begin
        state_d   = state_q;
        counter_d = counter_q;
        inc_input = 1'b0;
        start     = 1'b0;

        case(state_q)
            WAIT: begin
                if(in_valid) begin
                    state_d = COMPUTE;
                    start   = 1'b1;
                end
            end

            COMPUTE: begin
                if(finished) begin
                    state_d = WAIT;
                end

                else if(counter_q >= BITWIDTH) begin
                    inc_input = 1'b1;
                    start     = 1'b1;
                    counter_d =  'b0;
                end
            end
        endcase
    end

    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            state_q   <= WAIT;
            counter_q <= 'b0;
        end

        else begin
            state_q   <= state_d;
            counter_q <= counter_d;
        end
    end
endmodule: gemm_fsm

module multiplier #(
    parameter DIM      = 16,
    parameter WIDTH    = 8,
    parameter OUT_BITS = 2 * WIDTH
)(
    input  logic                                        clk,
    input  logic                                        reset_n,
    input  logic [DIM - 1:0][DIM - 1:0][WIDTH - 1:0] in0,
    input  logic [DIM - 1:0][DIM - 1:0][WIDTH - 1:0] in1,
    input  logic                                        in_valid,
    output logic [DIM - 1:0][DIM - 1:0][OUT_BITS - 1:0] out,
    output logic                                        finished
);

    logic [DIM - 1:0][WIDTH - 1:0] active_in0;
    logic [DIM - 1:0][WIDTH - 1:0] active_in1;
    logic [DIM - 1:0][DIM - 1:0]      mac_valid;
    logic                             start;
    logic                             inc_input;

    gemm_fsm #(.BITWIDTH(WIDTH)) fsm (
        .clk        (clk),
        .reset_n    (reset_n),
        .in_valid   (in_valid),
        .finished   (finished),
        .macs_done  (),
        .inc_input  (inc_input),
        .start      (start)
    );
    
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

    logic [$clog2(WIDTH):0] cycle_counter_d, cycle_counter_q;
    assign active_in0 = in0[cycle_counter_q];
    assign active_in1 = in1[cycle_counter_q];

    always_comb begin
        cycle_counter_d = cycle_counter_q;

        if(cycle_counter_q == DIM - 1 && inc_input) begin
            finished = 'b1;
        end

        else if(inc_input) begin
            cycle_counter_d = cycle_counter_q + 'b1;
        end

    end
    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            cycle_counter_q <= 'b0;
        end

        else if(inc_input) begin
            cycle_counter_q <= cycle_counter_q + 'b1;
        end
    end
endmodule: multiplier
