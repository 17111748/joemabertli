`default_nettype none

module tau_mac_tb ();
    logic clk;
    logic reset_n;
    logic start, mac_valid;
    localparam BITWIDTH = 8;
    localparam OUT_WIDTH = 2 * BITWIDTH;
    logic [BITWIDTH - 1:0] a;
    logic [BITWIDTH - 1:0] b;
    logic [OUT_WIDTH - 1:0] mac;

    tau_mac dut (
        .*
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task reset();
        reset_n  = 1'b1;
        reset_n <= 1'b0;
        @(posedge clk);
        reset_n <= 1'b1;
    endtask

    int i;
    initial begin
        a = 0;
        b = 0;
        start = 0;
        reset();
        for(i = 0; i < 5; i++) begin
            @(posedge clk);
        end

        #3
        a = 1;
        b = 2;
        start = 1;
        @(posedge clk);
        #3 start = 0;

        for(i = 0; i < 5; i++) begin
            while(!mac_valid) begin
                @(posedge clk);
            end
        end

        assert(mac == 'd10);
        @(posedge clk);

        #3
        a = 3;
        b = 1;
        start = 1;
        @(posedge clk);
        #3
        start = 'b0;

        for(i = 0; i < 5; i++) begin
            while(!mac_valid) begin
                @(posedge clk);
            end
        end

        assert(mac == 'd25);
        @(posedge clk);

        #3
        a = 3;
        b = 2;
        start = 1;
        @(posedge clk);
        #3
        start = 'b0;

        while(!mac_valid) begin
            @(posedge clk);
        end        

        assert(mac == 'd31);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $finish();
    end
endmodule: tau_mac_tb
