`default_nettype none

module alu_acc (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] b,
    input  wire [2:0] op,
    input  wire       en,
    output reg  [7:0] acc,
    output wire       zero
);

    // TODO: Step 1 — Combinational: compute ALU result
    // Declare wire or reg for alu_result
    // Use always @(*) or assign to compute:
    //   op=000: acc + b
    //   op=001: acc - b
    //   op=010: acc & b
    //   op=011: acc | b
    //   op=100: acc ^ b
    //   op=101: ~acc
    //   op=110: acc << 1
    //   op=111: acc >> 1

    // TODO: Step 2 — Sequential: accumulator register
    // always @(posedge clk or negedge rst_n)
    //   rst_n=0 → acc <= 0
    //   en=1    → acc <= alu_result

    // TODO: Step 3 — Combinational: zero flag
    // assign zero = ...

    reg [ 7: 0]    acc_reg;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  acc <= '0;
        else if(en) acc <= acc_reg;
    end

    always @(*) begin
        case(op)
            3'b000: acc_reg = acc + b;
            3'b001: acc_reg = acc - b;
            3'b010: acc_reg = acc & b;
            3'b011: acc_reg = acc | b;
            3'b100: acc_reg = acc ^ b;
            3'b101: acc_reg = ~acc;
            3'b110: acc_reg = acc << 1;
            3'b111: acc_reg = acc >> 1;
            default: acc_reg = 8'b0;
        endcase
    end
    assign zero = (acc == 8'b0);

endmodule
