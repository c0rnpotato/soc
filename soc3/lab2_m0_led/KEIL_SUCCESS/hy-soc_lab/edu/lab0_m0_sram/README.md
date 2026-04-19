# Lab 0: Cortex-M0 + SRAM

A minimal SoC consisting of an ARM Cortex-M0 processor and 64KB SRAM.
This is the first step toward understanding AHB-Lite bus operation.

## Block Diagram

```
┌─────────────────────────────────────────────┐
│  hy_soc (top)                               │
│                                             │
│  ┌────────────┐    ┌───────────────┐        │
│  │ cm0_rst_   │    │  ahb_         │        │
│  │ sync       │    │  interconnect │        │
│  └─────┬──────┘    │  (passthrough)│        │
│        │           └───┬───────────┘        │
│  ┌─────┴──────┐       │                    │
│  │ Cortex-M0  ├───────┤   ┌──────────┐     │
│  │ (manager)  │◄──────┤   │ ahb_sram │     │
│  └────────────┘       └───┤  64 KB   │     │
│                           └──────────┘     │
└─────────────────────────────────────────────┘
```

## Key Concepts

- **AHB-Lite Passthrough**: The interconnect routes all transfers directly to SRAM (no address decoding)
- **No Default Slave**: Accesses to unmapped addresses are still handled by SRAM (no error response)
- **Reset Synchronizer**: Asynchronous reset synchronized to the clock domain (4-stage synchronizer)

## Memory Map

| Address Range | Device | Notes |
|---------------|--------|-------|
| `0x0000_0000` – `0xFFFF_FFFF` | SRAM (64KB) | Entire address space maps to SRAM (no decoder) |

## Directory Structure

```
lab0_m0_sram/
├── rtl/
│   ├── hy_soc.v              ← Top-level module
│   └── ahb_interconnect.v    ← AHB passthrough (direct to SRAM)
├── tb/
│   └── tb_hy_soc.v           ← Testbench (PASS/FAIL detection)
├── sw/
│   ├── test.c                ← Test firmware
│   ├── gcc/                  ← GCC build (startup.s, link.ld, Makefile)
│   └── arm/                  ← ARM Compiler build (scatter.sct, startup_cm0.S)
└── Makefile                  ← Unified build/simulation Makefile
```

## Firmware (test.c) Behavior

1. **Test 1**: Word write/read at `0x00001000`
2. **Test 2**: Byte write/read at `0x00002000`
3. **Test 3**: Counter accumulation
4. All tests pass → writes `0x900DD00D` to `0x0000_7FFC` → **PASS**

## Build and Run

```bash
# Full build + run
make clean && make all

# Individual steps
make sw          # Compile firmware
make sim         # Compile RTL simulation
make run         # Run simulation
make wave        # Open waveform viewer (GTKWave)
```

Simulator selection (default: VCS):
```bash
make all SIM=vcs        # VCS
make all SIM=verilator  # Verilator
```

## Relationship to Next Lab

In Lab 0, there is no address decoding — any address access is responded to by SRAM.
**Lab 1** adds a Default Slave so that unmapped addresses return an ERROR response.
