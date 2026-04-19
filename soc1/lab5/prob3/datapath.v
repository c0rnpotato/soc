`default_nettype none

module datapath (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] raddr1,
    input  logic [1:0] raddr2,
    input  logic [1:0] waddr,
    input  logic       we,
    input  logic [2:0] alu_op,
    input  logic [7:0] imm,
    input  logic       src_b_sel,
    output logic [7:0] alu_result,
    output logic       zero
);

    // TODO: Instantiate sub-modules using dot-name (.name) connections
    //
    // Internal signals (all logic, no wire/reg):
    //   logic [7:0] rdata1, rdata2;
    //   logic [7:0] alu_b;
    //
    // Use dot-name where signal and port names match:
    //   reg_file u_rf (
    //       .clk,              // dot-name
    //       .rst_n,            // dot-name
    //       .raddr1,           // dot-name
    //       .raddr2,           // dot-name
    //       .waddr,            // dot-name
    //       .wdata (alu_result), // named (different names)
    //       .we,               // dot-name
    //       .rdata1,           // dot-name
    //       .rdata2            // dot-name
    //   );
    logic   [7:0] rdata1, rdata2;  // register file outputs
    logic   [7:0] alu_b;           // MUX output → ALU input B
    
    reg_file u_rf (
      .clk(clk), .rst_n(rst_n),
      .raddr1(raddr1), .raddr2(raddr2),
      .waddr(waddr), .wdata(alu_result), .we(we),
      .rdata1(rdata1), .rdata2(rdata2)
    );
    
    mux2to1_8bit u_mux_b (
      .a(rdata2), .b(imm), .sel(src_b_sel), .y(alu_b)
    );
    
    alu_unit u_alu (
      .a(rdata1), .b(alu_b), .op(alu_op),
      .y(alu_result), .zero(zero)
    );
endmodule
