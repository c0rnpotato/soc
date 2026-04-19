`default_nettype none

module alu_unit (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [2:0] op,
    output reg  [7:0] y,
    output wire       zero
);

    // TODO: Implement 8-bit ALU (same as Lab 2 Problem 4)
    // op=000: a+b, 001: a-b, 010: a&b, 011: a|b
    // op=100: a^b, 101: ~a,  110: a<<1, 111: a>>1

    // TODO: zero flag
    // assign zero = (y == 8'b0);
    assign zero = (y == 8'b0);
    always @(*) 
        case(op)
            3'b000: y = a + b;
            3'b001: y = a - b;
            3'b010: y = a & b;
            3'b011: y = a | b;
            3'b100: y = a ^ b;
            3'b101: y = ~a;
            3'b110: y = a << 1;
            3'b111: y = a >> 1;
            default:y = '0;
        endcase
endmodule
