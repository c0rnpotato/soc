`default_nettype none

module alu8bit (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [1:0] op,
    output wire [7:0] y
);

    // TODO: Implement 8-bit bitwise ALU using assign with ternary operators
    // op == 2'b00 : y = a & b  (AND)
    // op == 2'b01 : y = a | b  (OR)
    // op == 2'b10 : y = a ^ b  (XOR)
    // op == 2'b11 : y = ~a     (NOT A)
    assign y = (op == 2'b00) ? (a & b)  :
               (op == 2'b01) ? (a | b)  :
               (op == 2'b10) ? (a ^ b)  :
               (op == 2'b11) ? (~a)     : 8'b0;
endmodule
