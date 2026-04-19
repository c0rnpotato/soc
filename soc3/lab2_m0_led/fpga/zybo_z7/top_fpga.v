// top_fpga.v — Zybo Z7-20 FPGA top wrapper for HY-SoC Lab2
//
// Board:  Digilent Zybo Z7-20 (XC7Z020-1CLG400C)
// Clock:  125 MHz PL system clock (pin K17) → MMCM → 50 MHz
// Reset:  BTN0 (pin Y16, active-high) → inverted to active-low
// LEDs:   LD0-LD3 (pins M14, M15, G14, D18)
//
// The CM0 SoC runs entirely in PL — no Zynq PS is used.

module top_fpga (
  input  wire       sysclk_125,    // 125 MHz PL system clock
  input  wire       btn0,          // active-high push button (reset)
  output wire [3:0] led            // LD0-LD3
);

  // ──────────────────────────────────────────────────────────────────────────
  // Clock generation: 125 MHz → 50 MHz via Xilinx MMCM
  // ──────────────────────────────────────────────────────────────────────────
  wire clk_50m;
  wire mmcm_locked;
  wire mmcm_fb;

  MMCME2_BASE #(
    .CLKIN1_PERIOD  (8.000),    // 125 MHz = 8.000 ns
    .CLKFBOUT_MULT_F(8.000),   // VCO = 125 × 8 = 1000 MHz
    .CLKOUT0_DIVIDE_F(20.000)  // CLKOUT0 = 1000 / 20 = 50 MHz
  ) u_mmcm (
    .CLKIN1    (sysclk_125),
    .CLKFBIN   (mmcm_fb),
    .CLKFBOUT  (mmcm_fb),
    .CLKOUT0   (clk_50m),
    .CLKOUT0B  (),
    .CLKOUT1   (),
    .CLKOUT1B  (),
    .CLKOUT2   (),
    .CLKOUT2B  (),
    .CLKOUT3   (),
    .CLKOUT3B  (),
    .CLKOUT4   (),
    .CLKOUT5   (),
    .CLKOUT6   (),
    .LOCKED    (mmcm_locked),
    .PWRDWN    (1'b0),
    .RST       (1'b0)
  );

  // ──────────────────────────────────────────────────────────────────────────
  // Reset: BTN0 (active-high) → active-low, gated by MMCM lock
  // ──────────────────────────────────────────────────────────────────────────
  wire rst_n = mmcm_locked & ~btn0;

  // ──────────────────────────────────────────────────────────────────────────
  // HY-SoC Lab2 (CM0 + SRAM + LED)
  // ──────────────────────────────────────────────────────────────────────────
  wire [3:0] led_out;

  hy_soc u_soc (
    .clk    (clk_50m),
    .i_rst  (rst_n),
    .led_o  (led_out)
  );

  assign led = led_out;

endmodule
