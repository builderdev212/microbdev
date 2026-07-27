# Adds files for UART

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir [file dirname [info script]]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

set obj [get_filesets sources_1]
set verilog_files [list \
                    [file normalize "../../../cores/uart/uart_transmitter.v"] \
                    [file normalize "../../../cores/uart/uart_receiver.v"] \
                    [file normalize "../../../cores/uart/uart_core.v"] \
                    [file normalize "../../../cores/uart/demo/uart_transmitter_demo.v"] \
                  ]
add_files -norecurse -fileset $obj $verilog_files
set file_obj [get_files -of_objects [get_filesets sources_1] $verilog_files]
set_property -name "file_type" -value "Verilog" -objects $file_obj
set_property -name "used_in" -value "synthesis" -objects $file_obj
set_property -name "used_in_simulation" -value "1" -objects $file_obj

# Create 'uart_transmitter_sim' fileset (if not found)
if {[string equal [get_filesets -quiet uart_transmitter_sim] ""]} {
  create_fileset -simset uart_transmitter_sim
}
set obj [get_filesets uart_transmitter_sim]
set verilog_sim_files [list \
                    [file normalize "../../../cores/uart/tb/tb_uart_transmitter.v"] \
                  ]
add_files -norecurse -fileset $obj $verilog_sim_files
set_property -name "sim_wrapper_top" -value "1" -objects $obj
set_property -name "top" -value "tb_uart_transmitter" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj

# Create 'uart_receiver_sim' fileset (if not found)
if {[string equal [get_filesets -quiet uart_receiver_sim] ""]} {
  create_fileset -simset uart_receiver_sim
}
set obj [get_filesets uart_receiver_sim]
set verilog_sim_files [list \
                    [file normalize "../../../cores/uart/tb/tb_uart_receiver.v"] \
                  ]
add_files -norecurse -fileset $obj $verilog_sim_files
set_property -name "sim_wrapper_top" -value "1" -objects $obj
set_property -name "top" -value "tb_uart_receiver" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj


set obj [get_filesets sources_1]
set xci_files [list \
                [file normalize "../../../cores/uart/ip/uart_clk_96_pll/uart_clk_96_pll.xci"] \
                [file normalize "../../../cores/uart/ip/uart_ila/uart_ila.xci"] \
              ]
add_files -norecurse -fileset $obj $xci_files
set xci_obj [get_files -of_objects $obj $xci_files]
generate_target all $xci_obj


# Create 'uart_transmitter_demo_synth' run (if not found)
if {[string equal [get_runs -quiet uart_transmitter_demo_synth] ""]} {
    create_run -name uart_transmitter_demo_synth -part xc7a35tcpg236-1 -flow {Vivado Synthesis 2026} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs uart_transmitter_demo_synth]
  set_property flow "Vivado Synthesis 2026" [get_runs uart_transmitter_demo_synth]
}
set obj [get_runs uart_transmitter_demo_synth]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'uart_transmitter_demo_synth_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_synth] uart_transmitter_demo_synth_synth_report_utilization_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_synth_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs uart_transmitter_demo_synth
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_synth] uart_transmitter_demo_synth_synth_report_utilization_0]
if { $obj != "" } {

}
set obj [get_runs uart_transmitter_demo_synth]
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj
set_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
    -value {-generic LED_SHIFT_REG_EN=0 \
            -generic LED_COUNT=16 \
            -generic SWITCH_COUNT=16 \
            -generic INCLUDE_VGA=0 \
            -generic INCLUDE_VGA_DEMO=0 \
            -generic INCLUDE_UART=1 \
            -generic UART_TRANSMITTER_DEMO=1 \
            -generic UART_LOOPBACK=0} \
    -objects [get_runs uart_transmitter_demo_synth]

# Create 'uart_transmitter_demo_impl' run (if not found)
if {[string equal [get_runs -quiet uart_transmitter_demo_impl] ""]} {
    create_run -name uart_transmitter_demo_impl -part xc7a35tcpg236-1 -flow {Vivado Implementation 2026} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run uart_transmitter_demo_synth
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs uart_transmitter_demo_impl]
  set_property flow "Vivado Implementation 2026" [get_runs uart_transmitter_demo_impl]
}
set obj [get_runs uart_transmitter_demo_impl]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'uart_transmitter_demo_impl_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_init_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_init_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_opt_report_drc_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_opt_report_drc_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_io_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_io_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_utilization_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_utilization_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_control_sets_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_control_sets_0]
if { $obj != "" } {
set_property -name "options.verbose" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'uart_transmitter_demo_impl_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_incremental_reuse_1] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'uart_transmitter_demo_impl_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_place_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_post_place_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_drc_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_drc_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_methodology_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_methodology_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_power_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_power_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_route_status_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_route_status_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.routable_nets" -value "1" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_incremental_reuse_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_clock_utilization_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_clock_utilization_0]
if { $obj != "" } {

}
# Create 'uart_transmitter_demo_impl_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_route_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_post_route_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'uart_transmitter_demo_impl_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name uart_transmitter_demo_impl_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs uart_transmitter_demo_impl
}
set obj [get_report_configs -of_objects [get_runs uart_transmitter_demo_impl] uart_transmitter_demo_impl_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj
}
set obj [get_runs uart_transmitter_demo_impl]
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj


