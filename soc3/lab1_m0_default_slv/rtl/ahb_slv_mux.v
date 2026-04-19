// --=========================================================================--
// Copyright (c) 2025-2026 DSAL, Hanyang University. All rights reserved
//                     DSAL Confidential Proprietary
//  ----------------------------------------------------------------------------
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from DSAL.
// -----------------------------------------------------------------------------
// FILE NAME       : ahb_slv_mux.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim
// AUTHOR'S EMAIL  : jhoonkim@hanyang.ac.kr
// -----------------------------------------------------------------------------
// ahb_slv_mux.v — Lab1 AHB subordinate-to-manager mux
//
// 1 subordinate + default slave → manager response mux

module ahb_slv_mux (
  input  wire        hclk,
  input  wire        hrst_n,
  input  wire        hready_i,       // muxed hready (active feedback)

  // Address-phase selects (from decoder)
  input  wire        hsel_sram_i,

  // Subordinate responses
  input  wire [31:0] hrdata_sram_i,
  input  wire        hreadyout_sram_i,

  // Default slave responses
  input  wire [31:0] hrdata_nomap_i,
  input  wire        hreadyout_nomap_i,
  input  wire        hresp_nomap_i,

  // Muxed output to manager
  output wire [31:0] hrdata_o,
  output wire        hready_o,
  output wire        hresp_o
);

  // Register select at address phase
  reg mux_sel_sram;

  always @(posedge hclk or negedge hrst_n)
    if (!hrst_n)       mux_sel_sram <= 1'b1;
    else if (hready_i) mux_sel_sram <= hsel_sram_i;

  assign hrdata_o = mux_sel_sram ? hrdata_sram_i    : hrdata_nomap_i;
  assign hready_o = mux_sel_sram ? hreadyout_sram_i  : hreadyout_nomap_i;
  assign hresp_o  = mux_sel_sram ? 1'b0              : hresp_nomap_i;

endmodule
