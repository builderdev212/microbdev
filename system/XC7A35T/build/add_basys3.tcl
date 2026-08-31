# Adds files for basys3 board

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir [file dirname [info script]]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

set obj [get_filesets sources_1]
set verilog_files [list \
                    [file normalize "../../../cores/basys3/led_shift_reg.v"] \
                    [file normalize "../../../cores/basys3/fd_ss_driver.v"] \
                  ]
add_files -norecurse -fileset $obj $verilog_files
set file_obj [get_files -of_objects [get_filesets sources_1] $verilog_files]
set_property -name "file_type" -value "Verilog" -objects $file_obj
set_property -name "used_in" -value "synthesis" -objects $file_obj
set_property -name "used_in_simulation" -value "0" -objects $file_obj

# Create 'basys3_synth' run (if not found)
if {[string equal [get_runs -quiet basys3_synth] ""]} {
    create_run -name basys3_synth -part xc7a35tcpg236-1 -flow {Vivado Synthesis 2026} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs basys3_synth]
  set_property flow "Vivado Synthesis 2026" [get_runs basys3_synth]
}
set obj [get_runs basys3_synth]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'basys3_synth_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_synth] basys3_synth_synth_report_utilization_0] "" ] } {
  create_report_config -report_name basys3_synth_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs basys3_synth
}
set obj [get_report_configs -of_objects [get_runs basys3_synth] basys3_synth_synth_report_utilization_0]
if { $obj != "" } {

}
set obj [get_runs basys3_synth]
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj
set_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
    -value {-generic LED_SHIFT_REG_EN=1 \
            -generic LED_COUNT=16 \
            -generic SWITCH_COUNT=16 \
            -generic INCLUDE_VGA=0 \
            -generic INCLUDE_VGA_DEMO=0 \
            -generic INCLUDE_UART=0 \
            -generic UART_TRANSMITTER_DEMO=0 \
            -generic UART_LOOPBACK=0} \
    -objects [get_runs basys3_synth]

# Create 'basys3_impl' run (if not found)
if {[string equal [get_runs -quiet basys3_impl] ""]} {
    create_run -name basys3_impl -part xc7a35tcpg236-1 -flow {Vivado Implementation 2026} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run basys3_synth
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs basys3_impl]
  set_property flow "Vivado Implementation 2026" [get_runs basys3_impl]
}
set obj [get_runs basys3_impl]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'basys3_impl_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_init_report_timing_summary_0] "" ] } {
  create_report_config -report_name basys3_impl_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_init_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'basys3_impl_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_opt_report_drc_0] "" ] } {
  create_report_config -report_name basys3_impl_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_opt_report_drc_0]
if { $obj != "" } {

}
# Create 'basys3_impl_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name basys3_impl_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'basys3_impl_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name basys3_impl_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'basys3_impl_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_io_0] "" ] } {
  create_report_config -report_name basys3_impl_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_io_0]
if { $obj != "" } {

}
# Create 'basys3_impl_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_utilization_0] "" ] } {
  create_report_config -report_name basys3_impl_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_utilization_0]
if { $obj != "" } {

}
# Create 'basys3_impl_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_control_sets_0] "" ] } {
  create_report_config -report_name basys3_impl_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_control_sets_0]
if { $obj != "" } {
set_property -name "options.verbose" -value "1" -objects $obj

}
# Create 'basys3_impl_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name basys3_impl_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'basys3_impl_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_incremental_reuse_1] "" ] } {
  create_report_config -report_name basys3_impl_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'basys3_impl_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_timing_summary_0] "" ] } {
  create_report_config -report_name basys3_impl_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_place_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'basys3_impl_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_post_place_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name basys3_impl_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'basys3_impl_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name basys3_impl_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'basys3_impl_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_drc_0] "" ] } {
  create_report_config -report_name basys3_impl_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_drc_0]
if { $obj != "" } {

}
# Create 'basys3_impl_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_methodology_0] "" ] } {
  create_report_config -report_name basys3_impl_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_methodology_0]
if { $obj != "" } {

}
# Create 'basys3_impl_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_power_0] "" ] } {
  create_report_config -report_name basys3_impl_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_power_0]
if { $obj != "" } {

}
# Create 'basys3_impl_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_route_status_0] "" ] } {
  create_report_config -report_name basys3_impl_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_route_status_0]
if { $obj != "" } {

}
# Create 'basys3_impl_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_timing_summary_0] "" ] } {
  create_report_config -report_name basys3_impl_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.routable_nets" -value "1" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'basys3_impl_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name basys3_impl_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_incremental_reuse_0]
if { $obj != "" } {

}
# Create 'basys3_impl_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_clock_utilization_0] "" ] } {
  create_report_config -report_name basys3_impl_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_clock_utilization_0]
if { $obj != "" } {

}
# Create 'basys3_impl_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name basys3_impl_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_route_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'basys3_impl_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_post_route_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name basys3_impl_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'basys3_impl_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name basys3_impl_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs basys3_impl
}
set obj [get_report_configs -of_objects [get_runs basys3_impl] basys3_impl_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
set obj [get_runs basys3_impl]
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

