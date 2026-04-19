`default_nettype none

module mux4to1 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [7:0] c,
    input  wire [7:0] d,
    input  wire [1:0] sel,
    output reg  [7:0] y
);

    // TODO: Implement 4:1 MUX using always @(*) with case statement
    // Remember: use blocking assignment (=)
    always @(*) begin
        case (sel)
            2'b00   : y = a;
            2'b01   : y = b;
            2'b10   : y = c;
            2'b11   : y = d;
            default : y = 8'b0;
        endcase
    end
endmodule
