module traffic_light_fsm #(
    parameter GREEN_TIME  = 5,
    parameter YELLOW_TIME = 2
)(
    input  wire clk,
    input  wire reset,
    input  wire one_sec_tick,

    output reg road_a_red,
    output reg road_a_yellow,
    output reg road_a_green,

    output reg road_b_red,
    output reg road_b_yellow,
    output reg road_b_green
);

    localparam S0 = 2'b00;   // A GREEN,  B RED
    localparam S1 = 2'b01;   // A YELLOW, B RED
    localparam S2 = 2'b10;   // A RED,    B GREEN
    localparam S3 = 2'b11;   // A RED,    B YELLOW

    reg [1:0] state;
    reg [1:0] next_state;

    // Counts seconds spent in current state
    reg [3:0] timer;

    // State and timer register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= 0;
        end
        else if (one_sec_tick) begin

            if ((state == S0 || state == S2) &&
                timer == GREEN_TIME - 1) begin

                state <= next_state;
                timer <= 0;
            end

            else if ((state == S1 || state == S3) &&
                     timer == YELLOW_TIME - 1) begin

                state <= next_state;
                timer <= 0;
            end

            else begin
                timer <= timer + 1;
            end
        end
    end

    // Next-state logic
    always @(*) begin
        case (state)
            S0: next_state = S1;
            S1: next_state = S2;
            S2: next_state = S3;
            S3: next_state = S0;
            default: next_state = S0;
        endcase
    end

    // Output logic
    always @(*) begin

        road_a_red    = 1'b0;
        road_a_yellow = 1'b0;
        road_a_green  = 1'b0;

        road_b_red    = 1'b0;
        road_b_yellow = 1'b0;
        road_b_green  = 1'b0;

        case (state)

            S0: begin
                road_a_green = 1'b1;
                road_b_red   = 1'b1;
            end

            S1: begin
                road_a_yellow = 1'b1;
                road_b_red    = 1'b1;
            end

            S2: begin
                road_a_red   = 1'b1;
                road_b_green = 1'b1;
            end

            S3: begin
                road_a_red    = 1'b1;
                road_b_yellow = 1'b1;
            end

            default: begin
                road_a_red = 1'b0;
                road_b_red = 1'b0;
            end

        endcase
    end

endmodule