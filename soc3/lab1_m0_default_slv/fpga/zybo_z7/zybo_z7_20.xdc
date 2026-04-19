## zybo_z7_20.xdc — Zybo Z7-20 constraints for HY-SoC Lab2
##
## Reference: Digilent Zybo Z7 Schematic Rev. B.2
## Part: XC7Z020-1CLG400C

## ────────────────────────────────────────────────────────────
## Clock: 125 MHz PL system clock
## ────────────────────────────────────────────────────────────
set_property -dict { PACKAGE_PIN K17  IOSTANDARD LVCMOS33 } [get_ports sysclk_125]
create_clock -period 8.000 -name sys_clk_125 [get_ports sysclk_125]

## ────────────────────────────────────────────────────────────
## Reset: BTN0 (active-high)
## ────────────────────────────────────────────────────────────
set_property -dict { PACKAGE_PIN Y16  IOSTANDARD LVCMOS33 } [get_ports btn0]

## ────────────────────────────────────────────────────────────
## LEDs: LD0 – LD3
## ────────────────────────────────────────────────────────────
set_property -dict { PACKAGE_PIN M14  IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN M15  IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN G14  IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN D18  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]

## ────────────────────────────────────────────────────────────
## Configuration: compress bitstream
## ────────────────────────────────────────────────────────────
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
