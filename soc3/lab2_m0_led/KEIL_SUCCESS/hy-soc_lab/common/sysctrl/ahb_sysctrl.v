// --=========================================================================--
// Copyright (c) 2025-2026 DSAL, Hanyang University. All rights reserved
//                     DSAL Confidential Proprietary
//  ----------------------------------------------------------------------------
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from DSAL.
// -----------------------------------------------------------------------------
// FILE NAME       : ahb_sysctrl.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim (with assistance from Claude, Anthropic)
// AUTHOR'S EMAIL  : jhoonkim@hanyang.ac.kr
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE         AUTHOR         DESCRIPTION
// 1.0     2022-09-01   Ji-Hoon Kim    Initial remap-only version
// 2.0     2026-03-30   Ji-Hoon Kim    Add SOC_ID register, addr decode
// -----------------------------------------------------------------------------

// ahb_sysctrl.v — AHB-Lite System Control Register
//
// Register map (base 0x4000_0000):
//   0x00  REMAPCTRL   R/W  bit[0] = remap
//                          0: 0x0 → BROM (power-on default)
//                          1: 0x0 → SRAM (set by bootloader)
//   0x04  SOC_ID      RO   SoC identifier (build-time parameter)
//                          [31:24] CORE_TYPE  0x00=CM0, 0x01=CM3, 0x02=CM4F, 0x10=RV32I
//                          [23]    HAS_VTOR   0=no VTOR, 1=VTOR available
//                          [22:16] reserved
//                          [15:8]  SRAM_SIZE_KB
//                          [7:0]   BROM_SIZE_KB
//
// Single-cycle response.

module ahb_sysctrl #(
  parameter SOC_ID = 32'h0000_4008   // default: CM0, no VTOR, 64KB SRAM, 8KB BROM
)(
  input  wire        hclk,
  input  wire        hrst_n,

  input  wire        hsel_i,
  input  wire        hready_i,
  input  wire [31:0] haddr_i,
  input  wire [1:0]  htrans_i,
  input  wire        hwrite_i,
  input  wire [31:0] hwdata_i,

  output wire        hreadyout_o,
  output wire [31:0] hrdata_o,

  output wire        remap_o    // to address decoder
);

  assign hreadyout_o = 1'b1;

  // Address-phase capture
  wire trans_valid = hsel_i & htrans_i[1] & hready_i;

  reg wr_en;
  reg [1:0] addr_reg;   // capture haddr[3:2] for register select

  always @(posedge hclk or negedge hrst_n) begin
    if (!hrst_n) begin
      wr_en    <= 1'b0;
      addr_reg <= 2'b0;
    end else begin
      wr_en    <= trans_valid & hwrite_i;
      addr_reg <= haddr_i[3:2];
    end
  end

  // REMAPCTRL register (offset 0x00)
  reg remap_reg;
  always @(posedge hclk or negedge hrst_n) begin
    if (!hrst_n)                        remap_reg <= 1'b0;  // boot from BROM
    else if (wr_en && addr_reg == 2'b00) remap_reg <= hwdata_i[0];
  end

  assign remap_o = remap_reg;

  // Read mux
  reg [31:0] rdata;
  always @(*) begin
    case (addr_reg)
      2'b00:   rdata = {31'h0, remap_reg};   // 0x00: REMAPCTRL
      2'b01:   rdata = SOC_ID;                // 0x04: SOC_ID (RO)
      default: rdata = 32'h0;
    endcase
  end

  assign hrdata_o = rdata;

endmodule
