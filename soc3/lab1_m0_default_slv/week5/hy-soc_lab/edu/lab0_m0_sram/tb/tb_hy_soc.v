// --=========================================================================--
// Copyright (c) 2025-2026 DSAL, Hanyang University. All rights reserved
//                     DSAL Confidential Proprietary
//  ----------------------------------------------------------------------------
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from DSAL.
// -----------------------------------------------------------------------------
// FILE NAME       : tb_hy_soc.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim
// AUTHOR'S EMAIL  : jhoonkim@hanyang.ac.kr
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
//==============================================================================
// tb_hy_soc.v — Lab0 simulation testbench
//
// PASS verdict: SW writes 0x900DD00D to 0x0000_7FFC → PASS
// FAIL verdict: SW writes 0xDEADDEAD to 0x0000_7FFC → FAIL
// TIMEOUT    : terminates after 50000 clock cycles
//==============================================================================
module tb_hy_soc;

    // -------------------------------------------------------------------------
    // clock & reset
    // -------------------------------------------------------------------------
    reg clk, rst_n;

    initial clk = 0;
    always  #10 clk = ~clk;  // 50 MHz (20ns period)

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, tb_hy_soc);
        rst_n = 0;
        repeat(20) @(posedge clk);
        rst_n = 1;
        repeat(50000) @(posedge clk);
        $display("[TIMEOUT] %0t ns", $time);
        $finish;
    end

    // -------------------------------------------------------------------------
    // DUT
    // -------------------------------------------------------------------------
    hy_soc dut (.clk(clk), .rst_n(rst_n));
    
    localparam DONE_ADDR = 32'h00007FFC;
    localparam PASS_CODE = 32'h900DD00D;
    localparam FAIL_CODE = 32'hDEADDEAD;

    reg        mon_pending;
    reg [31:0] mon_addr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mon_pending <= 1'b0;
            mon_addr    <= 32'h0;
        end else if (dut.hready) begin
            mon_pending <= dut.hwrite & dut.htrans[1];
            mon_addr    <= dut.haddr;
        end
    end

    always @(posedge clk) begin
        if (mon_pending && mon_addr == DONE_ADDR) begin
            if      (dut.hwdata == PASS_CODE) begin
                $display("TEST PASS! (t=%0t ns)", $time);
                $finish;
            end
            else if (dut.hwdata == FAIL_CODE) begin
                $display("TEST FAIL! (t=%0t ns)", $time);
                $finish;
            end
        end
    end


endmodule
