`timescale 1ns/1ps

module traffic_light_fsm_tb;

    reg clk;
    reg reset;

    wire one_sec_tick;

    wire road_a_red;
    wire road_a_yellow;
    wire road_a_green;

    wire road_b_red;
    wire road_b_yellow;
    wire road_b_green;

    integer errors;
    integer tick_count;

    traffic_light_timer #(
        .CLK_FREQ(10)
    ) timer_inst (
        .clk(clk),
        .reset(reset),
        .one_sec_tick(one_sec_tick)
    );

    traffic_light_fsm #(
        .GREEN_TIME(5),
        .YELLOW_TIME(2)
    ) dut (
        .clk(clk),
        .reset(reset),
        .one_sec_tick(one_sec_tick),
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
        tick_count = 0;

        #20;
        reset = 1'b0;

        #1500;

        if (errors == 0) begin
            $display("========================================");
            $display("ALL SEQUENCE CHECKS PASSED");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display("TEST FAILED: %0d errors", errors);
            $display("========================================");
        end

        $finish;
    end

    always @(posedge clk) begin
        if (!reset && one_sec_tick) begin

            tick_count = tick_count + 1;

            $display("TICK=%0d | A_R=%b A_Y=%b A_G=%b | B_R=%b B_Y=%b B_G=%b",
                     tick_count,
                     road_a_red,
                     road_a_yellow,
                     road_a_green,
                     road_b_red,
                     road_b_yellow,
                     road_b_green);

            if (tick_count >= 1 && tick_count <= 5) begin
                if (!(road_a_green && road_b_red)) begin
                    $display("ERROR: Expected S0 at tick %0d", tick_count);
                    errors = errors + 1;
                end
            end

            if (tick_count >= 6 && tick_count <= 7) begin
                if (!(road_a_yellow && road_b_red)) begin
                    $display("ERROR: Expected S1 at tick %0d", tick_count);
                    errors = errors + 1;
                end
            end

            if (tick_count >= 8 && tick_count <= 12) begin
                if (!(road_a_red && road_b_green)) begin
                    $display("ERROR: Expected S2 at tick %0d", tick_count);
                    errors = errors + 1;
                end
            end

            if (tick_count >= 13 && tick_count <= 14) begin
                if (!(road_a_red && road_b_yellow)) begin
                    $display("ERROR: Expected S3 at tick %0d", tick_count);
                    errors = errors + 1;
                end
            end

            if (tick_count == 15) begin
                if (!(road_a_green && road_b_red)) begin
                    $display("ERROR: Expected S0 restart at tick 14");
                    errors = errors + 1;
                end
            end

        end
    end

    always @(posedge clk) begin
        if (!reset) begin

            if ((road_a_red + road_a_yellow + road_a_green) > 1) begin
                $display("ERROR: Multiple Road A lights ON at %0t", $time);
                errors = errors + 1;
            end

            if ((road_b_red + road_b_yellow + road_b_green) > 1) begin
                $display("ERROR: Multiple Road B lights ON at %0t", $time);
                errors = errors + 1;
            end

            if (road_a_green && road_b_green) begin
                $display("ERROR: BOTH ROADS GREEN at %0t", $time);
                errors = errors + 1;
            end

            if ((road_a_red + road_a_yellow + road_a_green) == 0) begin
                $display("ERROR: No Road A light active at %0t", $time);
                errors = errors + 1;
            end

            if ((road_b_red + road_b_yellow + road_b_green) == 0) begin
                $display("ERROR: No Road B light active at %0t", $time);
                errors = errors + 1;
            end

        end
    end

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, traffic_light_fsm_tb);
    end

endmodule
