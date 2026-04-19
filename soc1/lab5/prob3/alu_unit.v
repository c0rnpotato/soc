`default_nettype none

module alu_unit (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [2:0] op,
    output logic [7:0] y,
    output logic       zero
);

    // TODO: Implement ALU using always_comb + assign for zero flag
    assign zero = (y == 8'b0);
    always_comb 
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
