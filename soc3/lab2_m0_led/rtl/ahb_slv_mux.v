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
// ahb_slv_mux.v — Lab2 AHB subordinate-to-manager mux
//
// 2 subordinates + default slave → manager response mux

module ahb_slv_mux (
  input  wire        hclk,
  input  wire        hrst_n,
  input  wire        hready_i,

  // Address-phase selects
  input  wire        hsel_sram_i,
  input  wire        hsel_led_i,

  // Subordinate responses
  input  wire [31:0] hrdata_sram_i,
  input  wire        hreadyout_sram_i,
  input  wire [31:0] hrdata_led_i,
  input  wire        hreadyout_led_i,

  // Default slave responses
  input  wire [31:0] hrdata_nomap_i,
  input  wire        hreadyout_nomap_i,
  input  wire        hresp_nomap_i,

  // Muxed output
  output wire [31:0] hrdata_o,
  output wire        hready_o,
  output wire        hresp_o
);

  localparam MUX_SRAM  = 2'd0;
  localparam MUX_LED   = 2'd1;
  localparam MUX_NOMAP = 2'd2;

  reg [1:0] mux_sel;

  always @(posedge hclk or negedge hrst_n)
    if (!hrst_n)       mux_sel <= MUX_NOMAP;
    else if (hready_i) begin
      if      (hsel_sram_i) mux_sel <= MUX_SRAM;
      else if (hsel_led_i)  mux_sel <= MUX_LED;
      else                  mux_sel <= MUX_NOMAP;
    end

  reg [31:0] hrdata_mux;
  reg        hready_mux;
  reg        hresp_mux;

  always @* begin
    case (mux_sel)
      MUX_SRAM: begin hrdata_mux = hrdata_sram_i; hready_mux = hreadyout_sram_i; hresp_mux = 1'b0; end
      MUX_LED:  begin hrdata_mux = hrdata_led_i;  hready_mux = hreadyout_led_i;  hresp_mux = 1'b0; end
      default:  begin hrdata_mux = hrdata_nomap_i; hready_mux = hreadyout_nomap_i; hresp_mux = hresp_nomap_i; end
    endcase
  end

  assign hrdata_o = hrdata_mux;
  assign hready_o = hready_mux;
  assign hresp_o  = hresp_mux;

endmodule
