`default_nettype none

module alu_acc (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] b,
    input  logic [2:0] op,
    input  logic       en,
    output logic [7:0] acc,
    output logic       zero
);

    // TODO: Implement ALU + Accumulator using SystemVerilog
    //
    // Step 1 — Combinational: ALU (use always_comb)
    //   logic [7:0] alu_result;
    //   always_comb begin ... end
    //
    // Step 2 — Sequential: Accumulator register (use always_ff)
    //   always_ff @(posedge clk or negedge rst_n) begin ... end
    //
    // Step 3 — Combinational: zero flag (use assign)
    reg [ 7: 0]    acc_reg;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)  acc <= '0;
        else if(en) acc <= acc_reg;
    end

    always_comb begin
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
