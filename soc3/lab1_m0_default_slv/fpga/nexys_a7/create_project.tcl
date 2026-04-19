# create_project.tcl — Vivado project for HY-SoC Lab2 on Nexys A7-100T
#
# Usage:
#   cd edu/lab2_m0_led/fpga/nexys_a7
#   vivado -mode batch -source create_project.tcl
#
# After creation:
#   vivado -mode gui lab2_fpga/lab2_fpga.xpr

set proj_name  "lab2_fpga"
set proj_dir   [file normalize "$proj_name"]
set part       "xc7a100tcsg324-1"

# Paths relative to this script
set script_dir [file dirname [file normalize [info script]]]
set rtl_dir    [file normalize "$script_dir/../../rtl"]
set common_dir [file normalize "$script_dir/../../../../common"]
set arm_ip_dir [file normalize "/opt/arm_ip"]

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
  "$common_dir/led/ahb_led.v"                                    \
  "$arm_ip_dir/CortexM0-DS/CORTEXM0INTEGRATION.v"               \
  "$arm_ip_dir/CortexM0-DS/cortexm0ds_logic.v"                  \
]

# ── Add constraints ─────────────────────────────────────────
add_files -fileset constrs_1 "$script_dir/nexys_a7.xdc"

# ── Set top module ──────────────────────────────────────────
set_property top top_fpga [current_fileset]

# ── SRAM init file ──────────────────────────────────────────
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
