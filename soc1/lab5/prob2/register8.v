`default_nettype none

module register8 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       we,
    input  logic [7:0] d,
    output logic [7:0] q
);

    // TODO: Implement 8-bit register using always_ff
    always_ff @(posedge clk or negedge rst_n)
        if(!rst_n)  q <= '0;
        else if(we) q <= d;
endmodule
