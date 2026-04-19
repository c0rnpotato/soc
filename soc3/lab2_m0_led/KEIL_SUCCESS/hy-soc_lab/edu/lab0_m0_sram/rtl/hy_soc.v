// --=========================================================================--
// Copyright (c) 2025-2026 DSAL, Hanyang University. All rights reserved
//                     DSAL Confidential Proprietary
//  ----------------------------------------------------------------------------
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from DSAL.
// -----------------------------------------------------------------------------
// FILE NAME       : hy_soc.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim
// AUTHOR'S EMAIL  : jhoonkim@hanyang.ac.kr
// -----------------------------------------------------------------------------
// hy_soc.v — HY-SoC Educational Lab0
//
// Cortex-M0 (DesignStart) + AHB-Lite Interconnect + SRAM 64KB
//
// Memory map:
//   0x0000_0000 – 0xFFFF_FFFF : single subordinate — ahb_sram (64 KB)
//   (no default slave; unmapped address handling introduced in lab1)

module hy_soc (
  input wire clk,     // system clock
  input wire rst_n    // async assert, sync deassert (active-low)
//  output wire [3:0] led
);

  // ---------------------------------------------------------------------------
  // AHB-Lite bus signals
  // ---------------------------------------------------------------------------
  wire [31:0] haddr;
  wire [31:0] hwdata;
  wire        hwrite;
  wire [1:0]  htrans;
  wire [2:0]  hburst;
  wire        hmastlock;
  wire [3:0]  hprot;
  wire [2:0]  hsize;
  wire [31:0] hrdata;
  wire        hresp;
  wire        hready;

  // Subordinate signals
  wire        hsel_s0;
  wire [31:0] hrdata_s0;
  wire        hreadyout_s0;

  // No interrupts in v01
  wire [31:0] irq = 32'h0;

  // ---------------------------------------------------------------------------
  // Reset synchronizer: two independent async-assert / sync-deassert chains
  //   por_sync (ext reset only)        -> PORESETn, DBGRESETn
  //   sys_sync (ext reset + SYSRESETREQ) -> HRESETn
  // ---------------------------------------------------------------------------
  wire hresetn, poresetn, dbgresetn;

  cm0_rst_sync u_rst_sync (
    .clk            (clk),
    .rst_n          (rst_n),
    .sysresetreq_i  (1'b0),
    .poresetn_o     (poresetn),
    .dbgresetn_o    (dbgresetn),
    .hresetn_o      (hresetn)
  );

  // CDBGPWRUP self-ack
  wire cdbgpwrupreq;

  // ---------------------------------------------------------------------------
  // Cortex-M0 DesignStart
  // ---------------------------------------------------------------------------
  CORTEXM0INTEGRATION u_cm0 (
    // clocks & resets
    .FCLK           (clk),
    .SCLK           (clk),
    .HCLK           (clk),
    .DCLK           (clk),
    .PORESETn       (poresetn),
    .DBGRESETn      (dbgresetn),
    .HRESETn        (hresetn),
    .SWCLKTCK       (1'b0),
    .nTRST          (1'b1),

    // AHB-Lite manager port
    .HADDR          (haddr),
    .HBURST         (hburst),
    .HMASTLOCK      (hmastlock),
    .HPROT          (hprot),
    .HSIZE          (hsize),
    .HTRANS         (htrans),
    .HWDATA         (hwdata),
    .HWRITE         (hwrite),
    .HRDATA         (hrdata),
    .HREADY         (hready),
    .HRESP          (hresp),
    .HMASTER        (),

    // code sequentiality (unused)
    .CODENSEQ       (),
    .CODEHINTDE     (),
    .SPECHTRANS     (),

    // debug — SWD tied off
    .SWDITMS        (1'b0),
    .TDI            (1'b0),
    .SWDO           (),
    .SWDOEN         (),
    .TDO            (),
    .nTDOEN         (),
    .DBGRESTART     (1'b0),
    .DBGRESTARTED   (),
    .EDBGRQ         (1'b0),
    .HALTED         (),

    // interrupts
    .NMI            (1'b0),
    .IRQ            (irq),
    .TXEV           (),
    .RXEV           (1'b0),
    .LOCKUP         (),
    .SYSRESETREQ    (),
    // SysTick: 50 MHz → 10 ms = 500 000 - 1 = 0x07_A11F
    .STCALIB        ({1'b1, 1'b0, 24'h07A11F}),
    .STCLKEN        (1'b0),
    .IRQLATENCY     (8'h00),
    .ECOREVNUM      (28'h0),

    // power management — tied off
    .GATEHCLK       (),
    .SLEEPING       (),
    .SLEEPDEEP      (),
    .WAKEUP         (),
    .WICSENSE       (),
    .SLEEPHOLDREQn  (1'b1),
    .SLEEPHOLDACKn  (),
    .WICENREQ       (1'b0),
    .WICENACK       (),
    .CDBGPWRUPREQ   (cdbgpwrupreq),
    .CDBGPWRUPACK   (cdbgpwrupreq),  // self-ack

    // scan — tied off
    .SE             (1'b0),
    .RSTBYPASS      (1'b0)
  );

  // ---------------------------------------------------------------------------
  // On-chip Interconnect (single subordinate, no default slave)
  // ---------------------------------------------------------------------------
  ahb_interconnect u_interconnect (
    .hclk            (clk),
    .hrst_n          (hresetn),
    .haddr_i         (haddr),
    .htrans_i        (htrans),
    .hrdata_o        (hrdata),
    .hready_o        (hready),
    .hresp_o         (hresp),
    .hsel_sram_o     (hsel_s0),
    .hrdata_sram_i   (hrdata_s0),
    .hreadyout_sram_i(hreadyout_s0)
  );

  // ---------------------------------------------------------------------------
  // s0: ahb_sram 64 KB (MEMWIDTH=16 → 2^16 bytes)
  // ---------------------------------------------------------------------------
  ahb_sram #(.MEMWIDTH(16)) u_sram (
    .hsel      (hsel_s0),
    .clk       (clk),
    .rst_n     (hresetn),
    .hready    (hready),
    .haddr     (haddr),
    .htrans    (htrans),
    .hwrite    (hwrite),
    .hsize     (hsize),
    .hwdata    (hwdata),
    .hreadyout (hreadyout_s0),
    .hrdata    (hrdata_s0)
  );

/*
      localparam DONE_ADDR = 32'h00007FFC;
    localparam PASS_CODE = 32'h900DD00D;
    localparam FAIL_CODE = 32'hDEADDEAD;

    reg        mon_pending;
    reg [31:0] mon_addr;

 
// state
reg [3:0] c_led, n_led;

assign led = c_led;
*/
endmodule
