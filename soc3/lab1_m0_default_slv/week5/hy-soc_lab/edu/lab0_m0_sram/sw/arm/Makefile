#==============================================================================
# HY-SoC Lab0 — Arm Compiler 6 (Keil MDK Community) CLI build
#==============================================================================

# ── Toolchain ──────────────────────────────────────────────────────────────
ARMCLANG_DIR := $(HOME)/.vcpkg/artifacts/2139c4c6/compilers.arm.armclang/6.24.0/bin
CC      := $(ARMCLANG_DIR)/armclang
AS      := $(ARMCLANG_DIR)/armclang
LD      := $(ARMCLANG_DIR)/armlink
FROMELF := $(ARMCLANG_DIR)/fromelf

COMMON  := $(abspath ../../../..)
SW_DIR  := $(abspath ..)

# ── Flags ──────────────────────────────────────────────────────────────────
CFLAGS  = --target=arm-arm-none-eabi -mcpu=cortex-m0 -mthumb \
          -O1 -g -Wall \
          -I$(COMMON)/common/include \
          -I$(COMMON)/common/cmsis \
          -DSIMULATION

ASFLAGS = --target=arm-arm-none-eabi -mcpu=cortex-m0 -mthumb -g

LDFLAGS = --cpu=Cortex-M0 --scatter=scatter.sct \
          --strict --entry=Reset_Handler \
          --diag_suppress=L6306W \
          --map --list=lab0.map

# Use MicroLib (small C library, no semihosting)
LDFLAGS += --library_type=microlib
CFLAGS  += -D__MICROLIB

# ── Sources ────────────────────────────────────────────────────────────────
OBJS = startup_cm0.o test.o

.PHONY: all clean

all: lab0.hex

lab0.axf: $(OBJS) scatter.sct
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

lab0.hex: lab0.axf
	$(FROMELF) --vhx --32x1 --output=$@ $<

startup_cm0.o: startup_cm0.S
	$(AS) $(ASFLAGS) -c -o $@ $<

test.o: $(SW_DIR)/test.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.axf *.hex *.map *.htm
