`default_nettype none

module top_mux_dec_reg (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] wdata,
    input  logic [1:0] waddr,
    input  logic       we,
    input  logic [1:0] raddr,
    output logic [7:0] rdata
);

    // TODO: Instantiate sub-modules using dot-name (.name) port connections
    //
    // Use .name for ports where signal name matches port name:
    //   decoder2to4 u_dec (
    //       .in  (waddr),
    //       .en  (we),      // or .en if local signal is also named 'en'
    //       .out (we_vec)
    //   );
    //
    //   register8 u_reg0 (
    //       .clk,           // dot-name: clk matches clk
    //       .rst_n,         // dot-name: rst_n matches rst_n
    //       .we  (we_vec[0]),
    //       .d   (wdata),
    //       .q   (reg0_q)
    //   );
    //
    // Remember: logic for all internal wires (no wire/reg distinction)

    logic   [ 3: 0] we_vec;
    logic   [ 7: 0] reg0_q, reg1_q, reg2_q, reg3_q,
                    mux_low,        mux_high;
                    
    decoder2to4 u_dec (.in(waddr), .en(we), .out(we_vec));
    
    register8 u_reg0 (.clk(clk), .rst_n(rst_n), .we(we_vec[0]), .d(wdata), .q(reg0_q));
    register8 u_reg1 (.clk(clk), .rst_n(rst_n), .we(we_vec[1]), .d(wdata), .q(reg1_q));
    register8 u_reg2 (.clk(clk), .rst_n(rst_n), .we(we_vec[2]), .d(wdata), .q(reg2_q));
    register8 u_reg3 (.clk(clk), .rst_n(rst_n), .we(we_vec[3]), .d(wdata), .q(reg3_q));
    
    mux2to1 u_mux0 (.a(reg0_q),  .b(reg1_q),   .sel(raddr[0]), .y(mux_low));
    mux2to1 u_mux1 (.a(reg2_q),  .b(reg3_q),   .sel(raddr[0]), .y(mux_high));
    mux2to1 u_mux2 (.a(mux_low), .b(mux_high), .sel(raddr[1]), .y(rdata));
endmodule
