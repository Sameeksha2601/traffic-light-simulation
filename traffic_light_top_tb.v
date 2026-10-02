`timescale 1ns/1ps

module traffic_light_top_tb;

    reg clk;
    reg reset;

    wire road_a_red;
    wire road_a_yellow;
    wire road_a_green;

    wire road_b_red;
    wire road_b_yellow;
    wire road_b_green;

    integer errors;

    traffic_light_top #(
        .CLK_FREQ(10),
        .GREEN_TIME(5),
        .YELLOW_TIME(2)
    ) dut (
        .clk(clk),
        .reset(reset),
        .road_a_red(road_a_red),
        .road_a_yellow(road_a_yellow),
        .road_a_green(road_a_green),
        .road_b_red(road_b_red),
        .road_b_yellow(road_b_yellow),
        .road_b_green(road_b_green)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        errors = 0;

        #20;
        reset = 1'b0;

        #1500;

        if (errors == 0) begin
            $display("========================================");
            $display("TOP-LEVEL TEST PASSED");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display("TOP-LEVEL TEST FAILED: %0d errors", errors);
            $display("========================================");
        end

        $finish;
    end

    always @(posedge clk) begin
        if (!reset) begin

            if ((road_a_red + road_a_yellow + road_a_green) > 1) begin
                $display("ERROR: Multiple Road A lights ON");
                errors = errors + 1;
            end

            if ((road_b_red + road_b_yellow + road_b_green) > 1) begin
                $display("ERROR: Multiple Road B lights ON");
                errors = errors + 1;
            end

            if (road_a_green && road_b_green) begin
                $display("ERROR: BOTH ROADS GREEN");
                errors = errors + 1;
            end

            if ((road_a_red + road_a_yellow + road_a_green) == 0) begin
                $display("ERROR: No Road A light active");
                errors = errors + 1;
            end

            if ((road_b_red + road_b_yellow + road_b_green) == 0) begin
                $display("ERROR: No Road B light active");
                errors = errors + 1;
            end

        end
    end

    initial begin
        $dumpfile("traffic_light_top.vcd");
        $dumpvars(0, traffic_light_top_tb);
    end

endmodule