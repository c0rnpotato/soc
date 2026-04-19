# Lab 2: Cortex-M0 + LED Controller

Builds on Lab 1 by adding an **LED controller** peripheral,
implementing SysTick interrupt-driven LED blinking.
The AHB interconnect is expanded to handle two subordinates.

## Block Diagram

```
┌──────────────────────────────────────────────────────┐
│  hy_soc (top)                          ┌────────┐    │
│                                        │  SRAM  │    │
│  ┌────────────┐                        │  64KB  │    │
│  │ cm0_rst_   │                        └───▲────┘    │
│  │ sync       │                            │         │
│  └─────┬──────┘                            │         │
│  ┌─────┴──────┐    ┌──────────────────┐    │         │
│  │ Cortex-M0  ├───►│ ahb_interconnect ├────┘         │
│  │ (manager)  │◄───┤  ├─ ahb_dcd      ├────┐         │
│  └────────────┘    │  ├─ ahb_slv_mux  │    │         │
│                    │  └─ default_slv  │    ▼         │
│                    └──────────────────┘ ┌────────┐   │
│                                  led_o ◄┤ahb_led │   │
│                               [3:0]    └────────┘   │
└──────────────────────────────────────────────────────┘
```

## Changes from Lab 1

| Type | Description |
|------|-------------|
| **New** | `ahb_led` — LED controller (4-bit output) |
| **Modified** | `hy_soc.v` — Added `led_o[3:0]` port and LED instance |
| **Modified** | `ahb_dcd.v` — Added LED address region (2-to-1 decoding) |
| **Modified** | `ahb_slv_mux.v` — Expanded to 3-way mux (SRAM + LED + Default) |

## Key Concepts

- **Peripheral Addition Pattern**: Add address region to DCD → expand MUX → instantiate in top
- **SysTick Interrupt**: CM0 built-in timer for periodic LED toggling
- **Simulation Mode**: `SIMULATION=1` macro shortens the blink period for faster simulation

## Memory Map

| Address Range | Device | Notes |
|---------------|--------|-------|
| `0x0000_0000` – `0x0000_FFFF` | SRAM (64KB) | `haddr[31:16] == 16'h0000` |
| `0x5000_0000` – `0x50FF_FFFF` | LED Controller | `haddr[31:24] == 8'h50` |
| All other | Default Slave | ERROR response |

### LED Registers

| Offset | Name | Description |
|--------|------|-------------|
| `0x00` | DATA | LED output [3:0] (R/W) |

## Directory Structure

```
lab2_m0_led/
├── rtl/
│   ├── hy_soc.v              ← Top-level (led_o port added)
│   ├── ahb_interconnect.v    ← Interconnect (2 subordinates)
│   ├── ahb_dcd.v             ← Address decoder (SRAM + LED)
│   └── ahb_slv_mux.v         ← 3-way response mux
├── tb/
│   └── tb_hy_soc.v           ← Testbench (LED output monitoring)
├── sw/
│   ├── test.c                ← SysTick LED blink test
│   ├── gcc/                  ← GCC build
│   └── arm/                  ← ARM Compiler build
└── Makefile
```

## Firmware (test.c) Behavior

1. Initialize SysTick timer (simulation: short period, FPGA: 1 second)
2. SysTick interrupt handler toggles LED
3. After 3 toggles → writes `0x900DD00D` to `0x0000_7FFC` → **PASS**

## Build and Run

```bash
make clean && make all

# Simulator selection
make all SIM=vcs        # VCS (default)
make all SIM=verilator  # Verilator
```

## Relationship to Next Lab

**Lab 3** adds a UART peripheral, expanding the interconnect to three subordinates
and introducing interrupt-driven serial communication.
