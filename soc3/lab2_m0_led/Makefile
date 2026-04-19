#==============================================================================
# HY-SoC edu/lab2_m0_led Makefile
#
# Usage:
#   make                    # default: Verilator sim
#   make SIM=vcs            # use VCS instead
#   make SIM=verilator      # explicit Verilator
#   make wave               # open waveform viewer
#==============================================================================

ARM_IP  ?= $(abspath ../../common/arm_ip)
COMMON  := $(abspath ../../common)
SIM_DIR := sim

RTL_DIR := $(abspath rtl)
TB_DIR  := $(abspath tb)

VSRCS := \
    $(RTL_DIR)/hy_soc.v \
    $(RTL_DIR)/ahb_interconnect.v \
    $(RTL_DIR)/ahb_dcd.v \
    $(RTL_DIR)/ahb_slv_mux.v \
    $(COMMON)/rst/cm0_rst_sync.v \
    $(COMMON)/ahb_bus/ahb_default_slv.v \
    $(COMMON)/ahb_sram/ahb_sram.v \
    $(COMMON)/led/ahb_led.v \
    $(ARM_IP)/cm0_ds/CORTEXM0INTEGRATION.v \
    $(ARM_IP)/cm0_ds/cortexm0ds_logic.v

TB_SRC := $(TB_DIR)/tb_hy_soc.v

# ── Simulator selection ──────────────────────────────────────────
SIM ?= verilator

NPROC := $(shell nproc 2>/dev/null || echo 4)
JFLAG := $(shell echo $$(( $(NPROC) < 16 ? $(NPROC) : 16 )))

.PHONY: all sw sim run wave clean

all: sw sim run

sw:
	$(MAKE) -C sw/gcc SIMULATION=1

# ── Verilator flow ───────────────────────────────────────────────
ifeq ($(SIM),verilator)

sim: sw
	mkdir -p $(SIM_DIR)
	cp sw/gcc/code.hex $(SIM_DIR)/code.hex
	verilator --binary --trace -j $(JFLAG) \
	    --Mdir $(SIM_DIR)/obj_dir \
	    $(VSRCS) $(TB_SRC) \
	    --top-module tb_hy_soc \
	    -Wno-fatal \
	    2>&1 | tee $(SIM_DIR)/verilator.log

run:
	cd $(SIM_DIR) && ./obj_dir/Vtb_hy_soc

wave:
	cd $(SIM_DIR) && surfer sim.vcd &

clean:
	rm -rf $(SIM_DIR)/obj_dir $(SIM_DIR)/*.vcd \
	       $(SIM_DIR)/*.hex $(SIM_DIR)/*.log
	$(MAKE) -C sw/gcc clean

# ── VCS flow ─────────────────────────────────────────────────────
else ifeq ($(SIM),vcs)

sim: sw
	mkdir -p $(SIM_DIR)
	cp sw/gcc/code.hex $(SIM_DIR)/code.hex
	cd $(SIM_DIR) && vcs -full64 -sverilog -timescale=1ns/1ps \
	    $(VSRCS) $(TB_SRC) \
	    -debug_access+all \
	    -o simv \
	    2>&1 | tee vcs.log

run:
	cd $(SIM_DIR) && ./simv

wave:
	cd $(SIM_DIR) && dve -vpd vcdplus.vpd &

clean:
	rm -rf $(SIM_DIR)/simv $(SIM_DIR)/simv.daidir \
	       $(SIM_DIR)/csrc $(SIM_DIR)/*.log \
	       $(SIM_DIR)/*.vpd $(SIM_DIR)/*.vcd \
	       $(SIM_DIR)/*.hex $(SIM_DIR)/ucli.key \
	       $(SIM_DIR)/*.fsdb
	$(MAKE) -C sw/gcc clean

endif
