# HY-SoC

ARM Cortex-M0 based modular SoC educational platform, developed at the
Digital System Architecture Lab (DSAL), Hanyang University.

## Repository Structure

```
hy_soc/
├── edu/                        Educational labs (AHB-Lite, FPGA target)
│   ├── lab0_m0_sram/           CM0 + SRAM (passthrough interconnect)
│   ├── lab1_m0_default_slv/    + AHB Default Slave
│   ├── lab2_m0_led/            + LED Controller (SysTick interrupt)
│   ├── lab3_m0_uart/           + CMSDK APB UART
│   └── lab4_m0_boot/           + Boot ROM + SYSCTRL remap + bootloader
├── common/                     Reusable IP modules
│   ├── ahb_sram/               AHB-Lite SRAM controller
│   ├── ahb_bus/                AHB default slave
│   ├── brom/                   AHB Boot ROM + hex generator
│   ├── uart/                   AHB UART (CMSDK APB UART wrapper)
│   ├── led/                    AHB LED controller
│   ├── sysctrl/                AHB SYSCTRL (remap + SOC_ID)
│   ├── rst/                    CM0 reset synchronizer
│   ├── cmsis/                  CMSIS Core headers (core_cm0.h)
│   ├── include/                hy_soc.h (CMSIS-style device header)
│   ├── sim_models/             uart_mon.v (simulation only)
│   └── arm_ip/                 ARM DesignStart placeholder (see below)
```

## Quick Start

### Prerequisites

- **ARM IP**: Download [Cortex-M0 DesignStart](https://www.arm.com/resources/designstart)
  and place the RTL in `common/arm_ip/cm0_ds/` (see `common/arm_ip/README.md`)
- **Toolchain**: `arm-none-eabi-gcc` (13.x recommended)
- **Simulator**: Synopsys VCS or Verilator 5.x

### Build & Simulate

```bash
# Any lab (e.g. lab3)
cd edu/lab3_m0_uart
make clean && make SIM=vcs        # VCS
make clean && make                # Verilator (default)

# Lab4 with dual-speed UART testbench
cd edu/lab4_m0_boot
make clean && make SIM=vcs                # BAUD=fast (HSTM, ~13s)
make clean && make SIM=vcs BAUD=real      # BAUD=real (115200, ~5min)
```

### Server Setup (ARM IP via symlink)

```bash
ln -s /opt/arm_ip/CortexM0-DS common/arm_ip/cm0_ds
```

## Lab Progression

Each lab builds incrementally on the previous one:

| Lab | Interconnect | Peripherals | Key Concept |
|-----|-------------|-------------|-------------|
| Lab0 | Passthrough | SRAM | Bare CM0 boot |
| Lab1 | 1-slave decode | + Default Slave | AHB ERROR response |
| Lab2 | 2-slave | + LED | SysTick interrupt, AHB decoder/mux |
| Lab3 | 3-slave | + UART | AHB-to-APB adapter, serial I/O |
| Lab4 | 5-slave | + BROM + SYSCTRL | Boot ROM, memory remap, bootloader |

## Memory Map (Lab4)

```
remap=0 (default):
  0x0000_0000  BROM  8KB   (bootloader)
  0x1000_0000  BROM  8KB   (permanent alias)
  0x2000_0000  SRAM 64KB
  0x4000_0000  SYSCTRL
  0x5000_0000  LED
  0x5100_0000  UART

remap=1 (after 'run' command):
  0x0000_0000  SRAM alias  (application vectors)
```

## FPGA Targets

Labs 2-4 include constraint files for:
- **Digilent Nexys A7** (Artix-7)
- **Digilent Zybo Z7-20** (Zynq-7020)

## Toolchain Support

Each lab provides two SW build flows:
- `sw/gcc/` — arm-none-eabi-gcc (open source)
- `sw/arm/` — Arm Compiler 6 / armclang (Keil MDK)

## License

- **HY-SoC RTL & SW**: Copyright (c) 2025-2026 DSAL, Hanyang University
- **ARM IP**: Subject to [ARM DesignStart EULA](https://www.arm.com/resources/designstart/designstart-eula) (not included in this repository)
- **CMSIS**: Apache 2.0 (ARM)
