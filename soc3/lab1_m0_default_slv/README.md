# Lab 1: Cortex-M0 + Default Slave

Builds on Lab 0 by adding an **AHB address decoder** and **Default Slave**,
so that accesses to unmapped addresses return an ERROR response.

## Block Diagram

```
┌──────────────────────────────────────────────────────┐
│  hy_soc (top)                                        │
│                                                      │
│  ┌────────────┐                                      │
│  │ cm0_rst_   │                                      │
│  │ sync       │                                      │
│  └─────┬──────┘                                      │
│  ┌─────┴──────┐    ┌──────────────────┐              │
│  │ Cortex-M0  ├───►│ ahb_interconnect │  ┌────────┐  │
│  │ (manager)  │◄───┤  ├─ ahb_dcd      ├─►│  SRAM  │  │
│  └────────────┘    │  ├─ ahb_slv_mux  │  │  64KB  │  │
│                    │  └─ default_slv  │  └────────┘  │
│                    └──────────────────┘              │
└──────────────────────────────────────────────────────┘
```

## Changes from Lab 0

| Type | Description |
|------|-------------|
| **New** | `ahb_dcd.v` — Address decoder (SRAM vs Default) |
| **New** | `ahb_slv_mux.v` — Subordinate response multiplexer |
| **New** | `ahb_default_slv` — Returns ERROR response (2-cycle) for unmapped addresses |
| **Modified** | `ahb_interconnect.v` — Expanded to structural wrapper (DCD + MUX + Default Slave) |

## Key Concepts

- **Address Decoding (Address Phase)**: `ahb_dcd` examines `HADDR` to select the target subordinate
- **Response Multiplexing (Data Phase)**: `ahb_slv_mux` latches the select signal in the address phase and muxes the response in the data phase
- **Default Slave**: Unmapped address → `HRESP=1` (ERROR) → CM0 HardFault

## Memory Map

| Address Range | Device | Notes |
|---------------|--------|-------|
| `0x0000_0000` – `0x0000_FFFF` | SRAM (64KB) | `haddr[31:16] == 16'h0000` |
| All other | Default Slave | ERROR response → HardFault |

## Directory Structure

```
lab1_m0_default_slv/
├── rtl/
│   ├── hy_soc.v              ← Top-level module
│   ├── ahb_interconnect.v    ← Interconnect (DCD + MUX + Default Slave)
│   ├── ahb_dcd.v             ← Address decoder
│   └── ahb_slv_mux.v         ← Subordinate response mux
├── tb/
│   └── tb_hy_soc.v           ← Testbench
├── sw/
│   ├── test.c                ← Test firmware
│   ├── gcc/                  ← GCC build
│   └── arm/                  ← ARM Compiler build
└── Makefile
```

## Build and Run

```bash
make clean && make all

# Simulator selection
make all SIM=vcs        # VCS (default)
make all SIM=verilator  # Verilator
```

## Relationship to Next Lab

The interconnect pattern established in Lab 1 (DCD → MUX → Default Slave)
is reused in all subsequent labs.
**Lab 2** adds an LED controller as a second subordinate to this structure.
