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
// ahb_interconnect.v — Lab1: SRAM + default slave
//
// Structural wrapper: decoder + mux + default slave

module ahb_interconnect (
  input  wire        hclk,
  input  wire        hrst_n,

  input  wire [31:0] haddr_i,
  input  wire [1:0]  htrans_i,

  output wire [31:0] hrdata_o,
  output wire        hready_o,
  output wire        hresp_o,

  // Subordinate: SRAM
  output wire        hsel_sram_o,
  input  wire [31:0] hrdata_sram_i,
  input  wire        hreadyout_sram_i
);

  // Internal wires
  wire        sel_nomap;
  wire [31:0] hrdata_nomap;
  wire        hreadyout_nomap;
  wire        hresp_nomap;

  // --- Address Decoder ---
  ahb_dcd u_dcd (
    .haddr_i      (haddr_i),
    .hsel_sram_o  (hsel_sram_o),
    .hsel_nomap_o (sel_nomap)
  );

  // --- Subordinate-to-Manager Mux ---
  ahb_slv_mux u_mux (
    .hclk             (hclk),
    .hrst_n           (hrst_n),
    .hready_i         (hready_o),
    .hsel_sram_i      (hsel_sram_o),
    .hrdata_sram_i    (hrdata_sram_i),
    .hreadyout_sram_i (hreadyout_sram_i),
    .hrdata_nomap_i   (hrdata_nomap),
    .hreadyout_nomap_i(hreadyout_nomap),
    .hresp_nomap_i    (hresp_nomap),
    .hrdata_o         (hrdata_o),
    .hready_o         (hready_o),
    .hresp_o          (hresp_o)
  );

  // --- Default Slave ---
  ahb_default_slv u_default_slv (
    .clk        (hclk),
    .rst_n      (hrst_n),
    .hsel_i     (sel_nomap),
    .htrans_i   (htrans_i),
    .hready_i   (hready_o),
    .hreadyout_o(hreadyout_nomap),
    .hresp_o    (hresp_nomap),
    .hrdata_o   (hrdata_nomap)
  );

endmodule
