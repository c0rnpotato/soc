// --=========================================================================--
// Copyright (c) 2025-2026 DSAL, Hanyang University. All rights reserved
//                     DSAL Confidential Proprietary
//  ----------------------------------------------------------------------------
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from DSAL.
// -----------------------------------------------------------------------------
// FILE NAME       : ahb_dcd.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim
// AUTHOR'S EMAIL  : jhoonkim@hanyang.ac.kr
// -----------------------------------------------------------------------------
// ahb_dcd.v — Lab1 AHB address decoder
//
// 1 subordinate + default slave
//   SRAM : 0x0000_0000 – 0x0000_FFFF

module ahb_dcd (
  input  wire [31:0] haddr_i,

  output wire        hsel_sram_o,
  output wire        hsel_nomap_o
);

  assign hsel_sram_o  = (haddr_i[31:16] == 16'h0000);
  assign hsel_nomap_o = ~hsel_sram_o;

endmodule