# Create 'uart_loopback_synth' run (if not found)
if {[string equal [get_runs -quiet uart_loopback_synth] ""]} {
    create_run -name uart_loopback_synth -part xc7a35tcpg236-1 -flow {Vivado Synthesis 2026} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs uart_loopback_synth]
  set_property flow "Vivado Synthesis 2026" [get_runs uart_loopback_synth]
}
set obj [get_runs uart_loopback_synth]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'uart_loopback_synth_synth_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_synth] uart_loopback_synth_synth_report_utilization_0] "" ] } {
  create_report_config -report_name uart_loopback_synth_synth_report_utilization_0 -report_type report_utilization:1.0 -steps synth_design -runs uart_loopback_synth
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_synth] uart_loopback_synth_synth_report_utilization_0]
if { $obj != "" } {

}
set obj [get_runs uart_loopback_synth]
set_property -name "strategy" -value "Vivado Synthesis Defaults" -objects $obj
set_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
    -value {-generic LED_SHIFT_REG_EN=0 \
            -generic LED_COUNT=16 \
            -generic SWITCH_COUNT=16 \
            -generic INCLUDE_VGA=0 \
            -generic INCLUDE_VGA_DEMO=0 \
            -generic INCLUDE_UART=1 \
            -generic UART_TRANSMITTER_DEMO=0 \
            -generic UART_LOOPBACK=1} \
    -objects [get_runs uart_loopback_synth]

# Create 'uart_loopback_impl' run (if not found)
if {[string equal [get_runs -quiet uart_loopback_impl] ""]} {
    create_run -name uart_loopback_impl -part xc7a35tcpg236-1 -flow {Vivado Implementation 2026} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run uart_loopback_synth
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs uart_loopback_impl]
  set_property flow "Vivado Implementation 2026" [get_runs uart_loopback_impl]
}
set obj [get_runs uart_loopback_impl]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj
# Create 'uart_loopback_impl_init_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_init_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_init_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps init_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_init_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_opt_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_opt_report_drc_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_opt_report_drc_0 -report_type report_drc:1.0 -steps opt_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_opt_report_drc_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps opt_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps power_opt_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_place_report_io_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_io_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_place_report_io_0 -report_type report_io:1.0 -steps place_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_io_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_place_report_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_utilization_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_place_report_utilization_0 -report_type report_utilization:1.0 -steps place_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_utilization_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_place_report_control_sets_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_control_sets_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_place_report_control_sets_0 -report_type report_control_sets:1.0 -steps place_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_control_sets_0]
if { $obj != "" } {
set_property -name "options.verbose" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_place_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_place_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps place_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_incremental_reuse_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'uart_loopback_impl_place_report_incremental_reuse_1' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_incremental_reuse_1] "" ] } {
  create_report_config -report_name uart_loopback_impl_place_report_incremental_reuse_1 -report_type report_incremental_reuse:1.0 -steps place_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_incremental_reuse_1]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj

}
# Create 'uart_loopback_impl_place_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_place_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps place_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_place_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_post_place_power_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_post_place_power_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_post_place_power_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_place_power_opt_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_post_place_power_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps phys_opt_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "is_enabled" -value "0" -objects $obj
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_route_report_drc_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_drc_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_route_report_drc_0 -report_type report_drc:1.0 -steps route_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_drc_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_route_report_methodology_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_methodology_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_route_report_methodology_0 -report_type report_methodology:1.0 -steps route_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_methodology_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_route_report_power_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_power_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_route_report_power_0 -report_type report_power:1.0 -steps route_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_power_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_route_report_route_status_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_route_status_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_route_report_route_status_0 -report_type report_route_status:1.0 -steps route_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_route_status_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_route_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_route_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps route_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.routable_nets" -value "1" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_route_report_incremental_reuse_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_incremental_reuse_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_route_report_incremental_reuse_0 -report_type report_incremental_reuse:1.0 -steps route_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_incremental_reuse_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_route_report_clock_utilization_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_clock_utilization_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_route_report_clock_utilization_0 -report_type report_clock_utilization:1.0 -steps route_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_clock_utilization_0]
if { $obj != "" } {

}
# Create 'uart_loopback_impl_route_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_bus_skew_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_route_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps route_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_route_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_post_route_phys_opt_report_timing_summary_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_post_route_phys_opt_report_timing_summary_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_post_route_phys_opt_report_timing_summary_0 -report_type report_timing_summary:1.0 -steps post_route_phys_opt_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_post_route_phys_opt_report_timing_summary_0]
if { $obj != "" } {
set_property -name "options.max_paths" -value "10" -objects $obj
set_property -name "options.report_unconstrained" -value "1" -objects $obj
set_property -name "options.warn_on_violation" -value "1" -objects $obj

}
# Create 'uart_loopback_impl_post_route_phys_opt_report_bus_skew_0' report (if not found)
if { [ string equal [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_post_route_phys_opt_report_bus_skew_0] "" ] } {
  create_report_config -report_name uart_loopback_impl_post_route_phys_opt_report_bus_skew_0 -report_type report_bus_skew:1.1 -steps post_route_phys_opt_design -runs uart_loopback_impl
}
set obj [get_report_configs -of_objects [get_runs uart_loopback_impl] uart_loopback_impl_post_route_phys_opt_report_bus_skew_0]
if { $obj != "" } {
set_property -name "options.warn_on_violation" -value "1" -objects $obj
}
set obj [get_runs uart_loopback_impl]
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj
