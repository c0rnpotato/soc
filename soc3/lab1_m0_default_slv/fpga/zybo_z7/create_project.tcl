# create_project.tcl — Vivado project for HY-SoC Lab2 on Zybo Z7-20
#
# Usage:
#   cd /home/c0rnpotato/codespace/soc/soc3/lab1_m0_default_slv/fpga/zybo_z7/create_project.tcl
#   vivado -mode batch -source create_project.tcl -nolog -nojournal
#
# After creation:
#   vivado -mode gui lab1_fpga/lab1_fpga.xpr  -nolog -nojournal


# create_project.tcl — Vivado project for HY-SoC Lab2
#
# Usage (Windows CMD - if Vivado is NOT in PATH):
#   1. Set environment: call C:\Xilinx\Vivado\202X.X\settings64.bat
#   2. Run script:      vivado -mode batch -source create_project.tcl -nolog -nojournal
#
# After creation:
#   vivado -mode gui lab1_fpga/lab1_fpga.xpr  -nolog -nojournal
set proj_name  "lab1_fpga"
set proj_dir   [file normalize "$proj_name"]
set part       "xc7z020clg400-1"

# Paths relative to this script
set script_dir [file dirname [file normalize [info script]]]
set rtl_dir    [file normalize "$script_dir/../../rtl"]
set common_dir [file normalize "$script_dir/../../../common"]
set arm_ip_dir [file normalize "$common_dir/arm_ip"]
set sim_dir    [file normalize "$script_dir/../../sim"]
set tb_dir     [file normalize "$script_dir/../../tb"]

# ── Create project ──────────────────────────────────────────
create_project $proj_name $proj_dir -part $part -force
set_property target_language Verilog [current_project]

# ── Add RTL sources ─────────────────────────────────────────
add_files -fileset sources_1 [list \
  "$script_dir/top_fpga.v"                                      \
  "$rtl_dir/hy_soc.v"                                      \
  "$rtl_dir/ahb_interconnect.v"                                  \
  "$rtl_dir/ahb_dcd.v"                                           \
  "$rtl_dir/ahb_slv_mux.v"                                      \
  "$common_dir/rst/cm0_rst_sync.v"                               \
  "$common_dir/ahb_bus/ahb_default_slv.v"                        \
  "$common_dir/ahb_sram/ahb_sram.v"                              \
  "$arm_ip_dir/cm0_ds/CORTEXM0INTEGRATION.v"               \
  "$arm_ip_dir/cm0_ds/cortexm0ds_logic.v"                  \
  "$tb_dir/tb_hy_soc.v"                                      \
  "$sim_dir/code.mem"                                      \
]

# ── Add constraints ─────────────────────────────────────────
add_files -fileset constrs_1 "$script_dir/zybo_z7_20.xdc"

# ── Set top module ──────────────────────────────────────────
set_property top top_fpga [current_fileset]

# ── SRAM init file ──────────────────────────────────────────
# ahb_sram uses $readmemh("code.hex").
# For FPGA, generate hex with arm/Makefile (no -DSIMULATION)
# then copy to the fpga/ directory before synthesis.
#
# The hex file path is relative to simulation working directory.
# For synthesis, Vivado looks in the project directory.
# Copy the hex file to the project directory:
if {[file exists "$script_dir/../../sw/gcc/code.hex"]} {
  file copy -force "$script_dir/../../sw/gcc/code.hex" "$proj_dir/code.hex"
  puts "INFO: Copied code.hex (gcc) to project directory"
} elseif {[file exists "$script_dir/../../sw/arm/lab2.hex"]} {
  file copy -force "$script_dir/../../sw/arm/lab2.hex" "$proj_dir/code.hex"
  puts "INFO: Copied lab2.hex (arm) to project directory"
} else {
  puts "WARNING: No hex file found — build sw first"
}

# ── Synthesis settings ──────────────────────────────────────
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY rebuilt [get_runs synth_1]

# ── Done ────────────────────────────────────────────────────
puts ""
puts "Project created: $proj_dir"
puts "Part: $part"
puts ""
puts "Next steps:"
puts "  1. Build SW:  cd ../../sw/gcc && make       (without SIMULATION flag)"
puts "  2. Copy hex:  cp ../../sw/gcc/code.hex $proj_dir/code.hex"
puts "  3. Open GUI:  vivado -mode gui $proj_dir/${proj_name}.xpr"
puts "  4. Run Synthesis → Implementation → Generate Bitstream"
puts ""
