module traffic_light_timer #(
    parameter CLK_FREQ = 50_000_000
)(
    input  wire clk,
    input  wire reset,
    output reg  one_sec_tick
);

    reg [25:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter     <= 0;
            one_sec_tick <= 0;
        end
        else begin
            if (counter == CLK_FREQ - 1) begin
                counter      <= 0;
                one_sec_tick <= 1'b1;
            end
            else begin
                counter      <= counter + 1'b1;
                one_sec_tick <= 1'b0;
            end
        end
    end

endmodule