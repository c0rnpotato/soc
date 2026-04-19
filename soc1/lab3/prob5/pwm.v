`default_nettype none

module pwm (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] duty,
    output wire       pwm_out
);

    // TODO: Implement PWM generator
    //
    // Step 1 (Sequential): 8-bit free-running counter
    //   - Increments every clock edge
    //   - Resets to 0 on async reset
    //
    // Step 2 (Combinational): Compare counter with duty
    //   - pwm_out = 1 when counter < duty
    //   - Use assign statement for this comparison
    reg [ 7: 0] counter;
    assign  pwm_out = (counter<duty);
    always @(posedge clk or negedge rst_n)
        if(!rst_n)  counter <= 0;
        else        counter <= counter + 8'b1;
endmodule
