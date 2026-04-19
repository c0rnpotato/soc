// --=========================================================================--
// Copyright (c) 2025-2026 DSAL, Hanyang University. All rights reserved
//                     DSAL Confidential Proprietary
//  ----------------------------------------------------------------------------
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from DSAL.
// -----------------------------------------------------------------------------
// FILE NAME       : cm0_rst_sync.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim (with assistance from Claude, Anthropic)
// AUTHOR'S EMAIL  : jhoonkim@hanyang.ac.kr
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE         AUTHOR         DESCRIPTION
// 1.0     2022-09-01   Ji-Hoon Kim    4-stage async assert / sync deassert
// 2.0     2026-03-30   Ji-Hoon Kim    Add SYSRESETREQ soft-reset support
// -----------------------------------------------------------------------------

// cm0_rst_sync.v — Cortex-M0 reset synchronizer
//
// Two independent async-assert / sync-deassert chains:
//
//   por_sync (rst_n only)
//     stage 1 → poresetn_o  (PORESETn)
//     stage 2 → dbgresetn_o (DBGRESETn)
//
//   sys_sync (rst_n OR SYSRESETREQ)
//     stage 1 → hresetn_o   (HRESETn)
//
// ARM TRM requirement (Cortex-M0 IIM §4.3):
//   "SYSRESETREQ must only cause assertion of HRESETn, not DBGRESETn."
//   This permits a debugger to stay connected across soft resets.

module cm0_rst_sync (
  input  wire clk,
  input  wire rst_n,           // async active-low reset input (external)
  input  wire sysresetreq_i,   // CM0 SYSRESETREQ (active-high, sync to clk)

  output wire poresetn_o,      // POR reset   (por_sync[1])
  output wire dbgresetn_o,     // debug reset (por_sync[2])
  output wire hresetn_o        // bus reset   (sys_sync[1])
);

  // ── POR / Debug reset chain (external reset only) ──────────
  // SYSRESETREQ must NOT assert PORESETn or DBGRESETn
  // so that a debugger can stay connected across soft resets.
  reg [2:0] por_sync;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) por_sync <= 3'b000;
    else        por_sync <= {por_sync[1:0], 1'b1};
  end

  assign poresetn_o  = por_sync[1];
  assign dbgresetn_o = por_sync[2];

  // ── System / bus reset chain (external reset OR SYSRESETREQ) ──
  wire rst_sys_n = rst_n & ~sysresetreq_i;
  reg [1:0] sys_sync;

  always @(posedge clk or negedge rst_sys_n) begin
    if (!rst_sys_n) sys_sync <= 2'b00;
    else            sys_sync <= {sys_sync[0], 1'b1};
  end

  assign hresetn_o = sys_sync[1];

endmodule
