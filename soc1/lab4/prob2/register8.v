`default_nettype none

module register8 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       we,
    input  wire [7:0] d,
    output reg  [7:0] q
);

    // TODO: Implement 8-bit register with write enable and async reset
    // rst_n=0 → q=0
    // we=1 on posedge clk → q <= d
    // we=0 → hold
    always @(posedge clk or negedge rst_n)
        if(!rst_n)  q <= '0;
        else if(we) q <= d;
endmodule
