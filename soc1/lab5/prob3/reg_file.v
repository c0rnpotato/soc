`default_nettype none

module reg_file (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] raddr1,
    input  logic [1:0] raddr2,
    input  logic [1:0] waddr,
    input  logic [7:0] wdata,
    input  logic       we,
    output logic [7:0] rdata1,
    output logic [7:0] rdata2
);

    // TODO: Implement 4-entry x 8-bit register file
    //
    // Storage: logic [7:0] regs [0:3];
    //
    // Write port: always_ff
    // Read ports: always_comb
    logic   [7:0] regs  [0:3];
    integer i;
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            for (i = 0; i < 4; i = i + 1) regs[i] <= '0;
        else begin
            if(we)     regs[waddr ] <= wdata;
        end
    end
    
    always_comb begin
        rdata1  = regs[raddr1];
        rdata2  = regs[raddr2];
    end
endmodule
