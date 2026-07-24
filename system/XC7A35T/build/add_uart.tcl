# Adds files for UART

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir [file dirname [info script]]

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

set obj [get_filesets sources_1]
set verilog_files [list \
                    [file normalize "../../../cores/uart/uart_transmitter.v"] \
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

set obj [get_filesets sources_1]
set xci_files [list \
                [file normalize "../../../cores/uart/ip/uart_clk_96_pll/uart_clk_96_pll.xci"] \
                [file normalize "../../../cores/uart/ip/uart_ila/uart_ila.xci"] \
              ]
add_files -norecurse -fileset $obj $xci_files
set xci_obj [get_files -of_objects $obj $xci_files]
generate_target all $xci_obj
