`default_nettype none

module updown_counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       load,
    input  wire       en,
    input  wire       up,
    input  wire [7:0] data,
    output reg  [7:0] count
);

    // TODO: Implement 8-bit up/down counter with load and async reset
    // Priority: reset > load > count (en+up/down) > hold
    // Use nonblocking assignment (<=)
    always @(posedge clk or negedge rst_n)
        if(!rst_n)      count <= 0;
        else if(load)   count <= data;
        else if(en)
            if(up)      count <= count + 8'b1;
            else        count <= count - 8'b1;
endmodule
