module traffic_light_top #(
    parameter CLK_FREQ   = 50_000_000,
    parameter GREEN_TIME = 5,
    parameter YELLOW_TIME = 2
)(
    input  wire clk,
    input  wire reset,

    output wire road_a_red,
    output wire road_a_yellow,
    output wire road_a_green,

    output wire road_b_red,
    output wire road_b_yellow,
    output wire road_b_green
);

    wire one_sec_tick;

    // 50 MHz clock -> 1-second tick
    traffic_light_timer #(
        .CLK_FREQ(CLK_FREQ)
    ) timer_inst (
        .clk(clk),
        .reset(reset),
        .one_sec_tick(one_sec_tick)
    );

    // Traffic-light FSM
    traffic_light_fsm #(
        .GREEN_TIME(GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME)
    ) fsm_inst (
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

endmodule