## nexys_a7.xdc — Nexys A7-100T constraints for HY-SoC Lab2
##
## Reference: Digilent Nexys A7 Reference Manual / Schematic
## Part: XC7A100T-1CSG324C

## ────────────────────────────────────────────────────────────
## Clock: 100 MHz oscillator
## ────────────────────────────────────────────────────────────
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports sysclk_100]
create_clock -period 10.000 -name sys_clk_100 [get_ports sysclk_100]

## ────────────────────────────────────────────────────────────
## Reset: CPU_RESETN (active-low)
## ────────────────────────────────────────────────────────────
set_property -dict { PACKAGE_PIN C12  IOSTANDARD LVCMOS33 } [get_ports cpu_resetn]

## ────────────────────────────────────────────────────────────
## LEDs: LD0 – LD3
## ────────────────────────────────────────────────────────────
set_property -dict { PACKAGE_PIN H17  IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN K15  IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN J13  IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN N14  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]

## ────────────────────────────────────────────────────────────
## Configuration: compress bitstream
## ────────────────────────────────────────────────────────────
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
