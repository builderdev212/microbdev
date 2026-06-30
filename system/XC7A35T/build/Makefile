PROJ_NAME:=fpga_xc7a35t

clean:
	@rm -rf $(PROJ_NAME).runs
	@rm -rf $(PROJ_NAME).srcs
	@rm -rf $(PROJ_NAME).sim
	@rm -rf $(PROJ_NAME).cache
	@rm -rf $(PROJ_NAME).hw
	@rm -rf $(PROJ_NAME).ip_user_files
	@rm -rf $(PROJ_NAME).runs
	@rm -f $(PROJ_NAME).xpr
	@rm -rf .Xil
	@rm -f *.log
	@rm -f $(PROJ_NAME)*.bin.gz
	@rm -f $(PROJ_NAME)*.tar.gz
	@rm -f $(PROJ_NAME)*.prm
	@rm -f *.jou

projgen:
	@echo "Generating XC7A35T project..."
	@vivado -mode batch -source projgen_xc7a35t.tcl -notrace -nojournal -log vivado_projgen.log

add_led:
	@echo "Adding led files..."
	@vivado -mode batch -source add_led.tcl -notrace -log vivado_add_led.log ${PROJ_NAME}.xpr
