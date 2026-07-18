# Adds files for LED demo

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

set obj [get_filesets sources_1]
set verilog_files [list \
                    [file normalize "../../cores/basys3/led_shift_reg.v"] \
                    [file normalize "../../cores/basys3/fd_ss_driver.v"] \
                  ]
add_files -norecurse -fileset $obj $verilog_files
set file_obj [get_files -of_objects [get_filesets sources_1] $verilog_files]
set_property -name "file_type" -value "Verilog" -objects $file_obj
set_property -name "used_in" -value "synthesis" -objects $file_obj
set_property -name "used_in_simulation" -value "0" -objects $file_obj

set obj [get_filesets sources_1]
set xci_files [list \
                [file normalize "../../cores/vga/ip/vga_clk_25_17007_pll.xci"] \
              ]
add_files -norecurse -fileset $obj $xci_files
set xci_obj [get_files -of_objects $obj $xci_files]
set_property synth_checkpoint_mode Singular $xci_obj
generate_target all $xci_obj
