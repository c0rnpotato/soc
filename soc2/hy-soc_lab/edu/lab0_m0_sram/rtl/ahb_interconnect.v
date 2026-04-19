// --=========================================================================--
// Copyright (c) 2025-2026 DSAL, Hanyang University. All rights reserved
//                     DSAL Confidential Proprietary
//  ----------------------------------------------------------------------------
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from DSAL.
// -----------------------------------------------------------------------------
// FILE NAME       : ahb_interconnect.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim
// AUTHOR'S EMAIL  : jhoonkim@hanyang.ac.kr
// -----------------------------------------------------------------------------
// ahb_interconnect.v — Lab0: single subordinate (SRAM), no default slave
//
// Trivial interconnect: all AHB transfers are forwarded to the sole
// subordinate. Unmapped addresses receive no ERROR — the bus simply
// returns whatever SRAM responds (lab1 introduces the default slave
// to generate proper ERROR responses for unmapped regions).

module ahb_interconnect (
  input  wire        hclk,
  input  wire        hrst_n,

  // Manager → Interconnect (address phase only; hwdata broadcast separately)
  input  wire [31:0] haddr_i,
  input  wire [1:0]  htrans_i,

  // Interconnect → Manager
  output wire [31:0] hrdata_o,
  output wire        hready_o,
  output wire        hresp_o,

  // Subordinate: SRAM
  output wire        hsel_sram_o,
  input  wire [31:0] hrdata_sram_i,
  input  wire        hreadyout_sram_i
);

  // Single subordinate — all accesses go to SRAM
  assign hsel_sram_o = 1'b1;

  // Responses passthrough
  assign hrdata_o = hrdata_sram_i;
  assign hready_o = hreadyout_sram_i;
  assign hresp_o  = 1'b0;

endmodule
