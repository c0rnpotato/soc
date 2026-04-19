`default_nettype none

module dff (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);

    // TODO: Implement D flip-flop with active-low asynchronous reset
    // Template: always @(posedge clk or negedge rst_n)
    // Use nonblocking assignment (<=)
    always @(posedge clk or negedge rst_n)
        if(!rst_n) q <= 0;
        else q <= d;
endmodule
