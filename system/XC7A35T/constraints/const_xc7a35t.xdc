# https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc

## Config ##
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

## Clock signal ##
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN W5 [get_ports clk]
create_clock -period 10.00 -name sys_clk_pin [get_ports clk]

## On-board LEDs ##
set_property IOSTANDARD LVCMOS33 [get_ports led[*]]
set_property PACKAGE_PIN U16 [get_ports led[0]]
set_property PACKAGE_PIN E19 [get_ports led[1]]
set_property PACKAGE_PIN U19 [get_ports led[2]]
set_property PACKAGE_PIN V19 [get_ports led[3]]
set_property PACKAGE_PIN W18 [get_ports led[4]]
set_property PACKAGE_PIN U15 [get_ports led[5]]
set_property PACKAGE_PIN U14 [get_ports led[6]]
set_property PACKAGE_PIN V14 [get_ports led[7]]
set_property PACKAGE_PIN V13 [get_ports led[8]]
set_property PACKAGE_PIN V3  [get_ports led[9]]
set_property PACKAGE_PIN W3  [get_ports led[10]]
set_property PACKAGE_PIN U3  [get_ports led[11]]
set_property PACKAGE_PIN P3  [get_ports led[12]]
set_property PACKAGE_PIN N3  [get_ports led[13]]
set_property PACKAGE_PIN P1  [get_ports led[14]]
set_property PACKAGE_PIN L1  [get_ports led[15]]
