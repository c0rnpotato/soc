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
// hy_soc.v — HY-SoC Educational Lab2
//
// Cortex-M0 (DesignStart) + AHB Interconnect + SRAM 64KB + LED
//
// Memory map:
//   0x0000_0000 – 0x0000_FFFF : SRAM 64 KB
//   0x5000_0000 – 0x50FF_FFFF : LED Controller
//   other                     : default slave (ERROR)

module hy_soc (
  input  wire       clk,       // system clock
  input  wire       i_rst,     // async assert, sync deassert (active-low)
  output wire [3:0] led_o      // LED output pins
);
wire rst_n;

assign rst_n = !i_rst;
  // ---------------------------------------------------------------------------
  // AHB-Lite bus signals
  // ---------------------------------------------------------------------------s
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

  // Subordinate signals — SRAM
  wire        hsel_sram;
  wire [31:0] hrdata_sram;
  wire        hreadyout_sram;

  // Subordinate signals — LED
  wire        hsel_led;
  wire [31:0] hrdata_led;
  wire        hreadyout_led;

  // No interrupts
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
  // On-chip Interconnect (SRAM + LED + default slave)
  // ---------------------------------------------------------------------------
  ahb_interconnect u_interconnect (
    .hclk             (clk),
    .hrst_n           (hresetn),
    .haddr_i          (haddr),
    .htrans_i         (htrans),
    .hrdata_o         (hrdata),
    .hready_o         (hready),
    .hresp_o          (hresp),
    .hsel_sram_o      (hsel_sram),
    .hrdata_sram_i    (hrdata_sram),
    .hreadyout_sram_i (hreadyout_sram),
    .hsel_led_o       (hsel_led),
    .hrdata_led_i     (hrdata_led),
    .hreadyout_led_i  (hreadyout_led)
  );

  // ---------------------------------------------------------------------------
  // SRAM 64 KB (MEMWIDTH=16 → 2^16 bytes)
  // ---------------------------------------------------------------------------
  ahb_sram #(.MEMWIDTH(16)) u_sram (
    .hsel      (hsel_sram),
    .clk       (clk),
    .rst_n     (hresetn),
    .hready    (hready),
    .haddr     (haddr),
    .htrans    (htrans),
    .hwrite    (hwrite),
    .hsize     (hsize),
    .hwdata    (hwdata),
    .hreadyout (hreadyout_sram),
    .hrdata    (hrdata_sram)
  );

  // ---------------------------------------------------------------------------
  // LED Controller
  // ---------------------------------------------------------------------------
  ahb_led u_led (
    .hclk       (clk),
    .hrst_n     (hresetn),
    .hsel_i     (hsel_led),
    .hready_i   (hready),
    .haddr_i    (haddr),
    .htrans_i   (htrans),
    .hwrite_i   (hwrite),
    .hwdata_i   (hwdata),
    .hreadyout_o(hreadyout_led),
    .hrdata_o   (hrdata_led),
    .led_o      (led_o)
  );


endmodule
