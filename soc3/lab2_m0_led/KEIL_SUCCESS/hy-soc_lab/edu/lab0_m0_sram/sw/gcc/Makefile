CC      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
COMMON  := $(abspath ../../../..)
SW_DIR  := $(abspath ..)
CFLAGS  = -mcpu=cortex-m0 -mthumb -O1 -g \
           -nostdlib -nostartfiles -Wall \
           -I$(COMMON)/common/include \
           -I$(COMMON)/common/cmsis

ifdef SIMULATION
CFLAGS += -DSIMULATION
endif

.PHONY: all clean

all: code.hex

code.hex: test.elf
	$(OBJCOPY) -O verilog $< $@.raw
	python3 hex2mem.py $@.raw $@

test.elf: startup.s $(SW_DIR)/test.c link.ld
	$(CC) $(CFLAGS) -T link.ld -o $@ startup.s $(SW_DIR)/test.c

clean:
	rm -f *.elf *.hex *.raw *.o
