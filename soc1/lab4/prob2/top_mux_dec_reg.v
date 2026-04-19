`default_nettype none

module top_mux_dec_reg (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] wdata,
    input  wire [1:0] waddr,
    input  wire       we,
    input  wire [1:0] raddr,
    output wire [7:0] rdata
);

    // TODO: Instantiate and connect the sub-modules
    //
    // 1. Decoder: converts waddr + we into per-register write enables
    //    decoder2to4 u_dec (.in(waddr), .en(we), .out(we_vec));
    //
    // 2. Four registers: each gets its own write enable from decoder
    //    register8 u_reg0 (.clk(clk), .rst_n(rst_n), .we(we_vec[0]), .d(wdata), .q(reg0_q));
    //    ... (reg1, reg2, reg3)
    //
    // 3. MUX tree: select one register output for reading
    //    mux2to1 u_mux0 (.a(reg0_q), .b(reg1_q), .sel(raddr[0]), .y(mux_low));
    //    mux2to1 u_mux1 (.a(reg2_q), .b(reg3_q), .sel(raddr[0]), .y(mux_high));
    //    mux2to1 u_mux2 (.a(mux_low), .b(mux_high), .sel(raddr[1]), .y(rdata));

    wire    [ 3: 0] we_vec;
    wire    [ 7: 0] reg0_q, reg1_q, reg2_q, reg3_q,
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
